FROM ubuntu:18.04

RUN apt-get update \
 && apt install --no-install-recommends -y software-properties-common \
 && apt-add-repository -y ppa:bitcoin/bitcoin \
 && apt-get update \
 && apt install --no-install-recommends -y wget git curl build-essential libssl-dev libboost-all-dev libminiupnpc-dev libdb4.8-dev libdb4.8++-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && mkdir -p /root/.photon \
 && git clone -b 16.04 https://github.com/photonproject/photon.git \
 && chmod +x photon/src/leveldb/build_detect_platform \
 && cd photon/src \
 && make -f makefile.unix \
 && strip photond \
 && cp photond /usr/local/bin/ \
 && rm -rf photon

CMD ["/usr/local/bin/photond", "-datadir=/root/.photon", "--printtoconsole"]
