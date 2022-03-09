FROM ubuntu:18.04

RUN apt-get update \
 && apt install --no-install-recommends -y software-properties-common \
 && apt-add-repository -y ppa:bitcoin/bitcoin \
 && apt-get update \
 && apt install --no-install-recommends -y wget git curl build-essential libssl-dev libboost-all-dev libminiupnpc-dev libdb4.8-dev libdb4.8++-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && mkdir -p /root/.universalmolecule \
 && git clone -b 16.04 https://github.com/BlueDragon747/universalmol.git \
 && chmod +x universalmol/src/leveldb/build_detect_platform \
 && cd universalmol/src \
 && make -f makefile.unix \
 && strip universalmoleculed \
 && cp universalmoleculed /usr/local/bin/ \
 && rm -rf universalmol

CMD ["/usr/local/bin/universalmoleculed", "-datadir=/root/.universalmolecule", "--printtoconsole"]
