#!/usr/bin/env python3
from common import files
import csv
import re
import itertools

dataset = {}

date_regex = re.compile(r"(?P<month>[0-9]+)/(?P<day>[0-9]+)/(?P<year>[0-9]+)")


def normalize_date(date):
    parsed = re.match(date_regex, date)
    parsed_date = parsed.groupdict()
    textual = "20{:0>2}-{:0>2}-{:0>2}".format(
        parsed_date["year"],
        parsed_date["month"],
        parsed_date["day"])
    return textual


def expand(row):
    region = row["Province/State"]
    country = row["Country/Region"]
    lat = row["Lat"]
    lon = row["Long"]
    return [{
        "region": region,
        "country": country,
        "lat": lat,
        "lon": lon,
        "date": normalize_date(date_name),
        "value": row[date_name]
    } for date_name in row.keys() if re.match(date_regex, date_name)]


for item in files:
    with open(item["downloadName"], 'r') as inFile:
        reader = csv.DictReader(inFile)
        lines = itertools.chain(*[expand(line) for line in reader])
    with open(item["transformedName"], 'w') as outFile:
        writer = csv.DictWriter(
            outFile,
            ["region", "country", "lat", "lon", "date", "value"])
        writer.writeheader()
        writer.writerows(lines)
