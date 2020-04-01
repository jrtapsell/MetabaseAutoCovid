\c covid19;

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