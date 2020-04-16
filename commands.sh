function Invoke-MB() {
    docker-compose rm -fsv
    docker-compose up -d --build
    docker-compose logs -tf run
}

function Invoke-MB-Test() {
    export COMMAND="./python/validate.py"
    export FORWARD='3000'
    Invoke-MB
}

function Invoke-MB-Interactive() {
    export COMMAND="sleep infinity"
    export FORWARD='3000:3000'
    Invoke-MB
}

