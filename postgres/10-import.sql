\c :covid_db;

COPY raw_confirmed(region,country,lat,lon,date,value) FROM '/tmp/transformed/Confirmed.csv' DELIMITER ',' CSV HEADER;
COPY raw_death(region,country,lat,lon,date,value) FROM '/tmp/transformed/Deaths.csv' DELIMITER ',' CSV HEADER;
COPY raw_recovered(region,country,lat,lon,date,value) FROM '/tmp/transformed/Recovered.csv' DELIMITER ',' CSV HEADER;
COPY raw_latest(Province_State, Country_Region, Last_Update, Lat, Long_, Confirmed, Deaths, Recovered, Active, Admin2, FIPS, Combined_Key,Incident_Rate,People_Tested,People_Hospitalized,UID,ISO3) FROM '/tmp/data/Latest.csv' DELIMITER ',' CSV HEADER;
COPY raw_countries(Name, Code) FROM '/tmp/data/countries.csv' DELIMITER ',' CSV HEADER;
COPY ammend_countries(Name, Code) FROM '/app/countries_ammendments.csv' DELIMITER ',' CSV HEADER;

COPY raw_nhs_contries(Area_Code,Area_Name,Date,Value) FROM '/tmp/nhs/countries.csv' DELIMITER ',' CSV HEADER;
COPY raw_nhs_regions(Area_Code,Area_Name,Date,Value) FROM '/tmp/nhs/NHS Regions.csv' DELIMITER ',' CSV HEADER;
COPY raw_nhs_recovered(Date,Cumulative_Counts) FROM '/tmp/nhs/Recovered patients.csv' DELIMITER ',' CSV HEADER;
COPY raw_nhs_cases (Date,Cases,Cumulative_Cases) FROM '/tmp/nhs/UK Cases.csv' DELIMITER ',' CSV HEADER;
COPY raw_nhs_deaths (Date,Region,Deaths) FROM '/tmp/nhs/UK Deaths.csv' DELIMITER ',' CSV HEADER;
COPY raw_nhs_utla(Area_Code,Area_Name,Date,Value) FROM '/tmp/nhs/UTLAs.csv' DELIMITER ',' CSV HEADER;