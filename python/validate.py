#!/usr/bin/env python3
import unittest
import psycopg2
import os
import requests

EXPECTED_TABLES = [
    'all_latest',
    'countries_combined',
    'countries_combined_now',
    'countries_confirmed',
    'countries_death',
    'countries_recovered',
    'i100_countries',
    'latest_date',
    'merged_countries',
    'raw_confirmed',
    'raw_death',
    'raw_latest',
    'raw_nhs_cases',
    'raw_nhs_contries',
    'raw_nhs_deaths',
    'raw_nhs_recovered',
    'raw_nhs_regions',
    'raw_nhs_utla',
    'raw_recovered']


class TestDockerImage(unittest.TestCase):

    def test_data_loaded(self):
        conn = psycopg2.connect(
            host=os.environ["PGHOST"],
            database=os.environ["COVID_DB"],
            user=os.environ["PGUSER"],
            password=os.environ["PGPASSWORD"]
        )

        cur = conn.cursor()
        cur.execute(
            "SELECT table_name " +
            "from information_schema.tables " +
            "where table_schema='public'")
        tables = sorted([i[0] for i in cur.fetchall()])
        self.assertEqual(tables, EXPECTED_TABLES, "Didn't find all the tables")

        for table_name in EXPECTED_TABLES:
            cur.execute("SELECT count(*) from %s;" % table_name)
            rows = cur.fetchone()[0]
            self.assertNotEqual(rows, 0, "Table %s was empty" % table_name)

        cur.execute(
            """with mentioned as (
            select raw_confirmed.country from raw_confirmed
            union select raw_death.country from raw_death
            union select raw_recovered.country from raw_recovered
            union select raw_latest.Country_Region as country from raw_latest)

            select count(*) from mentioned
            left join merged_countries 
                on mentioned.country = merged_countries.name
            where merged_countries.code is null"""
        )
        self.assertEqual(
            0, 
            cur.fetchone()[0], 
            "Found a country not in the countries list")

        json = requests.get("http://localhost:3000/api/util/stats") \
            .json()

        self.assertEqual(
            json["stats"]["database"]["databases"]["total"],
            1
        )

        utla_json = requests.get("http://localhost:3000/nginx_mirror/utlas.geojson").json()
        map_utla_names = {
            x["properties"]["ctyua16cd"]: x["properties"]["ctyua16nm"]
            for x in utla_json["features"]}

        cur.execute("select distinct area_code, area_name from raw_nhs_utla")
        pg_utla_names = {x[0]: x[1] for x in cur.fetchall()}

        pg_key_set = set(pg_utla_names.keys())
        map_key_set = set(map_utla_names.keys())

        print("In PG Only")
        for pg_only_name in pg_key_set - map_key_set:
            print(pg_only_name, pg_utla_names[pg_only_name])

        print("In Map Only")
        for map_only_name in map_key_set - pg_key_set:
            print(map_only_name, map_utla_names[map_only_name])

        cur.close()
        conn.close()


if __name__ == '__main__':
    unittest.main()
