# Metabase Automatic COVID19 data
[![Known Vulnerabilities](https://snyk.io/test/github/jrtapsell/MetabaseAutoCovid/badge.svg?targetFile=python/requirements.txt)](https://snyk.io/test/github/jrtapsell/MetabaseAutoCovid?targetFile=python/requirements.txt)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/5ecb24e9b5f740b6813a31c3766af6ae)](https://www.codacy.com/manual/jrtapsell/MetabaseAutoCovid?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=jrtapsell/MetabaseAutoCovid&amp;utm_campaign=Badge_Grade)
![](https://github.com/jrtapsell/MetabaseAutoCovid/workflows/Linters/badge.svg)
![](https://github.com/jrtapsell/MetabaseAutoCovid/workflows/Push%20Build/badge.svg)
## What is this project
This is a single docker image that can be spun up, that creates a Metabase instance with data loaded from the WHO dataset

## How do I run this
Run the following command

    docker run --rm --tmpfs /tmp --read-only -p 3000:3000 docker.pkg.github.com/jrtapsell/metabaseautocovid/metabaseautocovid:latest

## What does the image do

This image contains:
  - An instance of Postgres
  - An instance of Metabase configured to use the above for app storage
  - An instance of Nginx that proxies Metabase and bypasses auth

It downloads the data that WHO provide, aggregated by [Johns Hopkins CSSE](https://github.com/CSSEGISandData/COVID-19), transforms it and then loads it into the Metabase instance.
