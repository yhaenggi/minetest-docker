ARG ARCH
FROM ${ARCH}/ubuntu:bionic
MAINTAINER yhaenggi <yhaenggi-git-public@darkgamex.ch>

ARG ARCH
ARG VERSION
ENV VERSION=${VERSION}
ENV ARCH=${ARCH}

ARG VERSION_IRRLICHTMT
ENV VERSION_IRRLICHTMT=${VERSION_IRRLICHTMT}

COPY ./qemu-arm-static /usr/bin/qemu-arm
COPY ./qemu-aarch64-static /usr/bin/qemu-aarch64

RUN echo force-unsafe-io | tee /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
RUN apt-get update

# set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive
#install tzdata package
RUN apt-get install tzdata -y
# set your timezone
RUN ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get install software-properties-common -y
RUN add-apt-repository universe
RUN add-apt-repository multiverse
RUN add-apt-repository ppa:minetestdevs/stable -y
RUN sed 's/# deb-src/deb-src/g' -i /etc/apt/sources.list
RUN sed 's/# deb-src/deb-src/g' -i /etc/apt/sources.list.d/minetestdevs-ubuntu-stable-bionic.list
RUN apt-get update

RUN apt-get build-dep minetest -y
RUN apt-get install git debhelper fakeroot devscripts -y
RUN apt-get install build-essential libirrlicht-dev cmake libbz2-dev libpng-dev libjpeg-dev libsqlite3-dev libcurl4-gnutls-dev zlib1g-dev libgmp-dev libjsoncpp-dev luajit libgmp-dev libluajit-5.1-dev libleveldb-dev libhiredis-dev libspatialindex-dev libpq-dev libpq-dev postgresql-server-dev-all -y

WORKDIR /tmp/
RUN git clone --depth 1 --branch ${VERSION} https://github.com/minetest/minetest.git minetest
RUN git clone --depth=1 --branch ${VERSION_IRRLICHTMT} https://github.com/minetest/irrlicht.git irrlichtmt

WORKDIR /tmp/minetest/

RUN mkdir -p /tmp/minetest/cmakebuild
WORKDIR /tmp/minetest/cmakebuild/
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release -DRUN_IN_PLACE=FALSE -DBUILD_SERVER=TRUE -DBUILD_CLIENT=FALSE -BUILD_UNITTESTS=FALSE -DENABLE_SYSTEM_JSONCPP=1 -DENABLE_LEVELDB=ON -DENABLE_POSTGRESQL=ON -DENABLE_REDIS=ON -DENABLE_SPATIAL=ON -DENABLE_LUAJIT=ON -DENABLE_SYSTEM_GMP=ON -DENABLE_CURL=ON -DENABLE_SYSTEM_JSONCPP=ON -DENABLE_SOUND=OFF -DPostgreSQL_INCLUDE_DIR=/usr/include/postgresql/ -DIRRLICHT_INCLUDE_DIR=/tmp/irrlichtmt/include ..
RUN bash -c "nice -n 20 make -j$(nproc)"

ARG VERSION_GAME
ENV VERSION_GAME=${VERSION_GAME}

WORKDIR /tmp/minetest/games/
RUN git clone --depth 1 --branch ${VERSION_GAME} https://github.com/minetest/minetest_game.git minetest_game

WORKDIR /tmp/minetest/cmakebuild/
RUN make install

RUN rm /usr/bin/qemu-*

FROM ${ARCH}/ubuntu:bionic

COPY ./qemu-arm-static /usr/bin/qemu-arm
COPY ./qemu-aarch64-static /usr/bin/qemu-aarch64

WORKDIR /root/

# set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

# netcat is used for liveness/readiness probes
# also game dependencies
RUN apt-get update && apt-get install tzdata libcurl3-gnutls libjsoncpp1 liblua5.1-0 libluajit-5.1-2 libpq5 libsqlite3-0 libstdc++6 zlib1g libc6 libleveldb1v5 libspatialindex-c4v5 libhiredis0.13 netcat-openbsd -y && apt-get clean && rm -R /var/cache/apt && rm -R /var/lib/apt/lists

# set your timezone
RUN ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN mkdir -p /home/minetest/.minetest
RUN useradd -M -d /home/minetest -u 911 -U -s /bin/bash minetest
RUN usermod -G users minetest
RUN chown minetest:minetest /home/minetest -R

COPY --from=0 /usr/local/share/minetest /usr/local/share/minetest
COPY --from=0 /tmp/minetest/games/minetest_game /usr/local/share/minetest/games/minetest_game
COPY --from=0 /usr/local/bin/minetestserver /usr/local/bin/minetestserver
COPY --from=0 /usr/local/share/doc/minetest/minetest.conf.example /etc/minetest/minetest.conf

RUN rm /usr/bin/qemu-*

USER minetest
WORKDIR /home/minetest

EXPOSE 30000/udp

ENTRYPOINT ["/usr/local/bin/minetestserver"]
CMD ["--config", "/etc/minetest/minetest.conf", "--gameid", "minetest"]
