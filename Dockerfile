FROM debian:jessie-slim
MAINTAINER Tobias Janke <tobias.janke@outlook.com>
RUN apt-get update -qq
RUN apt-get install -y -qq gcc
RUN cd /usr/local/src \ 
    && wget https://cmake.org/files/v3.13/cmake-3.13.0.tar.gz \
    && tar xvf cmake-3.13.0.tar.gz \ 
    && cd cmake-3.13.0 \
    && ./bootstrap \
    && make \
    && make install \
    && cd .. \
    && rm -rf cmake*
