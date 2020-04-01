#!/bin/bash
set -e
set -u
set -x

export PGDATA="/tmp/pgsql/data"
export PGPASSWORD=$(cat /app/postgres/postgresPassword.txt)
export PGUSER="postgres"
export PGHOST="localhost"

echo "Downloading the data"
python3 ./python/download.py

echo "Converting the data"
python3 ./python/transform.py

echo "Setting up Postgres"
initdb -A md5 --username=postgres --pwfile=/app/postgres/postgresPassword.txt

echo "Starting Postgres"
postgres 2> /dev/null > /dev/null &
sleep 2

echo "Setting up database"
for f in postgres/*.sql;
do
    echo "++ $f"
    psql -f "$f"
done

echo "Starting Metabase"
export MB_DB_TYPE="postgres"
export MB_DB_DBNAME="metabase"
export MB_DB_PORT="5432"
export MB_DB_USER="$PGUSER"
export MB_DB_PASS="$PGPASSWORD"
export MB_DB_HOST="localhost"
java -jar ./metabase.jar 2> /dev/null > /dev/null &

echo "Configuring Metabase"
python3 ./python/configure.py

echo "Finished"
wait %1