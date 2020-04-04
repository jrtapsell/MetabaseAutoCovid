# Metabase Automatic COVID19 data

# What is this project
This is a single docker image that can be spun up, that creates a Metabase instance with data loaded from the WHO dataset

# How do I run this
Run the following command

    docker run --rm --tmpfs /tmp --read-only docker.pkg.github.com/jrtapsell/metabaseautocovid/metabaseautocovid:latest

# What does the image contain