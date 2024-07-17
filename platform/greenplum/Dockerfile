# https://github.com/andruche/docker-greenplum/blob/master/6/DockerFile
# FROM andruche/greenplum:7.0.0-b2
# FROM andruche/greenplum:6.24.1


FROM ubuntu:22.04 AS builder

SHELL ["/bin/bash", "-c"]
RUN echo 'alias ll="ls -l"' >> /root/.bashrc
RUN echo 'export PS1="\[\033[1;36m\][\u@\h \W]\[\033[0;31m\]$\[\033[0;37m\] "' >> /root/.bashrc

#from https://github.com/greenplum-db/gpdb/blob/6.25.1/README.ubuntu.bash:
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && apt-get update \
    && apt-get -y install \
        bison ccache cmake curl flex git-core gcc g++ inetutils-ping libapr1-dev libbz2-dev \
        libcurl4-gnutls-dev libevent-dev libkrb5-dev libpam-dev libperl-dev libreadline-dev \
        libssl-dev libxml2-dev libyaml-dev libzstd-dev locales net-tools ninja-build \
        openssh-client openssh-server openssl zlib1g-dev \
        vim wget mc sudo iproute2 \
        python2.7 python2.7-dev zip locales \
    && export DEBIAN_FRONTEND=noninteractive && apt-get install -y krb5-kdc krb5-admin-server 

RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output /tmp/get-pip.py && python2.7 /tmp/get-pip.py
RUN pip2.7 install conan psutil
RUN ln -s /usr/bin/python2.7 /usr/bin/python

WORKDIR /opt/

# https://github.com/greenplum-db/gp-xerces
RUN --mount=target=/opt/cache,type=cache,sharing=locked \
    cd /opt/cache && \
    wget https://github.com/greenplum-db/gp-xerces/archive/refs/tags/v3.1.2-p1.tar.gz && \
    gzip -dc v3.1.2-p1.tar.gz | (cd /opt && tar -xvf - )

WORKDIR /opt/gp-xerces-3.1.2-p1    
RUN mkdir build &&  cd build && ../configure --prefix=/usr/local && make && make install

RUN --mount=target=/opt/cache,type=cache,sharing=locked \
    cd /opt/cache && \
    [ -f 6.25.1.zip ] || wget https://github.com/greenplum-db/gpdb/archive/refs/tags/6.25.1.zip && \
    unzip 6.25.1.zip -d /opt/

WORKDIR /opt/gpdb-6.25.1
RUN echo "6.25.1 build dev" > ./VERSION
# RUN ./configure --disable-orca --with-libxml  --prefix=/opt/greenplum-db-6

# Add GPORCA, perl and python
RUN ./configure --with-perl --with-python --with-libxml --prefix=/opt/greenplum-db-6
RUN make -j 4
RUN make install


# Install the PXF server without running unit tests.
# PXF Version release-6.7.0
# https://github.com/greenplum-db/pxf/tree/main
# https://docs.vmware.com/en/VMware-Greenplum-Platform-Extension-Framework/6.6/greenplum-platform-extension-framework/index.html
# https://docs.vmware.com/en/VMware-Greenplum-Platform-Extension-Framework/6.7/greenplum-platform-extension-framework/cfg_server.html
#  

RUN wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
RUN curl -s "https://get.sdkman.io" | bash && source "/root/.sdkman/bin/sdkman-init.sh" && sdk install java 11.0.20-zulu
RUN --mount=target=/opt/cache,type=cache,sharing=locked \
    cd /opt/cache && \
    [ -f release-6.7.0.tar.gz ] || wget https://github.com/greenplum-db/pxf/archive/refs/tags/release-6.7.0.tar.gz && \
    gzip -dc release-6.7.0.tar.gz | (cd /opt && tar -xvf - )

WORKDIR /opt/pxf-release-6.7.0
RUN source "/root/.sdkman/bin/sdkman-init.sh" && sdk use java 11.0.20-zulu && \
    locale-gen en_US.UTF-8 && \
    LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 GPHOME=/opt/greenplum-db-6 PXF_HOME=/usr/local/pxf-gp6 \
    PATH=/usr/bin:/usr/local/go/bin:/opt/greenplum-db-6/bin make deb
    # LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 GPHOME=/opt/greenplum-db-6 PXF_HOME=/usr/local/pxf-gp6 PATH=/usr/bin:/usr/local/go/bin:/opt/greenplum-db-6/bin make -sj4 && \
    # LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 GPHOME=/opt/greenplum-db-6 PXF_HOME=/usr/local/pxf-gp6 PATH=/usr/bin:/usr/local/go/bin:/opt/greenplum-db-6/bin make -sj4 install && \

    # GPHOME=/opt/greenplum-db-6 PXF_HOME=/usr/local/pxf-gp6 PATH=/usr/bin:/usr/local/bin:/opt/greenplum-db-6/bin make -sj4 install-server 

# -----------------------------------------------------------------------------


FROM ubuntu:22.04 AS slim

SHELL ["/bin/bash", "-c"]
RUN echo 'alias ll="ls -l"' >> /root/.bashrc
RUN echo 'export PS1="\[\033[1;36m\][\u@\h \W]\[\033[0;31m\]$\[\033[0;37m\] "' >> /root/.bashrc

RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && \
    apt-get -y install \
      make python2.7 openssh-client openssh-server openssl sudo iproute2 \
      net-tools less inetutils-ping locales libcurl3-gnutls curl unzip zip tzdata

WORKDIR /opt/
RUN ln -s /usr/bin/python2.7 /usr/bin/python
COPY --from=builder /usr/local/lib/python2.7/dist-packages/psutil /usr/local/lib/python2.7/dist-packages/psutil

#build locale en_US.UTF-8
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

# RUN --mount=from=builder,type=bind,source=/opt/gp-xerces-3.1.2-p1,target=/opt/gp-xerces-3.1.2-p1,readwrite \
#    cd /opt/gp-xerces-3.1.2-p1 && cd build && make install

#RUN ldd  /opt/greenplum-db-6/lib/libxerces-c-3.1.so > ldd_out && cat ldd_out && echo '!!! libxerces-c-3.1.so !!!'

RUN --mount=from=builder,type=bind,source=/opt/gpdb-6.25.1,target=/opt/gpdb-6.25.1,readwrite \
    cd /opt/gpdb-6.25.1 && make install

COPY --from=builder /usr/local/lib/libxerces-c-3.1.so /opt/greenplum-db-6/lib/libxerces-c-3.1.so
# COPY --from=builder /usr/local/pxf-gp6 /usr/local/pxf-gp6

### pxf .deb
COPY --from=builder /opt/pxf-release-6.7.0/build/pxf-gp6-6.7.0-1-ubuntu18.04-amd64.deb  /opt/pxf-gp6-6.7.0-1-ubuntu18.04-amd64.deb
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    apt-get -y install /opt/pxf-gp6-6.7.0-1-ubuntu18.04-amd64.deb

# #from https://github.com/DataGrip/docker-env/blob/master/greenplum/6.8/Dockerfile:
RUN mkdir /data \
 && mkdir /data/data1 \
 && mkdir /data/data2 \
 && mkdir /data/master \
 && source /opt/greenplum-db-6/greenplum_path.sh \
 && cp $GPHOME/docs/cli_help/gpconfigs/gpinitsystem_singlenode /data/ \
 && sed -i 's/gpdata1/data\/data1/g' /data/gpinitsystem_singlenode \
 && sed -i 's/gpdata2/data\/data2/g' /data/gpinitsystem_singlenode \
 && sed -i 's/gpmaster/data\/master/g' /data/gpinitsystem_singlenode

# Create gpadmin user and add the user to the sudoers
RUN useradd -md /home/gpadmin/ --shell /bin/bash gpadmin \
 && chown gpadmin -R /data \
 && echo "source /opt/greenplum-db-6/greenplum_path.sh" > /home/gpadmin/.bash_profile \
 && echo 'export PS1="\[\033[1;35m\][\u@\h \W]\[\033[0;31m\]$\[\033[0;37m\] "'  >> /home/gpadmin/.bash_profile \
 && echo 'export MASTER_DATA_DIRECTORY="/data/master/gpsne-1/"'  >> /home/gpadmin/.bash_profile \
 && echo 'alias ll="ls -l"'  >> /home/gpadmin/.bash_profile \
 && chown gpadmin:gpadmin /home/gpadmin/.bash_profile \
 && su - gpadmin bash -c 'mkdir /home/gpadmin/.ssh' \
 && echo "gpadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
 && echo "root ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir /run/sshd
RUN echo "set hlsearch" >> /home/gpadmin/.vimrc

# from https://github.com/greenplum-db/gpdb/blob/6.21.1/src/tools/docker/ubuntu16_ppa/install_and_start_gpdb.sh:
RUN su - gpadmin bash -c '\
    ssh-keygen -f /home/gpadmin/.ssh/id_rsa -t rsa -N "" && \
    cp /home/gpadmin/.ssh/id_rsa.pub /home/gpadmin/.ssh/authorized_keys && \
    chmod 600 /home/gpadmin/.ssh/authorized_keys'

# workaround to set host=localhost for master node
RUN echo "def gethostname(): return 'greenplum'" >> /usr/lib/python2.7/socket.py
RUN mv /usr/bin/hostname{,.bkp} && \
  echo "echo greenplum" > /usr/bin/hostname && \
  chmod +x /usr/bin/hostname && \
  echo 'greenplum' > /etc/hostname

RUN mv /usr/bin/hostname{.bkp,}

### PFX integration
RUN chown -R gpadmin:gpadmin /usr/local/pxf-gp6

# COPY --from=builder /opt/greenplum-db-6 /opt/greenplum-db-6
RUN chown -R gpadmin:gpadmin /opt/greenplum-db-6
RUN mkdir -p /usr/java && ln -s /home/gpadmin//.sdkman/candidates/java/current /usr/java/default

USER gpadmin
RUN curl -s "https://get.sdkman.io" | bash && source "/home/gpadmin//.sdkman/bin/sdkman-init.sh" && \
    sdk install java 11.0.20-zulu  && sdk use java 11.0.20-zulu && \     
    echo 'cp -rp /usr/local/pxf-gp6/templates/*-site.xml /usr/local/pxf-gp6/servers/default' 

RUN mkdir /usr/local/pxf-gp6/servers/{minio,s3,pgsrvcfg}    
COPY s3-site.xml  /usr/local/pxf-gp6/servers/s3/s3-site.xml
# https://greenplum.org/using-greenplum-to-access-minio/
COPY minio-site.xml  /usr/local/pxf-gp6/servers/minio/minio-site.xml
# https://docs.vmware.com/en/VMware-Greenplum-Platform-Extension-Framework/6.7/greenplum-platform-extension-framework/jdbc_pxf_postgresql.html
COPY jdbc-site.xml  /usr/local/pxf-gp6/servers/pgsrvcfg/jdbc-site.xml
# COPY pxf-log4j2.xml /usr/local/pxf-gp6/conf/pxf-log4j2.xml
# COPY s3_yc.conf /home/gpadmin/s3_yc.conf
# COPY s3_config.conf /home/gpadmin/s3_config.conf

# ---------------------------------

USER root
ENV TZ=Europe/Moscow
RUN ls -s /usr/share/zoneinfo/$TZ /etc/localtime  && echo $TZ > /etc/timezone 

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]