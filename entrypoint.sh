#!/bin/bash
set -e
set -u
#set -x

mkdir -p /tmp/secrets/

export PGDATA="/tmp/pgsql/data"
export PGPASSWORD="$(openssl rand -base64 20)"
echo "$PGPASSWORD" > /tmp/secrets/pgpassword
export PGUSER="postgres"
export PGHOST="localhost"
export PGPORT="5432"
export COVID_DB="covid19"

export META_ADMIN_PASS="$(openssl rand -base64 20)"
export META_USER_PASS="$(openssl rand -base64 20)"

export MB_DB_TYPE="postgres"
export MB_DB_DBNAME="metabase"
export MB_DB_PORT="$PGPORT"
export MB_DB_USER="$PGUSER"
export MB_DB_PASS="$PGPASSWORD"
export MB_DB_HOST="localhost"
export MB_JETTY_PORT="3001"

function py {
    fileName=$1
    echo "Running $fileName - $(sha1sum $fileName)"
    python3 "$fileName"
}

echo "Downloading the data"
mkdir -p /tmp/data
py ./python/download.py

echo "Converting the data"
mkdir -p /tmp/transformed
py ./python/transform.py

echo "Setting up Postgres"
mkdir -p /tmp/postgresql
initdb -A md5 --username=postgres --pwfile=/tmp/secrets/pgpassword 2> /dev/null > /dev/null

echo "Starting Postgres"
mkdir -p /tmp/run/postgresql/
postgres 2> /dev/null > /dev/null &
sleep 2

echo "Setting up database"
for f in postgres/*.sql;
do
    echo "++ $f"
    psql -f "$f" --set=covid_db=$COVID_DB --set=meta_db=$MB_DB_DBNAME 2> /dev/null > /dev/null
done

echo "Starting Metabase"
java -Xmx1g -Xms1g -jar ./metabase.jar 2> /dev/null > /dev/null &

echo "Configuring Metabase"
mkdir -p /tmp/nginx
py ./python/setupMetabase.py

echo "Starting NGINX"
mkdir -p /tmp/nginx_tmp
mkdir -p /tmp/nginx_run/nginx
nginx -g 'daemon off;' 2> /dev/null > /dev/null &
echo "Finished"

sleep 2
echo "Ready at http://localhost:3000"
$@
kill %1
kill %2