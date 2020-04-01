\c covid19;

COPY raw_confirmed(region,country,lat,lon,date,value) FROM '/tmp/transformed/Confirmed.csv' DELIMITER ',' CSV HEADER;
COPY raw_death(region,country,lat,lon,date,value) FROM '/tmp/transformed/Deaths.csv' DELIMITER ',' CSV HEADER;
COPY raw_recovered(region,country,lat,lon,date,value) FROM '/tmp/transformed/Recovered.csv' DELIMITER ',' CSV HEADER;