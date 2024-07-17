docker compose run -ti greenplum_its sh -c 'PGPASSWORD="your_password" psql -h greenplum -U gpadmin -d postgres'

DROP EXTERNAL TABLE IF EXISTS source_external_table;
CREATE READABLE EXTERNAL TABLE source_external_table (client_name text , vip_priority int, dry_weight int) LOCATION ('pxf://metamodel-dev-terraform-object-storage/pxf_s3?PROFILE=s3:csv&SERVER=s3') FORMAT 'CSV';

DROP TABLE IF EXISTS stage_table;
CREATE TABLE stage_table (client_name text , vip_priority int, dry_weight int) DISTRIBUTED BY (client_name);

DROP TABLE IF EXISTS hub_client;
CREATE TABLE hub_client (client_name TEXT NOT NULL, load_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, record_source TEXT NOT NULL) DISTRIBUTED BY (client_name);


INSERT INTO hub_client (client_name, record_source) SELECT DISTINCT client_name, 'stage_table' FROM pxf_s3_read_target;


