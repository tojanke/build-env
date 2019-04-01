FROM debian:jessie-slim
MAINTAINER Tobias Janke <tobias.janke@outlook.com>
RUN apt-get update -qq
RUN apt-get install -y -qq g++ make wget
RUN cd /usr/local/src \ 
    && wget https://cmake.org/files/v3.13/cmake-3.13.0.tar.gz \
    && tar xf cmake-3.13.0.tar.gz \ 
    && cd cmake-3.13.0 \
    && ./bootstrap \
    && make \
    && make install \
    && cd .. \
    && rm -rf cmake*
RUN wget https://sourceforge.net/projects/boost/files/boost/1.69.0/boost_1_69_0.tar.gz/download \	
	&& tar xf download \
	&& rm download \
	&& mv boost_1_69_0 boost \
	&& cd boost \
	&& ./bootstrap.sh \
	&& ./b2 -j 8 --build-dir=build64 --stagedir=stage complete install \
	--with-timer --with-date_time --with-random --with-test --with-regex \
	&& cd ..
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*
