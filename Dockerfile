FROM java

ENV MIRTH_CONNECT_VERSION 3.6.0.b2287

# Mirth Connect is run with user `connect`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN useradd -u 1000 mirth

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

VOLUME /opt/mirth-connect/appdata

RUN \
  cd /tmp && \
  wget http://downloads.mirthcorp.com/connect/$MIRTH_CONNECT_VERSION/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  tar xvzf mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  rm -f mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  mv Mirth\ Connect/* /opt/mirth-connect/ && \
  chown -R mirth /opt/mirth-connect
  
  
RUN mkdir /opt/mirth-connect/custom-lib3
RUN chown -R mirth /opt/mirth-connect/custom-lib3



COPY mirth.properties /tmp
COPY extension.properties /tmp
COPY fhir.tar.gz /tmp
COPY net.sourceforge.lpg.lpgjavaruntime_1.1.0.v200803061910.jar /tmp
COPY org.eclipse.emf.common_2.5.0.v200906151043.jar /tmp
COPY org.eclipse.emf.ecore.xmi_2.5.0.v200906151043.jar /tmp
COPY org.eclipse.emf.ecore_2.5.0.v200906151043.jar /tmp
COPY org.eclipse.ocl.ecore_1.3.0.v200905271400.jar /tmp
COPY org.eclipse.ocl_1.3.0.v200905271400.jar /tmp
COPY org.openhealthtools.mdht.emf.runtime_1.0.0.201212201425.jar /tmp
COPY org.openhealthtools.mdht.uml.cda_1.2.0.201212201425.jar /tmp
COPY org.openhealthtools.mdht.uml.hl7.datatypes_1.2.0.201212201425.jar /tmp
COPY org.openhealthtools.mdht.uml.hl7.rim_1.2.0.201212201425.jar /tmp
COPY org.openhealthtools.mdht.uml.hl7.vocab_1.2.0.201212201425.jar /tmp
COPY azure-documentdb-1.16.2-sources.jar /tmp





RUN \
 cp -af /tmp/net.sourceforge.lpg.lpgjavaruntime_1.1.0.v200803061910.jar /opt/mirth-connect/custom-lib/ && \
 cp -af /tmp/org.eclipse.emf.common_2.5.0.v200906151043.jar /opt/mirth-connect/custom-lib/ && \
 cp -af /tmp/org.eclipse.emf.ecore.xmi_2.5.0.v200906151043.jar /opt/mirth-connect/custom-lib/ && \
 cp -af /tmp/org.eclipse.emf.ecore_2.5.0.v200906151043.jar /opt/mirth-connect/custom-lib/ && \
 cp -af /tmp/org.eclipse.ocl.ecore_1.3.0.v200905271400.jar /opt/mirth-connect/custom-lib/ && \
 cp -af /tmp/org.eclipse.ocl_1.3.0.v200905271400.jar /opt/mirth-connect/custom-lib/ && \
 cp -af /tmp/org.openhealthtools.mdht.emf.runtime_1.0.0.201212201425.jar /opt/mirth-connect/custom-lib/ && \
 cp -af /tmp/azure-documentdb-1.16.2-sources.jar /opt/mirth-connect/custom-lib/ && \
 cp -af /tmp/org.openhealthtools.mdht.uml.cda_1.2.0.201212201425.jar /opt/mirth-connect/custom-lib/ && \
 cp -af /tmp/org.openhealthtools.mdht.uml.hl7.datatypes_1.2.0.201212201425.jar /opt/mirth-connect/custom-lib/ && \
 cp -af /tmp/org.openhealthtools.mdht.uml.hl7.rim_1.2.0.201212201425.jar /opt/mirth-connect/custom-lib/ && \
 cp -af /tmp/org.openhealthtools.mdht.uml.hl7.vocab_1.2.0.201212201425.jar /opt/mirth-connect/custom-lib/  && \
 cp -af /tmp/mirth.properties /opt/mirth-connect/conf/ && \
 cp -af /tmp/extension.properties /opt/mirth-connect/appdata/ && \
 cp -af /tmp/fhir.tar.gz /opt/mirth-connect/extensions/ && \
 cd /opt/mirth-connect/extensions/ && \
 tar -xzvf fhir.tar.gz && \
 rm -f fhir.tar.gz


WORKDIR /opt/mirth-connect

# set spool volume for messages exchange with Docker host ----

RUN mkdir /var/spool/mirth
RUN chown -R mirth /var/spool/mirth
VOLUME /var/spool/mirth

EXPOSE 8088 8443 8042 8092 7011 7012 7013 5000

COPY docker-entrypoint.sh /

RUN chmod a+x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["java", "-jar", "mirth-server-launcher.jar"]
