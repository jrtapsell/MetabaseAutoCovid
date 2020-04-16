#!/usr/bin/env python3

from openpyxl import load_workbook
import itertools
import datetime
import csv
import re

UK_DATE = re.compile("^[0-9]{2}/[0-9]{2}/[0-9]{4}$")
STANDARD_DATE = re.compile("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")

wb = load_workbook(filename=r"/tmp/nhs/raw.xlsx", data_only=True)


def all_not_none(row):
    return not all(it is None for it in row)


def skip_including_null(items):
    return itertools.islice(itertools.dropwhile(all_not_none, items), 1, None)


def cleanup(data):
    if isinstance(data, datetime.datetime):
        return data.strftime("%Y-%m-%d")
    if isinstance(data, str):
        if UK_DATE.fullmatch(data):
            return cleanup(datetime.datetime.strptime(data, "%d/%m/%Y"))
        return data.strip()
    return data


def rotate_dates(data, header_info):
    headers = [x for x in header_info if not x[1]]
    dates = [x for x in header_info if x[1]]
    header_names = [x[2] for x in headers] + ["Date", "Value"]

    ret = []
    for row in data[1:]:
        fixed_part = [row[x[0]] for x in headers]
        for date in dates:
            date_name = date[2]
            value = row[date[0]]
            if value:
                ret += [fixed_part + [date_name, value]]
    return [header_names]+ret


for sheet in wb.worksheets:
    if sheet.title == "Summary":
        continue
    title = sheet.title
    rows = [[cleanup(cell.value) for cell in row] for row in sheet.rows]
    heading = rows[0][0]
    rows = [x for x in skip_including_null(skip_including_null(rows))]
    rows = [row for row in rows if all_not_none(row)]

    startRow = {
        'UK Cases': None,
        'UK Deaths': 1,
        'Countries': None,
        'NHS Regions': None,
        'UTLAs': None,
        'Recovered patients': None
    }[title]

    endRow = {
        'UK Cases': None,
        'UK Deaths': None,
        'Countries': -1,
        'NHS Regions': -1,
        'UTLAs': -1,
        'Recovered patients': None
    }[title]

    rows = rows[startRow:endRow]
    isDateHeader = [STANDARD_DATE.fullmatch(str(it)) is not None for it in rows[0]]

    if any(isDateHeader):
        headerInfo = [(id, x[0], x[1]) for id, x in enumerate(zip(isDateHeader, rows[0]))]
        rows = rotate_dates(rows, headerInfo)

    if title == "UK Deaths":
        ret = []
        ret += [["Date", "Region", "Value"]]

        regions = [(id, x) for id, x in enumerate(rows[0]) if x][3:]
        for row in rows[1:]:
            for region in regions:
                index = region[0]
                value = row[index]

                if value:
                    ret += [[row[0], region[1], value]]
        rows = ret

    rows[0] = [x.replace(" ", "_") for x in rows[0] if x is not None]
    rows = [row[:len(rows[0])] for row in rows]
    with open('/tmp/nhs/%s.csv' % title, 'w', newline='') as csvfile:
        spamwriter = csv.writer(
            csvfile,
            delimiter=',',
            quotechar='"',
            quoting=csv.QUOTE_MINIMAL)
        for row in rows:
            spamwriter.writerow(row)
