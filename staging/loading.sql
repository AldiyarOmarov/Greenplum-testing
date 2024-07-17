INSERT INTO target.h_aircraft (load_date_ts, aircraft_code, model, range)
SELECT DISTINCT
    CURRENT_TIMESTAMP AS load_date_ts,
    aircraft_code,
    model,
    range
FROM source.ext_aircrafts_data
WHERE NOT EXISTS (
    SELECT 1 FROM h_aircraft WHERE h_aircraft.aircraft_code = ext_aircrafts_data.aircraft_code
    );


WITH ranked_aircrafts AS (
    SELECT
        CURRENT_TIMESTAMP AS load_date_ts,
        aircraft_code,
        model,
        range,
        ROW_NUMBER() OVER (PARTITION BY aircraft_code ORDER BY CURRENT_TIMESTAMP DESC) AS rnk
    FROM source.ext_aircrafts_data
),
new_aircrafts AS (
    SELECT
        load_date_ts,
        aircraft_code,
        model,
        range
    FROM ranked_aircrafts
    WHERE rnk = 1
)
INSERT INTO target.h_aircraft (load_date_ts, aircraft_code, model, range)
SELECT
    new_aircrafts.load_date_ts,
    new_aircrafts.aircraft_code,
    new_aircrafts.model,
    new_aircrafts.range
FROM new_aircrafts
    LEFT JOIN target.h_aircraft
ON new_aircrafts.aircraft_code = target.h_aircraft.aircraft_code
WHERE target.h_aircraft.aircraft_code IS NULL;





INSERT INTO target.l_aircraft_seat (hk_aircraft, hk_seat, load_date_ts)
SELECT DISTINCT
    (SELECT hk_aircraft FROM h_aircraft WHERE aircraft_code = ext_seats.aircraft_code) AS hk_aircraft,
    (SELECT hk_seat FROM s_seat WHERE seat_no = ext_seats.seat_no AND aircraft_code = ext_seats.aircraft_code) AS hk_seat,
    CURRENT_TIMESTAMP AS load_date_ts
FROM source.ext_seats
WHERE NOT EXISTS (
    SELECT 1 FROM l_aircraft_seat AS las
    WHERE las.hk_aircraft = (SELECT hk_aircraft FROM h_aircraft WHERE aircraft_code = ext_seats.aircraft_code)
  AND las.hk_seat = (SELECT hk_seat FROM s_seat WHERE seat_no = ext_seats.seat_no AND aircraft_code = ext_seats.aircraft_code)
    );
