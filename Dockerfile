FROM openjdk:8-jdk
MAINTAINER Wentao Lu <wentao@butter.ai>

USER root

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
 && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
 && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true

RUN apt-get update \
 && apt-get install -y git \
 && apt-get install -y ant

RUN git clone github.com/butter/lucene-solr.git \
  && mv ./lucene-solr/lucene /opt/lucene \
  && mv ./lucene-solr/solr /opt/solr \
  && cd /opt/lucene \
  && ant ivy-bootstrap \
  && ant compile \
  && cd ../solr \
  && ant ivy-bootstrap \
  && ant server