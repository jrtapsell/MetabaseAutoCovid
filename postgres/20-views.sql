\c :covid_db;

CREATE TABLE i100_countries as (
    select min(date) as date, country from raw_confirmed where value >= 100 group by country 
);
COMMENT ON TABLE i100_countries is 'The dates when each country reaches 100 reported infections';

CREATE TABLE countries_confirmed as (
    with data as (
        select 
            _now.country, _now.date, sum(_now.value) as today, sum(_before.value) as yesterday
        from raw_confirmed as _now 
        left join raw_confirmed as _before 
        on (
                (_before.region is null and _now.region is null) or 
                (_now.region = _before.region)
        ) and (_before.country = _now.country) and (_now.date = _before.date + 1)
        group by _now.country, _now.date
    )

    select data.*, data.date - i100_countries.date as i100_date from data left join i100_countries on data.country = i100_countries.country
);

CREATE TABLE countries_death as (
    with data as (
        select 
            _now.country, _now.date, sum(_now.value) as today, sum(_before.value) as yesterday
        from raw_death as _now 
        left join raw_death as _before 
        on (
                (_before.region is null and _now.region is null) or 
                (_now.region = _before.region)
        ) and (_before.country = _now.country) and (_now.date = _before.date + 1)
        group by _now.country, _now.date
    )

    select data.*, data.date - i100_countries.date as i100_date from data left join i100_countries on data.country = i100_countries.country
);

CREATE TABLE countries_recovered as (
    with data as (
        select 
            _now.country, _now.date, sum(_now.value) as today, sum(_before.value) as yesterday
        from raw_recovered as _now 
        left join raw_recovered as _before 
        on (
                (_before.region is null and _now.region is null) or 
                (_now.region = _before.region)
        ) and (_before.country = _now.country) and (_now.date = _before.date + 1)
        group by _now.country, _now.date
    )

    select data.*, data.date - i100_countries.date as i100_date from data left join i100_countries on data.country = i100_countries.country
);

CREATE TABLE countries_combined as (
    select 
    countries_confirmed.country, 
    countries_confirmed.date,
    countries_confirmed.i100_date,
    countries_confirmed.today as confirmed, countries_confirmed.today - countries_confirmed.yesterday as confirmed_new,
    countries_death.today as death, countries_death.today - countries_death.yesterday as death_new,
    countries_recovered.today as recovered, countries_recovered.today - countries_recovered.yesterday as recovered_new
    from
        countries_confirmed
    left join countries_death on (countries_death.country = countries_confirmed.country) and (countries_death.date = countries_confirmed.date)
    left join countries_recovered on (countries_recovered.country = countries_confirmed.country) and (countries_recovered.date = countries_confirmed.date)
);

CREATE TABLE latest_date as (select max(date) as date from raw_confirmed);

CREATE TABLE countries_combined_now as (select countries_combined.* from countries_combined inner join latest_date on latest_date.date = countries_combined.date);

CREATE TABLE merged_countries as (select * from raw_countries union select * from ammend_countries);

CREATE TABLE all_latest as ( SELECT
    Province_State as region, 
    Country_Region as country, 
    Last_Update as updated, 
    Lat as lat, 
    Long_ as long, 
    Confirmed as confirmed, 
    Deaths as deaths, 
    Recovered as recovered, 
    Active as active
FROM raw_latest);

CREATE TABLE nhs_history_overview as (SELECT * from raw_nhs_history where sector_type = 'overview');
CREATE TABLE nhs_history_countries as (SELECT * from raw_nhs_history where sector_type = 'countries');
CREATE TABLE nhs_history_regions as (SELECT * from raw_nhs_history where sector_type = 'regions');
CREATE TABLE nhs_history_utlas as (SELECT * from raw_nhs_history where sector_type = 'utlas');

CREATE TABLE nhs_latest_overview as (SELECT * from raw_nhs_latest where sector_type = 'overview');
CREATE TABLE nhs_latest_countries as (SELECT * from raw_nhs_latest where sector_type = 'countries');
CREATE TABLE nhs_latest_regions as (SELECT * from raw_nhs_latest where sector_type = 'regions');
CREATE TABLE nhs_latest_utlas as (SELECT * from raw_nhs_latest where sector_type = 'utlas');