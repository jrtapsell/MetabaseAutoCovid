# Metabase Automatic COVID19 data

[![Known Vulnerabilities](https://snyk.io/test/github/jrtapsell/MetabaseAutoCovid/badge.svg?targetFile=python/requirements.txt)](https://snyk.io/test/github/jrtapsell/MetabaseAutoCovid?targetFile=python/requirements.txt)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/5ecb24e9b5f740b6813a31c3766af6ae)](https://www.codacy.com/manual/jrtapsell/MetabaseAutoCovid?utm_source=github.com&utm_medium=referral&utm_content=jrtapsell/MetabaseAutoCovid&utm_campaign=Badge_Grade) [![Join the chat at https://gitter.im/MetabaseAutoCovid/community](https://badges.gitter.im/MetabaseAutoCovid/community.svg)](https://gitter.im/MetabaseAutoCovid/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
![](https://github.com/jrtapsell/MetabaseAutoCovid/workflows/Linters/badge.svg)
![](https://github.com/jrtapsell/MetabaseAutoCovid/workflows/Push%20Build/badge.svg)

## What is this project

This is a single docker image that can be spun up, that creates a Metabase instance with data loaded from the WHO dataset

## How do I run this

-   Run the following command

        docker run --rm --tmpfs /tmp --read-only -p 3000:3000 docker.pkg.github.com/jrtapsell/metabaseautocovid/metabaseautocovid:latest

    Once this is done, the system will start up and download the data.

-   Once you see a line like this:

        Ready at http://localhost:3000

    Then you can see the Metabase instance at <http://localhost:3000>

## What does the image do

This image contains:

-   An instance of Postgres
-   An instance of Metabase configured to use the above for app storage
-   An instance of Nginx that proxies Metabase and bypasses auth

It downloads the data provided by the WHO, aggregated by [Johns Hopkins CSSE](https://github.com/CSSEGISandData/COVID-19), along with the [GOV.UK](https://coronavirus.data.gov.uk/about) provided data, transforms it and then loads it into the Postgres instance, ready to be analysed in Metabase

## Licencing

| Element    | AGLP | Custom | Link                                                                         |
|------------|------|--------|------------------------------------------------------------------------------|
| Scripting  | x    |        | <https://www.gnu.org/licenses/agpl-3.0.txt>                                  |
| Data - WHO |      |   x    | <https://github.com/CSSEGISandData/COVID-19#:~:text=Terms>                   |
| Data - NHS |      |   x    | <https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/> |
| Metabase   | x    |        | <https://www.metabase.com/license/>                                          |
| Nginx      |      |   x    | <https://nginx.org/LICENSE>                                                  |
| PostgreSQL |      |   x    | <https://www.postgresql.org/about/licence/>                                  |

## Downloaded Maps

  - <http://localhost:3000/nginx_mirror/countries.geojson>
  - <http://localhost:3000/nginx_mirror/regions.geojson>
  - <http://localhost:3000/nginx_mirror/utlas.geojson>