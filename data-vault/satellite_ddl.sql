DROP TABLE IF EXISTS s_aircraft;
CREATE TABLE IF NOT EXISTS s_aircraft
(
    hk_aircraft  VARCHAR(10) NOT NULL,
    load_date_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    model        VARCHAR(50),
    range        INT
) DISTRIBUTED BY (hk_aircraft);

DROP TABLE IF NOT EXISTS s_seat;
CREATE TABLE IF NOT EXISTS s_seat
(
    hk_seat         VARCHAR(5) NOT NULL,
    load_date_ts    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fare_conditions VARCHAR(100)
) DISTRIBUTED BY (hk_seat);