files = [
    {
        "sourceDir": "csse_covid_19_data/csse_covid_19_time_series",
        "sourceName": "time_series_covid19_confirmed_global.csv",
        "sourceBranch": "master",
        "downloadName": "/tmp/data/Confirmed.csv",
        "transformedName": "/tmp/transformed/Confirmed.csv",
        "transform": True
    },
    {
        "sourceDir": "csse_covid_19_data/csse_covid_19_time_series",
        "sourceName": "time_series_covid19_deaths_global.csv",
        "sourceBranch": "master",
        "downloadName": "/tmp/data/Deaths.csv",
        "transformedName": "/tmp/transformed/Deaths.csv",
        "transform": True
    },
    {
        "sourceDir": "csse_covid_19_data/csse_covid_19_time_series",
        "sourceName": "time_series_covid19_recovered_global.csv",
        "sourceBranch": "master",
        "downloadName": "/tmp/data/Recovered.csv",
        "transformedName": "/tmp/transformed/Recovered.csv",
        "transform": True
    },
    {
        "sourceDir": "data",
        "sourceName": "cases.csv",
        "sourceBranch": "web-data",
        "downloadName": "/tmp/data/Latest.csv",
        "transform": False
    }
]
