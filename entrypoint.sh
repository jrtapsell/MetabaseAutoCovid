#!/bin/bash
set -e
set -u
#set -x

export PGDATA="/tmp/pgsql/data"
export PGPASSWORD=$(cat /app/postgres/postgresPassword.txt)
export PGUSER="postgres"
export PGHOST="localhost"

function py {
    fileName=$1
    echo "Running $fileName - $(sha1sum $fileName)"
    python3 "$fileName"
}

echo "Downloading the data"
mkdir /tmp/data
py ./python/download.py

echo "Converting the data"
mkdir /tmp/transformed
py ./python/transform.py

echo "Setting up Postgres"
mkdir /tmp/postgresql
initdb -A md5 --username=postgres --pwfile=/app/postgres/postgresPassword.txt  2> /dev/null > /dev/null

echo "Starting Postgres"
mkdir -p /tmp/run/postgresql/
postgres 2> /dev/null > /dev/null &
sleep 2

echo "Setting up database"
for f in postgres/*.sql;
do
    echo "++ $f"
    psql -f "$f" 2> /dev/null > /dev/null
done

echo "Starting Metabase"
export MB_DB_TYPE="postgres"
export MB_DB_DBNAME="metabase"
export MB_DB_PORT="5432"
export MB_DB_USER="$PGUSER"
export MB_DB_PASS="$PGPASSWORD"
export MB_DB_HOST="localhost"
export MB_JETTY_PORT="3001"
java -jar ./metabase.jar 2> /dev/null > /dev/null &

echo "Configuring Metabase"
mkdir /tmp/nginx
py ./python/setupMetabase.py

echo "Starting NGINX"
mkdir /tmp/nginx_tmp
mkdir -p /tmp/nginx_run/nginx
nginx -g 'daemon off;' 2> /dev/null > /dev/null &
echo "Finished"

sleep 2
echo "Ready at http://localhost:3000"
sleep infinity
kill %1
kill %2