INSERT INTO h_aircraft (hk_aircraft, aircraft_code, load_date_ts)
SELECT DISTINCT
    aircraft_code,
    aircraft_code,
    CURRENT_TIMESTAMP
FROM public.aircrafts_data;

INSERT INTO h_seat (hk_seat, aircraft_code, seat_no, load_date_ts)
SELECT DISTINCT
    seat_no,
    aircraft_code,
    seat_no,
    CURRENT_TIMESTAMP
FROM public.seats;
