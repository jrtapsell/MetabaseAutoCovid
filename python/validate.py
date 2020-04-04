#!/usr/bin/env python3
import unittest
import psycopg2
import os
import requests


class TestDockerImage(unittest.TestCase):

    def test_data_loaded(self):
        conn = psycopg2.connect(
            host=os.environ["PGHOST"],
            database=os.environ["COVID_DB"],
            user=os.environ["PGUSER"],
            password=os.environ["PGPASSWORD"]
        )

        cur = conn.cursor()

        cur.execute("SELECT COUNT(*) from raw_confirmed")
        confirmed = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) from raw_recovered")
        recovered = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) from raw_death")
        death = cur.fetchone()[0]

        cur.execute(
            "SELECT table_name " +
            "from information_schema.tables " +
            "where table_schema='public'")
        tables = sorted([i[0] for i in cur.fetchall()])

        cur.execute(
            "select matviewname " +
            "from pg_matviews " +
            "where pg_matviews.schemaname = 'public'")
        views = sorted([i[0] for i in cur.fetchall()])

        cur.close()
        conn.close()

        self.assertNotEquals(confirmed, 0)
        self.assertNotEquals(recovered, 0)
        self.assertNotEquals(death, 0)

        self.assertEquals(
            tables,
            [
                'raw_confirmed',
                'raw_death',
                'raw_recovered'])
        self.assertEquals(
            views,
            [
                'countries_combined',
                'countries_combined_now',
                'countries_confirmed',
                'countries_death',
                'countries_recovered',
                'i100_countries',
                'latest_date'])

        json = requests.get("http://localhost:3000/api/util/stats").json()
        self.assertEquals(
            json["stats"]["database"]["databases"]["total"],
            1
        )


if __name__ == '__main__':
    unittest.main()
