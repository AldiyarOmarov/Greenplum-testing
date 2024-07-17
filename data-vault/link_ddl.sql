DROP TABLE IF EXISTS l_aircraft_seat;
CREATE TABLE IF NOT EXISTS l_aircraft_seat(
    hk_aircraft  VARCHAR(10) NOT NULL,
    hk_seat      VARCHAR(5) NOT NULL,
    load_date_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (hk_aircraft, hk_seat);
