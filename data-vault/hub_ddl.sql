DROP TABLE IF EXISTS h_aircraft;
CREATE TABLE IF NOT EXISTS h_aircraft (
    hk_aircraft   VARCHAR(10) NOT NULL,
    aircraft_code VARCHAR(10),
    load_date_ts  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (hk_aircraft);

DROP TABLE IF EXISTS h_seat;
CREATE TABLE IF NOT EXISTS h_seat
(
    hk_seat       VARCHAR(5) NOT NULL,
    aircraft_code VARCHAR(10),
    seat_no       VARCHAR(5),
    load_date_ts  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) DISTRIBUTED BY (hk_seat);