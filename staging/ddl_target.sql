DROP TABLE IF EXISTS public.aircrafts_data;

CREATE TABLE IF NOT EXISTS public.aircrafts_data(
    aircraft_code VARCHAR(10),
    model         VARCHAR(50),
    range         INT,
    load_date     DATE DEFAULT CURRENT_DATE
) DISTRIBUTED BY (aircraft_code)
    PARTITION BY RANGE (load_date)
        (START ('2024-01-01') END ('2025-01-01') EVERY (INTERVAL '1 day'));


DROP TABLE IF EXISTS public.seats;

CREATE TABLE IF NOT EXISTS public.seats(
    seat_no       VARCHAR(5),
    aircraft_code VARCHAR(10),
    load_date     DATE DEFAULT CURRENT_DATE
) DISTRIBUTED BY (aircraft_code)
    PARTITION BY RANGE (load_date)
        (START ('2024-01-01') END ('2025-01-01') EVERY (INTERVAL '1 day'));

INSERT INTO public.aircrafts_data (aircraft_code, model, range)
VALUES ('A320', 'Airbus A320', 6100);

SELECT *
FROM public.aircrafts_data;

INSERT INTO public.seats (seat_no, aircraft_code)
VALUES ('1A', 'A320');

SELECT *
FROM public.seats;