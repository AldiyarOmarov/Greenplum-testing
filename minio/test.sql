DROP EXTERNAL TABLE IF EXISTS pxf_s3_read;

CREATE READABLE EXTERNAL TABLE pxf_s3_read (client_name text , vip_priority int, dry_weight int) LOCATION ('pxf://metamodel-dev-terraform-object-storage/pxf_s3?PROFILE=s3:csv&SERVER=s3') FORMAT 'CSV';

SELECT * FROM pxf_s3_read;

