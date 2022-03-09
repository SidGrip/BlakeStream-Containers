FROM ubuntu:18.04

RUN apt-get update \
 && apt install --no-install-recommends -y software-properties-common \
 && apt-add-repository -y ppa:bitcoin/bitcoin \
 && apt-get update \
 && apt install --no-install-recommends -y wget git curl build-essential libssl-dev libboost-all-dev libminiupnpc-dev libdb4.8-dev libdb4.8++-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && mkdir -p /root/.electron \
 && git clone -b 16.04 https://github.com/BlueDragon747/Electron-ELT.git \
 && chmod +x Electron-ELT/src/leveldb/build_detect_platform \
 && cd Electron-ELT/src \
 && make -f makefile.unix \
 && strip electrond \
 && cp electrond /usr/local/bin/ \
 && rm -rf Electron-ELT

CMD ["/usr/local/bin/electrond", "-datadir=/root/.electron", "--printtoconsole"]
