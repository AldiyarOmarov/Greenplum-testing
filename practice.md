# Лабораторная работа: Построение Data Warehouse с использованием Data Vault

Эта лабораторная работа проведет вас через все шаги, необходимые для построения Data Vault, основываясь на предоставленной схеме. Мы будем использовать Greenplum как базу данных и MinIO для хранения CSV-файлов. Шаги включают создание внешних таблиц для CSV-файлов, staging таблиц и Data Vault структур (Hub, Link, Satellite таблицы). В конце мы настроим DAG в Airflow для оркестрации процесса загрузки данных.

## Пререквизиты
- Доступ к базе данных Greenplum
- Настроенный MinIO для хранения CSV-файлов
- Настроенный Airflow для оркестрации ETL процесса
- Вы можете использовать приложенный docker-compose.yml файл для запуска Greenplum, MinIO и Airflow
- Либо свою рабочую среду с Greenplum, MinIO и Airflow
- Либо сервисы на Яндекс Облаке
- Предварительно загрузив csv файлы в MinIO как это показано в видео
- Схемы опубликованы в презентации на слайдах 13, 14


## Шаги

### 1. Создание внешних таблиц в Greenplum для CSV-файлов в MinIO

Создайте внешние таблицы в Greenplum, которые будут ссылаться на CSV-файлы, хранящиеся в MinIO. Напишите необходимые SQL-запросы для этой задачи. В соответствии с приложенной схемой. Попробуйте запустить этот скрипт в Greenplum.

### 2. Создание внутренних таблиц в Greenplum для Staging слоя

Создайте внутренние staging таблицы в Greenplum, которые будут зеркально отражать структуру внешних таблиц. Напишите необходимые SQL-запросы. Схема staging таблиц должна быть такой же, как и схема внешних таблиц. Попробуйте запустить этот скрипт в Greenplum.

### 3. Создание внутренних таблиц в Greenplum для Data Vault (Hub, Link, Satellite)

Создайте структуры Data Vault, по приложенной схеме. Напишите необходимые SQL-запросы. Попробуйте запустить этот скрипт в Greenplum.

### 4. Создание SQL скрипта для загрузки данных из внешних таблиц в Staging слой

Напишите SQL скрипт для загрузки данных из внешних таблиц в staging таблицы. Попробуйте запустить этот скрипт в Greenplum.

### 5. Создание SQL скрипта для загрузки данных из Staging слоя в ODS слой

Напишите SQL скрипт для загрузки данных из staging таблиц в ODS слой, заполняя Hub, Link и Satellite таблицы. Попробуйте запустить этот скрипт в Greenplum.

### 6. Создание DAG в Airflow

Создайте DAG в Airflow, который включает задачи по загрузке данных из внешней таблицы в staging слой и из staging слоя в ODS слой. Напишите необходимый код на Python и SQL для этой задачи. Загрузите DAG в папку dags в MinIO как на видео. Попробуйте запустить DAG в Airflow.

Пример структуры создания DAG в Airflow:

```python
from airflow import DAG
from airflow.operators.postgres_operator import PostgresOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
}

dag = DAG(
    'data_vault_etl',
    default_args=default_args,
    description='ETL DAG для загрузки данных из внешних источников в staging и ODS слои',
    schedule_interval='@daily',
)

load_external_to_stage = PostgresOperator(
    task_id='load_external_to_stage',
    postgres_conn_id='greenplum_conn',
    sql='WRITE_YOUR_SQL_HERE',
    dag=dag,
)

load_stage_to_ods = PostgresOperator(
    task_id='load_stage_to_ods',
    postgres_conn_id='greenplum_conn',
    sql='WRITE_YOUR_SQL_HERE',
    dag=dag,
)

load_external_to_stage >> load_stage_to_ods



