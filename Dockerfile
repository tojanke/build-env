FROM debian:buster-slim
MAINTAINER Tobias Janke <tobias.janke@outlook.com>
ENV DEBIAN_FRONTEND noninteractive
ENV CC /usr/bin/gcc-8
ENV CXX /usr/bin/g++-8
RUN 	apt-get update -qq 1>>/dev/null \
	&& apt-get install -y -qq --no-install-recommends apt-utils apt-transport-https dirmngr gnupg ca-certificates 1>/dev/null
RUN	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
	&& echo "deb https://download.mono-project.com/repo/debian stable-stretch main" \
	   | tee /etc/apt/sources.list.d/mono-official-stable.list \
	&& dpkg --add-architecture i386 && apt-get update -qq 1>/dev/null \
	&& apt-get install -y -qq --no-install-recommends g++ g++-8 make libssl-dev wget unzip g++-mingw-w64-x86-64 mono-complete mono-vbnc nuget wine wine32 1>/dev/null
RUN	cd /usr/local/src \ 
    	&& wget -q https://cmake.org/files/v3.17/cmake-3.17.0.tar.gz \
	&& tar xf cmake-3.17.0.tar.gz \ 
    	&& cd cmake-3.17.0 \
	&& ./bootstrap 1>/dev/null \
 	&& make -j8 1>/dev/null \
 	&& make install 1>/dev/null \
	&& cd .. \
	&& rm -rf cmake*
RUN	wget -q https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.gz \	
	&& tar xf boost_1_72_0.tar.gz \
	&& rm boost_1_72_0.tar.gz \
	&& mv boost_1_72_0 /boost \
	&& cd /boost \
	&& echo "using gcc : 8.3 : g++-8 ;" > user-config.jam \
	&& ./bootstrap.sh \
	&& ./b2 -j8 --user-config=user-config.jam toolset=gcc-8.3 --build-type=complete --layout=versioned stage \
	   --with-timer --with-date_time --with-random --with-test --with-thread --with-regex
RUN	echo "using gcc : mingw32 : x86_64-w64-mingw32-g++ ;" > user-config.jam \
  	&& ./bootstrap.sh \
  	&& ./b2 -j8 --user-config=user-config.jam toolset=gcc-mingw32 target-os=windows --build-type=complete \
	   --layout=versioned stage --with-timer --with-date_time --with-random --with-thread --with-regex \
	&& rm -rf /boost/libs && rm -rf /boost/bin.v2 && rm -rf /boost/doc && rm -rf /boost/tools \
	&& ls /boost/stage/lib
RUN	cd /usr/local/src \
	&& wget -q https://sourceforge.net/projects/nsis/files/NSIS%203/3.05/nsis-3.05.zip/download \	
	&& unzip -qq download \
	&& rm download \
	&& mv nsis-3.05 nsis
RUN	apt-get remove --purge -y g++ \
	&& apt-get clean 1>>apt.log && rm -rf /var/lib/apt/lists/* && dpkg --get-selections
ENV BOOST_ROOT /boost/
ENV BOOST_INCLUDEDIR /boost/boost/
ENV BOOST_LIBRARYDIR /boost/stage/lib/
COPY nuget.config /root/.nuget/NuGet/NuGet.Config
