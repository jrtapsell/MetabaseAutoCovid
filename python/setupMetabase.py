#!/usr/bin/env python3
import requests
import time
import json
import os

METABASE_BASE = 'http://localhost:3001/api'
SETUP_KEY_URL = '%s/session/properties' % METABASE_BASE
SETUP_URL = '%s/setup/' % METABASE_BASE
def parse(response):
    if (response.status_code // 100) != 2:
        raise Exception('Got back status code %s: %s\n%s' % (response.status_code, response.url, response.text))
    if len(response.text) > 0:
        return response.json()
    return None
def p(item):
    print(item, flush=True)
def wait_for_metabase():
    while (True):
        try:
            d = parse(requests.get(SETUP_KEY_URL, timeout=1))
            if d["setup_token"]:
                break
        except Exception as e:
            p(">>> Trying again in 10 seconds")
            time.sleep(10)

def run_setup():
    p(">>> Getting the setup token")
    setup_token = parse(requests.get(SETUP_KEY_URL))["setup_token"]
    p(">>> Configuring")
    session_key = parse(requests.post(SETUP_URL, json={
        "prefs": {
            "allow_tracking": False,
            "site_name": "COVID19 Viewer"
        },
        "token": setup_token,
        "user": {
            "email": "admin@example.com",
            "first_name": "Admin",
            "password": os.environ["META_ADMIN_PASS"],
            "last_name": "User"
        }
    }))["id"]

    r = requests.Session()

    r.headers["X-Metabase-Session"] = session_key

    parse(r.delete("%s/database/1" % METABASE_BASE))

    parse(r.post("%s/database/" % METABASE_BASE, json={
        "name": "COVID 19",
        "engine": "postgres",
        "details": {
            "host": os.environ["PGHOST"],
            "dbname": os.environ["COVID_DB"],
            "port": os.environ["PGPORT"],
            "user": os.environ["PGUSER"],
            "password": os.environ["PGPASSWORD"]
        }
    }))

    with open("/tmp/nginx/default.conf", "w") as out:
        out.write("""
        server {
            listen 3000 default_server;

            location / {
                proxy_pass http://localhost:3001;
                proxy_set_header Cookie metabase.SESSION=%s;
                proxy_set_header X-Metabase-Session %s;
            }
        }
        """ % (session_key, session_key))
    

def main():
    p(">>> Waiting for Metabase")
    wait_for_metabase()
    p(">>> Setting up Metabase")
    run_setup()
    p(">>> Done")

main()