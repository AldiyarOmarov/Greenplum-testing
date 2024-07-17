FROM docker.getcollate.io/openmetadata/ingestion:1.3.0
USER root
RUN sudo apt update && apt-get install git -y
USER airflow
#RUN pip install "apache-airflow[celery]==2.7.1" && pip install airflow-code-editor
RUN pip3 install --upgrade pip && pip install "apache-airflow==2.7.1" && pip install jsonschema-spec==0.2.4 airflow-code-editor || exit 0
# RUN pip install --upgrade apache-airflow --upgrade-strategy=eager # Error -> Broken plugin: [openmetadata_managed_apis.plugin] To define root models, use `pydantic.RootModel` rather than a field called '__root__'
# RUN pip install "apache-airflow[celery]==2.7.1" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.7.1/constraints-3.9.txt" 


