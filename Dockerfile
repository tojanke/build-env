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
	&& apt-get install -y -qq --no-install-recommends mono-complete mono-vbnc nuget wine wine32 1>/dev/null \	
	&& cd /usr/local/src \ 
    	&& wget -q https://cmake.org/files/v3.14/cmake-3.14.4.tar.gz \
    	&& tar xf cmake-3.14.4.tar.gz \ 
    	&& cd cmake-3.14.4 \
    	&& ./bootstrap 1>/dev/null \
    	&& make -j8 1>/dev/null \
    	&& make install 1>/dev/null \
	&& cd .. \
	&& rm -rf cmake* \
	&& wget -q https://sourceforge.net/projects/boost/files/boost/1.70.0/boost_1_70_0.tar.gz/download \	
	&& tar xf download \
	&& rm download \
	&& mv boost_1_70_0 /boost \
	&& cd /boost \
	&& echo "using gcc : 8.3 : g++-8 ;" > user-config.jam \
	&& ./bootstrap.sh \
	&& ./b2 -j8 --user-config=user-config.jam toolset=gcc-8.3 --build-type=complete --layout=versioned stage \
	   --with-timer --with-date_time --with-random --with-test --with-thread --with-regex \
  	&& echo "using gcc : mingw32 : x86_64-w64-mingw32-g++ ;" > user-config.jam \
  	&& ./bootstrap.sh \
  	&& (./b2 -j8 --user-config=user-config.jam toolset=gcc-mingw32 target-os=windows --build-type=complete \
	   --layout=versioned stage --with-timer --with-date_time --with-random --with-regex || true) \
	&& rm -rf /boost/libs && rm -rf /boost/bin.v2 && rm -rf /boost/doc && rm -rf /boost/tools \
	&& (find /boost/stage/lib/ -name 'libboost_*' -exec bash -c 'mv $0 ${0/mgw/mgw83}' {} \;) && ls /boost/stage/lib \
	&& cd /usr/local/src \
	&& wget -q https://sourceforge.net/projects/nsis/files/NSIS%203/3.04/nsis-3.04.zip/download \	
	&& unzip -qq download \
	&& rm download \
	&& mv nsis-3.04 nsis \
	&& apt-get remove --purge -y -qq g++ apt-transport-https dirmngr unzip adwaita-icon-theme gtk-update-icon-cache hicolor-icon-theme krb5-locales libapparmor1 libatk1.0-0 libatk1.0-data libavahi-client3 libavahi-common-data libavahi-common3 libgail-common libgail18 libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-bin libgdk-pixbuf2.0-common libglade2-0 libglade2.0-cil libglib2.0-cil libgraphite2-3 libgssapi-krb5-2 libgtk2.0-0 libgtk2.0-bin libgtk2.0-cil libgtk2.0-common libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 librsvg2-2 librsvg2-common libthai-data libthai0 libxcomposite1 libxcursor1 monodoc-base monodoc-browser monodoc-manual libcroco3 libcups2 libdatrie1 \
	   libxinerama1 libxrandr2 dbus fontconfig libdbus-1-3 libfribidi0 libharfbuzz0b libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libmono-2.0-1 libmono-profiler libmonoboehm-2.0-1 libxdamage1 libxfixes3 libxi6 mono-4.0-service mono-jay mono-utils \
	&& apt-get clean 1>>apt.log && rm -rf /var/lib/apt/lists/* && dpkg --get-selections
ENV BOOST_ROOT /boost/
ENV BOOST_INCLUDEDIR /boost/boost/
ENV BOOST_LIBRARYDIR /boost/stage/lib/
COPY nuget.config /root/.nuget/NuGet/NuGet.Config
