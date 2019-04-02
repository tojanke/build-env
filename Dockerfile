FROM debian:buster-slim
MAINTAINER Tobias Janke <tobias.janke@outlook.com>
RUN apt-get update -qq
RUN apt-get install -y -qq g++-8 make wget
RUN cd /usr/local/src \ 
    	&& (wget https://cmake.org/files/v3.13/cmake-3.13.0.tar.gz > cmake.log || cat cmake.log) \
    	&& tar xf cmake-3.13.0.tar.gz \ 
    	&& cd cmake-3.13.0 \
    	&& (./bootstrap 1>cmake.log || cat cmake.log) \
    	&& (make 1>cmake.log || cat cmake.log) \
    	&& (make install 1>cmake.log || cat cmake.log) \
	&& cd .. \
	&& rm -rf cmake*
RUN (wget https://sourceforge.net/projects/boost/files/boost/1.69.0/boost_1_69_0.tar.gz/download 1>boost.log || cat boost.log)  \	
	&& tar xf download \
	&& rm download \
	&& mv boost_1_69_0 boost \
	&& cd boost \
	&& (./bootstrap.sh 1>boost.log || cat boost.log) \
	&& (./b2 -j8 --build-type=complete --layout=versioned stage \
	--with-timer --with-date_time --with-random --with-test --with-regex 1>boost.log || cat boost.log) \
	&& cd ..
RUN apt-get install -y -qq mingw-w64 wine
RUN apt-get install -y -qq mono-devel nuget
RUN apt-get clean \
    	&& rm -rf /var/lib/apt/lists/*
