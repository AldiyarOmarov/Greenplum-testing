### Лабораторная работа: Исследование разбиения таблиц в Greenplum

#### Цель:
Цель этой лабораторной работы - понять и попрактиковаться в разбиении таблиц и выполнении запросов к сегментированным таблицам в Greenplum. Вы создадите сегментированную таблицу, проверите схему разбиения, изучите политики распределения и выполните запросы к конкретным разделам.

#### Этапы:

1. **Настройка сегментированной таблицы:**
    - **Шаг 1.1:** Удалите существующую таблицу `orders_partitioned`, если она существует. Этот шаг гарантирует, что вы сможете создать новую таблицу без ошибок из-за уже существующей таблицы.
    - **Шаг 1.2:** Создайте новую таблицу с именем `orders_partitioned` с полями для `order_id`, `customer_id`, `order_date`, `amount` и `region`. Настройте эту таблицу на сегментацию по `order_id`.
    - **Шаг 1.3:** Разбейте таблицу по диапазону `order_date`. Разделы должны начинаться с 1 января 2020 года и заканчиваться 1 января 2030 года, каждый раздел представляет один год.

````sql
DROP TABLE IF EXISTS orders_partitioned;

CREATE TABLE orders_partitioned (
	order_id int,
	customer_id int,
	order_date date,
	amount decimal(10,2),
	region varchar(50)
)
DISTRIBUTED BY (order_id)
PARTITION BY RANGE(order_date)
(
	START ('2020-01-01') INCLUSIVE
	END ('2030-01-01') EXCLUSIVE
	EVERY (INTERVAL '1 year')
);
````

2. **Проверка таблицы и разделов:**
    - **Шаг 2.1:** Используйте запрос SELECT для списка всех разделов таблицы `orders_partitioned`. Этот шаг подтверждает, что разделы таблицы настроены правильно.
    - **Шаг 2.2:** Проверьте выражения разделов, чтобы убедиться, что каждый раздел охватывает правильный диапазон дат.

````sql
SELECT * FROM orders_partitioned
WHERE order_date >= '2021-01-01' AND order_date < '2022-01-01';
````

3. **Проверка политики распределения:**
    - **Шаг 3.1:** Выполните запрос для определения ключа распределения таблицы `orders_partitioned`. Этот шаг важен для понимания, как данные распределяются по сегментам в Greenplum.

````sql
SELECT
    n.nspname AS schemaname,
    c.relname AS tablename,
    c2.relname AS partitionname,
    pg_catalog.pg_get_expr(c2.relpartbound, c2.oid) AS partition_expression
FROM
    pg_class c
JOIN
    pg_inherits i ON c.oid = i.inhparent
JOIN
    pg_class c2 ON i.inhrelid = c2.oid
JOIN
    pg_namespace n ON c.relnamespace = n.oid
WHERE
    c.relname = 'orders_partitioned' AND n.nspname = 'public';

````

4. **Запрос к сегментированной таблице:**
    - **Шаг 4.1:** Выполните запрос SELECT для получения данных из конкретного раздела (например, заказы за 2021 год). Этот запрос демонстрирует, как эффективно получать доступ к данным из конкретного раздела.

````sql
SELECT
    a.attname AS distribution_key
FROM
    pg_class c
JOIN
    pg_namespace n ON c.relnamespace = n.oid
JOIN
    pg_attribute a ON a.attrelid = c.oid
JOIN
    gp_distribution_policy p ON p.localoid = c.oid
WHERE
    c.relname = 'orders_partitioned' AND
    n.nspname = 'public' AND
    a.attnum = ANY(p.distkey);

````


#### Шаги самопроверки:
- **Проверка 1:** После создания таблицы убедитесь, что не было отображено сообщений об ошибках, что указывает на успешное создание и настройку разделов.
- **Проверка 2:** Проверьте, что вывод из Шага 2.1 правильно перечисляет все разделы вместе с их соответствующими диапазонами дат.
- **Проверка 3:** Убедитесь, что вывод из Шага 2.2 соответствует ожидаемым выражениям разделения на основе указанных диапазонов дат при создании таблицы.
- **Проверка 4:** Подтвердите, что вывод из Шага 3.1 показывает `order_id` в качестве ключа распределения.
- **Проверка 5:** Проверьте, что запрос на Шаге 4.1 возвращает строки, которые попадают только в указанный диапазон дат 2021 года, подтверждая правильное разбиение данных и извлечение.

По завершении этой лабораторной работы у вас должно сложиться четкое представление о том, как работает разбиение таблиц в Greenplum и как его можно использовать для эффективного управления большими наборами данных.





