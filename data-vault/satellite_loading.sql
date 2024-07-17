INSERT INTO s_aircraft (hk_aircraft, load_date_ts, model, range)
SELECT
    aircraft_code,
    CURRENT_TIMESTAMP,
    model,
    range
FROM public.aircrafts_data;

INSERT INTO s_seat (hk_seat, load_date_ts, fare_conditions)
SELECT
    seat_no,
    CURRENT_TIMESTAMP,
    'Default Fare'
FROM public.seats;
