CREATE EXTERNAL TABLE source.ext_aircrafts_data (
    aircraft_code VARCHAR(10),
    model VARCHAR(50),
    range INT
)
LOCATION ('gpfdist://host:port/path/to/aircrafts_data/*.csv')
FORMAT 'CSV' (DELIMITER ',' NULL '');


CREATE
EXTERNAL TABLE source.ext_seats (
    seat_no VARCHAR(5),
    aircraft_code VARCHAR(10)
)
LOCATION ('gpfdist://host:port/path/to/seats/*.csv')
FORMAT 'CSV' (DELIMITER ',' NULL '');
