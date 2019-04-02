FROM debian:jessie-slim
MAINTAINER Tobias Janke <tobias.janke@outlook.com>
RUN apt-get update -qq
RUN apt-get install -y -qq g++ make wget
RUN cd /usr/local/src \ 
    	&& wget -q https://cmake.org/files/v3.13/cmake-3.13.0.tar.gz \
    	&& tar xf cmake-3.13.0.tar.gz \ 
    	&& cd cmake-3.13.0 \
    	&& ./bootstrap 1>/dev/null \
    	&& make 1>/dev/null  \
    	&& make install 1>/dev/null \
	&& cd .. \
	&& rm -rf cmake*
RUN wget -q https://sourceforge.net/projects/boost/files/boost/1.69.0/boost_1_69_0.tar.gz/download \	
	&& tar xf download \
	&& rm download \
	&& mv boost_1_69_0 boost \
	&& cd boost \
	&& ./bootstrap.sh \
	&& ./b2 -j8 --build-type=complete --layout=versioned stage \
	--with-timer --with-date_time --with-random --with-test --with-regex \
	&& cd ..
RUN apt-get clean \
    	&& rm -rf /var/lib/apt/lists/*
