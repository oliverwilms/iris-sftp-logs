ARG IMAGE=intersystemsdc/iris-community:2020.3.0.221.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.4.0.524.0-zpm
ARG IMAGE=intersystems/irishealth:2020.1.0.215.0.20264
ARG IMAGE=intersystems/irishealth:2020.1.0.215.0
FROM $IMAGE

USER root
WORKDIR /opt/sftplog
RUN mkdir /ghostdb/ && mkdir /voldata/ && mkdir /voldata/irisdb/ && mkdir /voldata/icsp/ && mkdir /voldata/icsp/sftplog/
COPY csp /voldata/icsp/sftplog
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/sftplog /ghostdb/ /voldata/ /voldata/irisdb/ /voldata/icsp/ /voldata/icsp/sftplog/ /voldata/icsp/sftplog/sftplog.csp
RUN chmod 775 /voldata/icsp/sftplog/ /voldata/icsp/sftplog/sftplog.csp

USER ${ISC_PACKAGE_MGRUSER}

COPY src src
COPY module.xml module.xml
COPY iris.script /tmp/iris.script

RUN iris start IRIS \
    && iris session IRIS < /tmp/iris.script \
    && iris stop IRIS quietly

HEALTHCHECK --interval=10s --timeout=3s --retries=2 CMD wget localhost:52773/csp/user/cache_status.cxw || exit 1

USER root
COPY vcopy.sh vcopy.sh
RUN rm -f $ISC_PACKAGE_INSTALLDIR/mgr/alerts.log $ISC_PACKAGE_INSTALLDIR/mgr/IRIS.WIJ $ISC_PACKAGE_INSTALLDIR/mgr/journal/* && cp -Rpf /voldata/* /ghostdb/ && rm -fr /voldata/* \
  && rm -f /tmp/iris.script && chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/sftplog/vcopy.sh && chmod +x /opt/sftplog/vcopy.sh
