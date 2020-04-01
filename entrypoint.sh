#!/bin/bash
set -e
set -u
#set -x

mkdir -p /dev/shm/fake_tmp/postgresql
ln -s /dev/shm/fake_tmp/postgresql /tmp/postgresql

mkdir -p /dev/shm/fake_tmp/data
ln -s /dev/shm/fake_tmp/data /tmp/

mkdir -p /dev/shm/fake_tmp/transformed
ln -s /dev/shm/fake_tmp/transformed /tmp/

mkdir -p /dev/shm/fake_tmp/nginx
ln -s /dev/shm/fake_tmp/nginx /tmp/

mkdir -p /dev/shm/fake_tmp/nginx_run
ln -s /dev/shm/fake_tmp/nginx_run /run/nginx

mkdir -p /dev/shm/fake_tmp/nginx_tmp
ln -s /dev/shm/fake_tmp/nginx_tmp /tmp/nginx_tmp

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
py ./python/download.py

echo "Converting the data"
py ./python/transform.py

echo "Setting up Postgres"
initdb -A md5 --username=postgres --pwfile=/app/postgres/postgresPassword.txt

echo "Starting Postgres"
ls -lagh /tmp
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
export MB_JETTY_PORT="3001"
java -jar ./metabase.jar 2> /dev/null > /dev/null &

echo "Configuring Metabase"
py ./python/setupMetabase.py

echo "Starting NGINX"
nginx -g 'daemon off;'
echo "Finished"

sleep infinity
kill %1
kill %2