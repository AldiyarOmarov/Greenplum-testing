#!/bin/bash

set -e

## Bootstrap => Create database & config if hostlist_singlenode does not exist:
su - gpadmin bash -c '\
    [ -f /data/hostlist_singlenode ] && (source /usr/local/gpdb/greenplum_path.sh && gpstart -a) || \
    cd /data/ && \
    echo "starting sshd ..." && \
    sudo /etc/init.d/ssh start && \
    sleep 2 && \
    ssh -o StrictHostKeyChecking=no localhost ls && \
    source /home/gpadmin/.bash_profile && \
    echo greenplum > /data/hostlist_singlenode && \
    sed -i "s/hostname_of_machine/localhost/g" /data/gpinitsystem_singlenode && \
    echo "gpssh-exkeys ..." && \
    gpssh-exkeys -f /data/hostlist_singlenode && \
    echo "gpinitsystem ..." && \
    gpinitsystem --ignore-warnings -ac gpinitsystem_singlenode && \
    /usr/local/pxf-gp6/bin/pxf start && \
    /usr/local/pxf-gp6/bin/pxf register && \
    echo "host all all 0.0.0.0/0 md5" >> /data/master/gpsne-1/pg_hba.conf && \
    psql -d postgres -c "\
              ALTER DATABASE postgres SET OPTIMIZER = OFF; \
              SELECT pg_reload_conf(); \
              CREATE EXTENSION pxf ; \
              SELECT extname FROM pg_extension; \
              ALTER DATABASE postgres SET OPTIMIZER = ON; \
              " && \
    sleep 3 && \
    psql -d postgres -c "alter role gpadmin with password \$\$your_password\$\$ ;" 
    '

trap "kill %1; su - gpadmin bash -c 'gpstop -a -M fast' && END=1" INT TERM

tail -f `ls /data/master/gpsne-1/pg_log/gpdb-* | tail -n1` &

#trap
while [ "$END" == '' ]; do
  sleep 1
done