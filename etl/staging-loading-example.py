from datetime import datetime, timedelta

from airflow import DAG
from airflow.models import Param
from datetime import datetime
from airflow.providers.postgres.operators.postgres import PostgresOperator



default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2023, 11, 7),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'staging-loading-example',
    params={
        "greenplum_ext_table": Param("ext_table", type="string"),
        "greenplum_stage_table": Param("stage_table", type="string"),
        "greenplum_hub_table": Param("h_table", type="string")
    },
    default_args=default_args,
    description='An example DAG with Staging Loading Example',
    schedule_interval='@hourly',
    catchup=False
)

with dag:


    insert_data_stage_sql = """
        INSERT INTO {{ params.greenplum_stage_table }} SELECT * FROM {{ params.greenplum_ext_table }};
        SELECT count(*) FROM {{ params.greenplum_stage_table }};
        """

    insert_data_ods_sql = """
        INSERT INTO {{ params.greenplum_hub_table }} (client_name, record_source) SELECT DISTINCT client_name, 'stage_table' FROM {{ params.greenplum_stage_table }};
        SELECT count(*) FROM {{ params.greenplum_hub_table }};
        """

    loading_stage_layer = PostgresOperator(
        task_id='loading_stage_layer',
        postgres_conn_id='your_greenplum_connection_id',
        sql=insert_data_stage_sql,
        dag=dag,
    )

    loading_ods_layer = PostgresOperator(
        task_id='loading_ods_layer',
        postgres_conn_id='your_greenplum_connection_id',
        sql=insert_data_ods_sql,
        dag=dag,
    )

loading_stage_layer >> loading_ods_layer