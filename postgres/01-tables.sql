\c :covid_db;

CREATE TABLE raw_confirmed (
    region TEXT,
    country TEXT,
    lat DECIMAL,
    lon DECIMAL,
    date DATE,
    value INT
);

CREATE TABLE raw_death (
    region TEXT,
    country TEXT,
    lat DECIMAL,
    lon DECIMAL,
    date DATE,
    value INT
);

CREATE TABLE raw_recovered (
    region TEXT,
    country TEXT,
    lat DECIMAL,
    lon DECIMAL,
    date DATE,
    value INT
);

CREATE TABLE raw_latest (	
    Province_State TEXT,	
    Country_Region TEXT NOT NULL,	
    Last_Update TIMESTAMP,	
    Lat	DECIMAL,
    Long_ DECIMAL,
    Confirmed INT,	
    Deaths INT,	
    Recovered INT,	
    Active INT,	
    FIPS INT,	
    Admin2 TEXT,
    Combined_Key TEXT NOT NULL,
    Incident_Rate DECIMAL,
    People_Tested INT,
    People_Hospitalized Int,
    UID INT,
    ISO3 TEXT
);

CREATE TABLE raw_countries (
    Name TEXT,
    Code TEXT
);

CREATE TABLE ammend_countries (
    Name TEXT,
    Code TEXT
);

CREATE TABLE raw_nhs_history(
    date DATE,
    sector_type TEXT,
    sector_key TEXT,
    sector_name TEXT,
    new_confirmed INT,
    total_confirmed INT,
    new_deaths INT,
    total_deaths INT
);

CREATE TABLE raw_nhs_latest(
    date TIMESTAMP,
    sector_type TEXT,
    sector_key TEXT,
    sector_name TEXT,
    cases INT,
    deaths INT,
    new_cases INT
);
