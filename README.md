# Metabase Automatic COVID19 data

# What is this project
This is a single docker image that can be spun up, that creates a Metabase instance with data loaded from the WHO dataset

# How do I run this
Run the following command

    docker run --rm --tmpfs /tmp --read-only docker.pkg.github.com/jrtapsell/metabaseautocovid/metabaseautocovid:latest

# What does the image do

This image contains:
- An instance of Postgres
- An instance of Metabase configured to use the above for app storage
- An instance of Nginx that proxies Metabase and bypasses auth

It downloads the data that WHO provide, aggregated by [Johns Hopkins CSSE](https://github.com/CSSEGISandData/COVID-19), transforms it and then loads it into the Metabase instance.
