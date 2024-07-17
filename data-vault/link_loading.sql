INSERT INTO l_aircraft_seat (hk_aircraft, hk_seat, load_date_ts)
SELECT
    aircraft_code,
    seat_no,
    CURRENT_TIMESTAMP
FROM public.seats;
