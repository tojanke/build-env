FROM debian:buster-slim
MAINTAINER Tobias Janke <tobias.janke@outlook.com>
RUN (apt-get update -qq > apt.log) || (cat apt.log && false)
RUN (apt-get install -y -qq g++ g++-8 make wget > apt.log) || (cat apt.log && false)
ENV CC /usr/bin/gcc-8
ENV CXX /usr/bin/g++-8
RUN cd /usr/local/src \ 
    	&& wget -q https://cmake.org/files/v3.13/cmake-3.13.0.tar.gz \
    	&& tar xf cmake-3.13.0.tar.gz \ 
    	&& cd cmake-3.13.0 \
    	&& (./bootstrap 1>cmake.log || (cat cmake.log && false)) \
    	&& (make 1>cmake.log || (cat cmake.log && false)) \
    	&& (make install 1>cmake.log || (cat cmake.log && false)) \
	&& cd .. \
	&& rm -rf cmake*
RUN wget -q https://sourceforge.net/projects/boost/files/boost/1.69.0/boost_1_69_0.tar.gz/download \	
	&& tar xf download \
	&& rm download \
	&& mv boost_1_69_0 boost \
	&& cd boost \
	&& (./bootstrap.sh 1>boost.log || (cat boost.log && false)) \
	&& (./b2 -j8 --build-type=complete --layout=versioned stage \
	--with-timer --with-date_time --with-random --with-test --with-regex 1>boost.log || (cat boost.log && false)) \
	&& cd .. && rm -R /boost/libs && rm -R /boost/bin.v2
RUN apt-get install -y -qq mingw-w64 wine
RUN apt-get install -y -qq mono-devel nuget
RUN apt-get clean \
    	&& rm -rf /var/lib/apt/lists/*
