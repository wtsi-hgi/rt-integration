# 
# RT Integration Dockerfile
#
# https://github.com/wtsi-hgi/rt-integration

FROM ubuntu:14.04
MAINTAINER "Joshua C. Randall" <jcrandall@alum.mit.edu>

# Prerequisites
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y librt-client-rest-perl libappconfig-perl

# Install
ADD . /docker

WORKDIR /docker
