FROM debian:bullseye-slim
MAINTAINER Tobias Janke <tobias.janke@outlook.com>
ENV DEBIAN_FRONTEND noninteractive
ENV CC /usr/bin/gcc-8
ENV CXX /usr/bin/g++-8
RUN	mkdir /log && apt-get update -qq 1>>/log/apt-upd.log 
RUN	apt-get install -y -qq --no-install-recommends apt-utils apt-transport-https dirmngr gnupg ca-certificates 1>>/log/apt-inst.log 2>&1 
RUN     apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF 1>/log/apt-key.log 2>&1
	&& echo "deb https://download.mono-project.com/repo/debian stable-stretch main" \
	   | tee /etc/apt/sources.list.d/mono-official-stable.list \
	&& dpkg --add-architecture i386 && apt-get update -qq 1>>/log/apt-upd.log
RUN     apt-get install -y -qq --no-install-recommends g++ g++-8 make libssl-dev wget unzip g++-mingw-w64-x86-64 mono-complete mono-vbnc nuget wine wine32 1>>/log/apt-inst.log
RUN	cd /usr/local/src \ 
    	&& wget -q https://cmake.org/files/v3.20/cmake-3.20.2.tar.gz \
	&& tar xf cmake-3.20.2.tar.gz \ 
    	&& cd cmake-3.20.2 \
	&& ./bootstrap 1>/log/cm-bs.log \
 	&& make -j8 1>/log/cm-mk.log \
 	&& make install 1>/log/cm-inst.log \
	&& cd .. \
	&& rm -rf cmake*
RUN     wget -q https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.gz \	
	&& tar xf boost_1_76_0.tar.gz \
	&& rm boost_1_76_0.tar.gz \
	&& mv boost_1_76_0 /boost \
	&& cd /boost \
	&& echo "using gcc : 8.3 : g++-8 ;" > user-config.jam \
	&& ./bootstrap.sh 1>/log/b-gcc-bs.log \
	&& ./b2 -j8 --user-config=user-config.jam toolset=gcc-8.3 --build-type=complete --layout=versioned stage \
	   --with-timer --with-date_time --with-random --with-test --with-thread --with-regex 1>/log/b-gcc-b2.log \
	&& cd /boost && echo "using gcc : mingw32 : x86_64-w64-mingw32-g++ ;" > user-config.jam \
  	&& ./bootstrap.sh 1>/log/b-mgw-bs.log \
  	&& ./b2 -j8 --user-config=user-config.jam toolset=gcc-mingw32 target-os=windows address-model=64 architecture=x86 \
	   --build-type=complete --layout=versioned stage --with-timer --with-date_time --with-random --with-thread --with-regex 1>/log/b-mgw-b2.log \
	&& rm -rf /boost/libs && rm -rf /boost/bin.v2 && rm -rf /boost/doc && rm -rf /boost/tools \
	&& (find /boost/stage/lib/ -name 'libboost_*' -exec bash -c 'mv $0 ${0/mgw/mgw83}' {} \;) && ls /boost/stage/lib 1>/log/boost-lib.log
RUN     cd /usr/local/src \
	&& wget -q https://sourceforge.net/projects/nsis/files/NSIS%203/3.06.1/nsis-3.06.1.zip/download \	
	&& unzip -qq download \
	&& rm download \
	&& mv nsis-3.06.1 nsis \
RUN     apt-get remove --purge -y g++ \
	&& apt-get clean 1>>apt.log && rm -rf /var/lib/apt/lists/* && dpkg --get-selections 1>/log/dpkg.log
ENV BOOST_ROOT /boost/
ENV BOOST_INCLUDEDIR /boost/boost/
ENV BOOST_LIBRARYDIR /boost/stage/lib/
COPY nuget.config /root/.nuget/NuGet/NuGet.Config
