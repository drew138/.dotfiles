#pragma once

#include <math.h>
#include <net/if.h>
#include <net/if_mib.h>
#include <stdio.h>
#include <string.h>
#include <sys/sysctl.h>
#include <sys/time.h>

static const char *unit_str[] = {
    " Bps",
    "KBps",
    "MBps",
};

enum unit { UNIT_BPS = 0, UNIT_KBPS, UNIT_MBPS };

struct network {
  uint32_t row;
  struct ifmibdata data;

  struct timeval tv_nm1;
  struct timeval tv_n;

  double up;
  double down;
  enum unit up_unit;
  enum unit down_unit;
};

static inline void ifdata(uint32_t net_row, struct ifmibdata *data) {
  static size_t size = sizeof(struct ifmibdata);
  static int mib[] = {CTL_NET,      PF_LINK, NETLINK_GENERIC,
                      IFMIB_IFDATA, 0,       IFDATA_GENERAL};

  mib[4] = net_row;
  sysctl(mib, 6, data, &size, NULL, 0);
}

static inline void network_init(struct network *net, const char *ifname) {
  memset(net, 0, sizeof(*net));

  static int count_mib[] = {CTL_NET, PF_LINK, NETLINK_GENERIC, IFMIB_SYSTEM,
                            IFMIB_IFCOUNT};

  uint32_t count = 0;
  size_t size = sizeof(count);
  sysctl(count_mib, 5, &count, &size, NULL, 0);

  for (uint32_t i = 0; i < count; i++) {
    ifdata(i, &net->data);
    if (strcmp(net->data.ifmd_name, ifname) == 0) {
      net->row = i;
      break;
    }
  }

  /* Initialize time baseline */
  gettimeofday(&net->tv_nm1, NULL);
}

static inline void select_unit(double bytes_per_sec, double *value,
                               enum unit *unit) {
  if (bytes_per_sec <= 0.0) {
    *value = 0.0;
    *unit = UNIT_BPS;
  } else if (bytes_per_sec < 1000.0) {
    *value = bytes_per_sec;
    *unit = UNIT_BPS;
  } else if (bytes_per_sec < 1000.0 * 1000.0) {
    *value = bytes_per_sec / 1000.0;
    *unit = UNIT_KBPS;
  } else {
    *value = bytes_per_sec / (1000.0 * 1000.0);
    *unit = UNIT_MBPS;
  }
}

static inline void network_update(struct network *net) {
  gettimeofday(&net->tv_n, NULL);

  double delta_t = (net->tv_n.tv_sec - net->tv_nm1.tv_sec) +
                   (net->tv_n.tv_usec - net->tv_nm1.tv_usec) * 1e-6;

  net->tv_nm1 = net->tv_n;

  if (delta_t <= 0.0 || delta_t > 10.0)
    return;

  uint64_t ibytes_prev = net->data.ifmd_data.ifi_ibytes;
  uint64_t obytes_prev = net->data.ifmd_data.ifi_obytes;

  ifdata(net->row, &net->data);

  double down_bps =
      (double)(net->data.ifmd_data.ifi_ibytes - ibytes_prev) / delta_t;
  double up_bps =
      (double)(net->data.ifmd_data.ifi_obytes - obytes_prev) / delta_t;

  select_unit(down_bps, &net->down, &net->down_unit);
  select_unit(up_bps, &net->up, &net->up_unit);
}
