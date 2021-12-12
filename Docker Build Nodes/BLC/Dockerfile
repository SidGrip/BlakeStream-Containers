FROM ubuntu:16.04

RUN apt-get update \
 && apt install --no-install-recommends -y software-properties-common \
 && apt-add-repository -y ppa:bitcoin/bitcoin \
 && apt-get update \
 && apt install --no-install-recommends -y wget git curl build-essential libssl-dev libboost-all-dev libminiupnpc-dev libdb4.8-dev libdb4.8++-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && mkdir -p /root/.blakecoin \
 && git clone https://github.com/BlueDragon747/Blakecoin.git \
 && chmod +x Blakecoin/src/leveldb/build_detect_platform \
 && cd Blakecoin/src \
 && make -f makefile.unix \
 && strip blakecoind \
 && cp blakecoind /usr/bin/

CMD ["/usr/bin/blakecoind", "-datadir=/root/.blakecoin", "--printtoconsole"]