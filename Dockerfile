FROM debian:jessie-slim
MAINTAINER Tobias Janke <tobias.janke@outlook.com>
RUN apt-get update -qq
RUN apt-get install -y -qq gcc make
