#!/usr/bin/env python3
import requests
import time

SETUP_KEY_URL = 'http://localhost:3000/api/session/properties'

while True:
    try:
        print("Checking if Metabase is ready")
        d = requests.get(SETUP_KEY_URL)
        break
    except Exception as e:
        time.sleep(2)

    