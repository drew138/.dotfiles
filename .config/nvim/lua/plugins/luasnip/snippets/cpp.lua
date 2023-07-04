local ls = require("luasnip")
local snippet = ls.s
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

local Snippets = {
    snippet(
        "cpt",
        fmt(
            [[
            #include <bits/stdc++.h>
            using namespace std;

            typedef long long ll;
            typedef long double ld;
            typedef pair<int, int> pii;
            typedef vector<int> vi; // int vec
            typedef vector<vi> vvi; // int vec vec
            typedef vector<pii> vpi; // int int pair vec

            #define d(x) cout << #x << " = " << x << endl;
            #define ios ios_base::sync_with_stdio(0), cin.tie(0);
            #define forn(i, n) for (int i=0; i< (int)n; ++i)
            #define forab(i, a, b) for (int i=a; i< (int)b; ++i)
            #define fored(i,l,r) for(int i=(int)r; i>= (int)l; --i)
            #define foreach(a, b) for (auto&(a) : (b))
            #define formap(map) for (const auto &[key, value] : map)
            #define all(v) v.begin(), v.end()
            #define allar(arr, sz) arr, arr + sz
            #define ms(ar, val) memset(ar, val, size)
            #define pq(type) priority_queue<type>
            #define pqd(type) priority_queue<type,vector<type>,greater<type> >
            #define umap unordered_map
            #define uset unordered_set
            #define imax INT_MAX
            #define imin INT_MIN
            #define pb push_back
            #define mp make_pair
            #define fi first
            #define se second
            #define nl "\n"
            #define in(t) while (t--)

            const double pi = acos(-1);
            const int maxn = 1e5 + 5;
            const ll MOD = 1e9 + 7;
            const ll INF = 1e9;
            const ll INFLL = 1000000000000000005LL;
            const ld EPS = 1e-9;
            int dirx[8] = {{ -1, 0, 0, 1, -1, -1, 1, 1 }};
            int diry[8] = {{ 0, 1, -1, 0, -1, 1, -1, 1 }};

            // snippets
            // hash: hash used for pairs used in unordered maps
            // comp: comparator of pairs used for priority queues
            // ncrmod: choose function for big numbers using modulo
            // ncr: choose function
            // nprmod: permutation function for big numbers using modulo
            // npr: permutation function
            // sieve: sieve of eratosthenes

            int main() {{
              ios
              cout << setprecision(20)<< fixed;
              {}
            }}
            ]],
            {
                i(0),
            }
        )
    ),
    snippet(
        "hash",
        fmt(
            [[
            // unordered_map<pair<int,int>, other_type, HASH> m;
            struct HASH{{
             size_t operator()(const pair<int,int>&x)const{{
              return hash<long long>()(((long long)x.first)^(((long long)x.second)<<32));
             }}
            }};
            ]],
            {}
        )
    ),
    snippet(
        "comp",
        fmt(
            [[
            // priority_queue<pair<int,int>, vector<pair<int,int>>, Comparator> pq;
            struct Comparator {{
              constexpr bool operator()(
                  pair<int, int> const& a,
                  pair<int, int> const& b)
                  const noexcept
              {{
                  return a.second < b.second;
              }}
            }};
            ]],
            {}
        )
    ),
    snippet(
        "ncrmod",
        fmt(
            [[
            ll inv(ll num, int mod) {{
              ll pow = mod - 2;
              ll res = 1;
              while (pow) {{
                if (pow % 2 == 1) {{
                  res *= num;
                  res %= mod;
                }}
                num *= num;
                num %= mod;
                pow /= 2;
              }}
              return res;
            }}

            ll ncrmod(ll n, ll r, vector<int> &fact, int mod = MOD) {{
              ll total = fact[n] % mod;
              total *= inv(fact[r], mod) % mod;
              total %= mod;
              total *= inv(fact[n - r], mod) % mod;
              total %= mod;
              return total;
            }}
            ]],
            {}
        )
    ),
    snippet(
        "ncr",
        fmt(
            [[
            ll ncrmod(ll n, ll r, vector<int> &fact) {{
              ll total = fact[n];
              total /= fact[n - r];
              total /= fact[r];
              return total;
            }}
            ]],
            {}
        )
    ),
    snippet(
        "nprmod",
        fmt(
            [[
            ll inv(ll num, int mod) {{
              ll pow = mod - 2;
              ll res = 1;
              while (pow) {{
                if (pow % 2 == 1) {{
                  res *= num;
                  res %= mod;
                }}
                num *= num;
                num %= mod;
                pow /= 2;
              }}
              return res;
            }}

            ll nprmod(ll n, ll r, vector<int> &fact, int mod = MOD) {{
              ll total = fact[n] % mod;
              total *= inv(fact[r], mod) % mod;
              total %= mod;
              return total;
            }}
            ]],
            {}
        )
    ),
    snippet(
        "npr",
        fmt(
            [[
            ll npr(ll n, ll r, vector<int> &fact) {{
              ll total = fact[n];
              total /= fact[r];
              return total;
            }}
            ]],
            {}
        )
    ),
    snippet(
        "sieve",
        fmt(
            [[
            vector<bool> seen(4e4 + 1, false);
            vector<int> primes;
            for (int i = 2; i < seen.size(); ++i) {{
              if (!seen[i]) {{
                primes.push_back(i);
                for (int j = 2 * i; j < seen.size(); j += i)
                  seen[j] = true;
              }}
            }}
            ]],
            {}
        )
    ),
}

return Snippets
