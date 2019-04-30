FROM debian:buster-slim
MAINTAINER Tobias Janke <tobias.janke@outlook.com>
RUN (apt-get update -qq 1>>apt.log \
	&& apt-get install -y -qq g++ g++-8 make wget unzip mingw-w64 wine apt-transport-https dirmngr gnupg ca-certificates 1>>apt.log \
	&& apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF 1>>apt.log \
	&& echo "deb https://download.mono-project.com/repo/debian stable-stretch main" | tee /etc/apt/sources.list.d/mono-official-stable.list \
	&& dpkg --add-architecture i386 && apt-get update -qq 1>>apt.log \
	&& apt-get install -y -qq mono-complete mono-vbnc nuget wine32 1>>apt.log \
	&& apt-get clean 1>>apt.log && rm -rf /var/lib/apt/lists/*) || (cat apt.log && false)
ENV CC /usr/bin/gcc-8
ENV CXX /usr/bin/g++-8
RUN cd /usr/local/src \ 
    	&& wget -q https://cmake.org/files/v3.13/cmake-3.13.0.tar.gz \
    	&& tar xf cmake-3.13.0.tar.gz \ 
    	&& cd cmake-3.13.0 \
    	&& (./bootstrap 1>>cmake.log || (cat cmake.log && false)) \
    	&& (make 1>cmake.log || (cat cmake.log && false)) \
    	&& (make install 1>>cmake.log || (cat cmake.log && false)) \
	&& cd .. \
	&& rm -rf cmake*
RUN wget -q https://sourceforge.net/projects/boost/files/boost/1.69.0/boost_1_69_0.tar.gz/download \	
	&& tar xf download \
	&& rm download \
	&& mv boost_1_69_0 boost \
	&& cd boost \
	&& (./bootstrap.sh 1>>boost.log || (cat boost.log && false)) \
	&& (./b2 -j8 --build-type=complete --layout=versioned stage \
	--with-timer --with-date_time --with-random --with-test --with-regex 1>>boost.log || (cat boost.log && false)) \
	&& cd .. && rm -rf /boost/libs && rm -rf /boost/bin.v2 && rm -rf /boost/doc && rm -rf /boost/tools
ENV BOOST_ROOT /boost/
ENV BOOST_INCLUDEDIR /boost/boost/
ENV BOOST_LIBRARYDIR /boost/stage/lib/
COPY nuget.config /root/.nuget/NuGet/NuGet.Config
RUN cd /usr/local/src \
	&& wget -q https://sourceforge.net/projects/nsis/files/NSIS%203/3.04/nsis-3.04.zip/download \	
	&& unzip download \
	&& rm download \
	&& mv nsis-3.04 nsis
