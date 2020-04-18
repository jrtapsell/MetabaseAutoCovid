#!/bin/bash
set -eE
set -u

function on_error() {
    echo "FAILURE"
    echo "-------- STDOUT"
    cat /tmp/silenced_out
    echo "-------- STDERR"
    cat /tmp/silenced_err
    echo "--------"
}

trap 'on_error' ERR
touch /tmp/silenced_out
touch /tmp/silenced_err

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
    echo "Running $fileName - $(sha1sum "$fileName")"
    python3 "$fileName"
}
echo "Downloading map data"
mkdir -p /tmp/data
mkdir -p /tmp/nginx_mirror/nginx_mirror
wget https://datahub.io/core/country-list/r/data.csv -O /tmp/data/countries.csv 2> /tmp/silenced_err > /tmp/silenced_out

echo "Downloading the data"
py ./python/download.py

echo "Downloading NHS Data"
mkdir /tmp/nhs/
py ./python/download_nhs.py

echo "Converting the data"
mkdir -p /tmp/transformed
py ./python/transform.py

echo "Setting up Postgres"
mkdir -p /tmp/postgresql
initdb -A md5 --username=postgres --pwfile=/tmp/secrets/pgpassword 2> /tmp/silenced_err > /tmp/silenced_out

echo "Starting Postgres"
mkdir -p /tmp/run/postgresql/
postgres 2> /tmp/pg_err > /tmp/pg_out &
sleep 2

echo "Setting up database"
for f in postgres/*.sql;
do
    echo "++ $f"
    psql -v ON_ERROR_STOP=ON -f "$f" --set=covid_db=$COVID_DB --set=meta_db=$MB_DB_DBNAME 2> /tmp/silenced_err > /tmp/silenced_out
done

echo "Starting Metabase"
java -Xmx1g -Xms1g -jar ./metabase.jar 2> /tmp/mb_err > /tmp/mb_out &

echo "Configuring Metabase"
mkdir -p /tmp/nginx
py ./python/setupMetabase.py

echo "Starting NGINX"
mkdir -p /tmp/nginx_tmp
mkdir -p /tmp/nginx_run/nginx
nginx -g 'daemon off;' 2> /tmp/nginx_err > /tmp/nginx_out &

echo "Adding maps"
py ./python/add_maps.py

echo "Finished"
sleep 2

echo "Ready at http://localhost:3000"
$@

kill %1
kill %2