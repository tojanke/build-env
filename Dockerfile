FROM debian:buster-slim
MAINTAINER Tobias Janke <tobias.janke@outlook.com>
ENV CC /usr/bin/gcc-8
ENV CXX /usr/bin/g++-8
RUN 	   apt-get update -qq 1>>/dev/null \
	&& apt-get install -y -qq --no-install-recommends \
	   g++ g++-8 make wget unzip g++-mingw-w64-x86-64 apt-transport-https dirmngr gnupg ca-certificates 1>/dev/null \
	&& apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
	&& echo "deb https://download.mono-project.com/repo/debian stable-stretch main" \
	   | tee /etc/apt/sources.list.d/mono-official-stable.list \
	&& dpkg --add-architecture i386 && apt-get update -qq 1>/dev/null \
	&& apt-get install -y -qq --no-install-recommends mono-devel mono-vbnc nuget wine32 1>/dev/null \	
	&& cd /usr/local/src \ 
    	&& wget -q https://cmake.org/files/v3.13/cmake-3.13.0.tar.gz \
    	&& tar xf cmake-3.13.0.tar.gz \ 
    	&& cd cmake-3.13.0 \
    	&& ./bootstrap 1>/dev/null \
    	&& make -j8 1>/dev/null \
    	&& make install 1>/dev/null \
	&& cd .. \
	&& rm -rf cmake* \
	&& wget -q https://sourceforge.net/projects/boost/files/boost/1.69.0/boost_1_69_0.tar.gz/download \	
	&& tar xf download \
	&& rm download \
	&& mv boost_1_69_0 boost \
	&& cd boost \
	&& echo "using gcc : 8.3 : g++-8 ;" > user-config.jam \
	&& ./bootstrap.sh \
	&& ./b2 -j8 --user-config=user-config.jam toolset=gcc-8.3 --build-type=complete --layout=versioned stage \
	   --with-timer --with-date_time --with-random --with-test --with-regex \
  	&& echo "using gcc : mingw32 : x86_64-w64-mingw32-g++ ;" > user-config.jam \
  	&& ./bootstrap.sh \
  	&& (./b2 -j8 --user-config=user-config.jam toolset=gcc-mingw32 target-os=windows --build-type=complete \
	   --layout=versioned stage --with-timer --with-date_time --with-random --with-test --with-regex || true) \
	&& rm -rf /boost/libs && rm -rf /boost/bin.v2 && rm -rf /boost/doc && rm -rf /boost/tools \
	&& (find /boost/stage/lib/ -name 'libboost_*' -exec bash -c 'mv $0 ${0/mgw/mgw83}' {} \;) && ls /boost/stage/lib \
	&& cd /usr/local/src \
	&& wget -q https://sourceforge.net/projects/nsis/files/NSIS%203/3.04/nsis-3.04.zip/download \	
	&& unzip -qq download \
	&& rm download \
	&& mv nsis-3.04 nsis \
	&& apt-get remove --purge -y -qq g++ apt-transport-https dirmngr wget unzip \
	&& apt-get clean 1>>apt.log && rm -rf /var/lib/apt/lists/*
ENV BOOST_ROOT /boost/
ENV BOOST_INCLUDEDIR /boost/boost/
ENV BOOST_LIBRARYDIR /boost/stage/lib/
COPY nuget.config /root/.nuget/NuGet/NuGet.Config
