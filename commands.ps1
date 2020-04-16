function Invoke-MB() {
    docker-compose rm -fsv
    docker-compose up -d --build
    docker-compose logs -tf run
}

function Invoke-MB-Test() {
    $ENV:COMMAND="./python/validate.py"
    $ENV:FORWARD='3000'
    Invoke-MB
}

function Invoke-MB-Interactive() {
    $ENV:COMMAND="sleep infinity"
    $ENV:FORWARD='3000:3000'
    Invoke-MB
}

