\c :covid_db;

COPY raw_confirmed(region,country,lat,lon,date,value) FROM '/tmp/transformed/Confirmed.csv' DELIMITER ',' CSV HEADER;
COPY raw_death(region,country,lat,lon,date,value) FROM '/tmp/transformed/Deaths.csv' DELIMITER ',' CSV HEADER;
COPY raw_recovered(region,country,lat,lon,date,value) FROM '/tmp/transformed/Recovered.csv' DELIMITER ',' CSV HEADER;
COPY raw_latest(Province_State, Country_Region, Last_Update, Lat, Long_, Confirmed, Deaths, Recovered, Active, Admin2, FIPS, Combined_Key,Incident_Rate,People_Tested,People_Hospitalized,UID,ISO3) FROM '/tmp/data/Latest.csv' DELIMITER ',' CSV HEADER;
COPY raw_countries(Name, Code) FROM '/tmp/data/countries.csv' DELIMITER ',' CSV HEADER;
COPY ammend_countries(Name, Code) FROM '/app/countries_ammendments.csv' DELIMITER ',' CSV HEADER;

COPY raw_nhs_history(date,sector_type,sector_key,sector_name,new_confirmed,total_confirmed,new_deaths,total_deaths) FROM '/tmp/nhs/history.csv' DELIMITER ',' CSV HEADER;
COPY raw_nhs_latest(date, sector_type,sector_key,sector_name,cases,deaths,new_cases) FROM '/tmp/nhs/latest.csv' DELIMITER ',' CSV HEADER;