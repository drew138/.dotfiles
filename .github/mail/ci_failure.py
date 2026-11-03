import html
import json
import os
import sys
import urllib.request
from datetime import datetime
from pathlib import Path
from string import Template
from zoneinfo import ZoneInfo

TRIGGERS = {"schedule": "weekly schedule", "workflow_dispatch": "manual run", "push": "push"}


def api(path):
    request = urllib.request.Request(
        f"https://api.github.com/{path}",
        headers={
            "Authorization": f"Bearer {os.environ['GH_TOKEN']}",
            "Accept": "application/vnd.github+json",
        },
    )
    with urllib.request.urlopen(request) as response:
        return json.load(response)


def failed_jobs(repo, run_id):
    jobs, page = [], 1
    while True:
        data = api(f"repos/{repo}/actions/runs/{run_id}/jobs?per_page=100&page={page}")
        jobs += data["jobs"]
        if not data["jobs"] or len(jobs) >= data["total_count"]:
            break
        page += 1
    return [job["name"] for job in jobs if job["conclusion"] == "failure"]


def main():
    repo, run_id, sha = os.environ["REPO"], os.environ["RUN_ID"], os.environ["SHA"]
    run = api(f"repos/{repo}/actions/runs/{run_id}")
    started = datetime.fromisoformat(run["run_started_at"].replace("Z", "+00:00")).astimezone(ZoneInfo("America/Bogota"))
    message = api(f"repos/{repo}/commits/{sha}")["commit"]["message"].splitlines()[0]
    failed = failed_jobs(repo, run_id)
    event = os.environ["EVENT"]

    values = {
        "repo": html.escape(repo),
        "branch": html.escape(os.environ["BRANCH"]),
        "commit": html.escape(f"{sha[:7]} {message}"),
        "trigger": html.escape(TRIGGERS.get(event, event)),
        "failed": "<br>".join(html.escape(name) for name in failed) or "none reported",
        "run": html.escape(f"#{run['run_number']}, {started:%a} {started.day} {started:%b %Y %H:%M} {started.isoformat()[-6:]}"),
        "run_url": html.escape(run["html_url"]),
    }
    template = Template((Path(__file__).parent / "ci-failure.html").read_text())
    sys.stdout.write(template.substitute(values))


main()
