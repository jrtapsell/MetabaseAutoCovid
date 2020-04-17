#!/usr/bin/env python3
import requests
import untangle
from datetime import datetime
import csv

SOURCE = "https://publicdashacc.blob.core.windows.net/" + \
    "publicdata?restype=container&comp=list"
FILE_BASE_URL = "https://c19pub.azureedge.net/"

listing = requests.get(SOURCE).text

obj = untangle.parse(listing)


def map_node(node):
    name = node.Name.cdata
    last_mod_text = node.Properties.Last_Modified.cdata
    last_mod = datetime.strptime(last_mod_text, "%a, %d %b %Y %H:%M:%S %Z")
    extension = name.split(".")[-1]
    return {
        "name": name,
        "modified": last_mod,
        "extension": extension,
        "url": "%s%s" % (FILE_BASE_URL, name)
    }


parsed = [map_node(i) for i in obj.EnumerationResults.Blobs.children]

maps = [p for p in parsed if p["extension"] == "geojson"]
current_data_payload = sorted(
        (p for p in parsed if p["extension"]),
        key=lambda x: x["modified"]
    )[-1]

current_data = requests.get(current_data_payload["url"]).json()

lastest_update = datetime.strptime(
    current_data["lastUpdatedAt"],
    "%Y-%m-%dT%H:%M:%S.%fZ")

to_extract = ['countries', 'regions', 'utlas', 'overview']


def normalize(data, key):
    if key in data:
        return {i["date"]: i["value"] for i in data[key]}
    return {}


history_rows = []
latest_rows = []
for target in to_extract:
    root = current_data[target]
    for sector_key in root.keys():
        sector_data = root[sector_key]
        sector_name = sector_data["name"]["value"]

        new_confirmed = normalize(sector_data, "dailyConfirmedCases")
        total_confirmed = normalize(sector_data, "dailyTotalConfirmedCases")
        new_deaths = normalize(sector_data, "dailyDeaths")
        total_deaths = normalize(sector_data, "dailyTotalDeaths")

        all_dates = (
            set(new_confirmed.keys()) |
            set(total_confirmed.keys()) |
            set(new_deaths.keys()) |
            set(total_deaths.keys())
        )

        history = [{
            "date": date,
            "sector_type": target,
            "sector_key": sector_key,
            "sector_name": sector_name,
            "new_confirmed": new_confirmed.get(date, None),
            "total_confirmed": total_confirmed.get(date, None),
            "new_deaths": new_deaths.get(date, None),
            "total_deaths": total_deaths.get(date, None)
        } for date in all_dates]

        history_rows += history

        sector_total_cases = sector_data.get("totalCases", {}) \
            .get("value", None)
        sector_new_cases = sector_data.get("newCases", {}) \
            .get("value", None)
        sector_total_deaths = sector_data.get("deaths", {}) \
            .get("value", None)
        latest_rows += [{
            "sector_type": target,
            "sector_key": sector_key,
            "sector_name": sector_name,
            "cases": sector_total_cases,
            "deaths": sector_total_deaths,
            "new_cases": sector_new_cases
        }]

history_header = [
    "date",
    "sector_type",
    "sector_key",
    "sector_name",
    "new_confirmed",
    "total_confirmed",
    "new_deaths",
    "total_deaths"]
with open('/tmp/nhs/history.csv', 'w', newline='') as csvfile:
    spamwriter = csv.writer(
        csvfile,
        delimiter=',',
        quotechar='"',
        quoting=csv.QUOTE_MINIMAL)
    spamwriter.writerow(history_header)
    for row in history_rows:
        spamwriter.writerow([row[x] for x in history_header])

latest_header = [
    "sector_type",
    "sector_key",
    "sector_name",
    "cases",
    "deaths",
    "new_cases"
]
with open('/tmp/nhs/latest.csv', 'w', newline='') as csvfile:
    spamwriter = csv.writer(
        csvfile,
        delimiter=',',
        quotechar='"',
        quoting=csv.QUOTE_MINIMAL)
    spamwriter.writerow(latest_header)
    for row in latest_rows:
        spamwriter.writerow([row[x] for x in latest_header])

for map in maps:
    with open("/tmp/nginx_mirror/nginx_mirror/%s" % map["name"], "w") as out:
        r = requests.get(map["url"]).text
        out.write(r)
