#!/bin/bash
#
MAXCONNECTIONS='maxconnections=20'
RPCALLOWIP='rpcallowip=0.0.0.0/0'
GEN='gen=0'
LISTEN='listen=1'
DAEMON='daemon=0'
SERVER='server=1'
TXINDEX='txindex=1'
#
FTP='https://bootstrap.specminer.com'
USER=$(whoami)
USERDIR=$(eval echo ~$user)
STRAP='bootstrap.dat'
COIN_PATH='/usr/local/bin'
RPCUSER=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w10 | head -n1 | sed -e 's/^/rpcuser=/')
RPCPASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w22 | head -n1 | sed -e 's/^/rpcpassword=/')
BBlue='\033[1;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[1;97m'
YELLOW='\033[0;93m'
NC='\033[0m'

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec &> >(tee setup.log) 2>&1
# Everything below will go to the file 'setup.log':

#Menu options
options[0]="All BlakeStream Coins"
options[1]="Blakecoin"
options[2]="Photon"
options[3]="BlakeBitcoin"
options[4]="Electron"
options[5]="Universal Molecule"
options[6]="Lithium"
options[7]="Download Bootstraps for Selected Daemons"

#Actions to take based on selection
function menu {
    if [[ ${choices[0]} ]]; then
        #Option 1 selected
        echo "All Blakestream Daemons selected"
        ALL='Y'
    fi
    if [[ ${choices[1]} ]]; then
        #Option 2 selected
        echo "Blakecoin selected"
        BLC='Y'
    fi
    if [[ ${choices[2]} ]]; then
        #Option 3 selected
        echo "Photon selected"
        PHO='Y'
    fi
    if [[ ${choices[3]} ]]; then
        #Option 4 selected
        echo "BlakeBitcoin selected"
        BBTC='Y'
    fi
    if [[ ${choices[4]} ]]; then
        #Option 5 selected
        echo "Electron selected"
        ELT='Y'
    fi
    if [[ ${choices[5]} ]]; then
        #Option 6 selected
        echo "Universal Molecule selected"
        UMO='Y'
    fi
    if [[ ${choices[6]} ]]; then
        #Option 7 selected
        echo "Lithium selected"
        LIT='Y'
    fi
    if [[ ${choices[7]} ]]; then
        #Option 8 selected
        echo "Boostraps selected"
        BSTRP='Y'
    fi

}

#Variables
ERROR=" "

#Clear screen for menu
clear

#Menu function
function MENU {
    echo "Blakestream Daemon Install"
    for NUM in ${!options[@]}; do
        echo "[""${choices[NUM]:- }""]" $(( NUM+1 ))") ${options[NUM]}"
    done
    echo "$ERROR"
}

#Menu loop
while MENU && read -e -p "Select the desired options using their number (again to uncheck, ENTER when done): " -n1 SELECTION && [[ -n "$SELECTION" ]]; do
    clear
    if [[ "$SELECTION" == *[[:digit:]]* && $SELECTION -ge 1 && $SELECTION -le ${#options[@]} ]]; then
        (( SELECTION-- ))
        if [[ "${choices[SELECTION]}" == "+" ]]; then
            choices[SELECTION]=""
        else
            choices[SELECTION]="+"
        fi
            ERROR=" "
    else
        ERROR="Invalid option: $SELECTION"
    fi
done

progressfilt ()
{
    local flag=false c count cr=$'\r' nl=$'\n'
    while IFS='' read -d '' -rn 1 c
    do
        if $flag
        then
            printf '%s' "$c"
        else
            if [[ $c != $cr && $c != $nl ]]
            then
                count=0
            else
                ((count++))
                if ((count > 1))
                then
                    flag=true
                fi
            fi
        fi
    done
}

function blc_install()  {
clear
if [ -f "$USERDIR/$BLC_CONFIGFOLDER/peers.dat" ]; then
echo "$BLC_COIN_NAME already installed skipping"
elif [[ $BLC == Y || $ALL == Y ]]; then
        echo "Setting up $BLC_COIN_NAME Container"

#BlakeCoin Variables
BLC_CONFIG_FILE='blakecoin.conf'
BLC_CONFIGFOLDER='.blakecoin'
BLC_COIN_DAEMON='blakecoind'
BLC_COIN_NAME='Blakecoin'
BLC_RPC_PORT='8772'
BLC_P2P_PORT='8773'
# get list of curent active nodes from chainz block explorer sort and save to var
NODES=$(curl -s https://chainz.cryptoid.info/blc/api.dws?q=nodes)
BLC_PEERS=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' <<< "$NODES" | sed -e 's/^/addnode=/')

#Setup Firewall
 echo -e "Setting up firewall ${GREEN}$BLC_P2P_PORT${NC}"
  ufw allow $BLC_P2P_PORT/tcp comment "$BLC_COIN_NAME" >/dev/null

#Make Coin Directory
mkdir $USERDIR/$BLC_CONFIGFOLDER >/dev/null 2>&1

#Create Config File
echo -e "Creating $BLC_COIN_NAME config file"
  cat << EOF > $USERDIR/$BLC_CONFIGFOLDER/$BLC_CONFIG_FILE
$MAXCONNECTIONS
$RPCUSER
$RPCPASSWORD
$RPCALLOWIP
rpcport=$BLC_RPC_PORT
port=$BLC_P2P_PORT
$GEN
$LISTEN
$DAEMON
$SERVER
$TXINDEX
$BLC_PEERS
EOF

#Daemon_script
cat << 'EOT' > $COIN_PATH/$BLC_COIN_DAEMON
#!/bin/bash
  docker exec BLC /usr/bin/blakecoind "$@"
EOT
sudo chmod u+x $COIN_PATH/$BLC_COIN_DAEMON

#Downloading Bootstrap
   if [[ $BSTRP == Y ]]; then
echo "Downloading $BLC_COIN_NAME $STRAP to $USERDIR/$BLC_CONFIGFOLDER"
  wget --progress=bar:force -O $USERDIR/$BLC_CONFIGFOLDER/$STRAP $FTP/$BLC_COIN_NAME/$STRAP 2>&1 | progressfilt; 
else
echo "$BLC_COIN_NAME Boostrap not selected"
fi

#Blakecoin Docker compose entry
BLC=$(cat << EOF
  BLC:
    container_name: BLC
    image: sidgrip/blakecoin:node
    restart: unless-stopped
    volumes:
      - $USERDIR/$BLC_CONFIGFOLDER:/root/.blakecoin
    ports: 
      - "$BLC_RPC_PORT:$BLC_RPC_PORT"
      - "$BLC_P2P_PORT:$BLC_P2P_PORT"
EOF
)
    else
        echo "$BLC_COIN_NAME option not chosen"
    fi
}

function pho_install()  {
clear
if [ -f "$USERDIR/$PHO_CONFIGFOLDER/peers.dat" ]; then
echo "$PHO_COIN_NAME already installed skipping"
elif [[ $PHO == Y || $ALL == Y ]]; then
        echo "Installing $PHO_COIN_NAME Node"

#Photon Variables
PHO_CONFIG_FILE='photon.conf'
PHO_CONFIGFOLDER='.photon'
PHO_COIN_DAEMON='photond'
PHO_COIN_NAME='Photon'
PHO_RPC_PORT='8984'
PHO_P2P_PORT='35556'
NODES=$(curl -s https://chainz.cryptoid.info/pho/api.dws?q=nodes)
PHO_PEERS=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' <<< "$NODES" | sed -e 's/^/addnode=/')

#Setup Firewall
 echo -e "Setting up firewall ${GREEN}$PHO_P2P_PORT${NC}"
  ufw allow $PHO_P2P_PORT/tcp comment "$PHO_COIN_NAME" >/dev/null

#Make Coin Directory
mkdir $USERDIR/$PHO_CONFIGFOLDER >/dev/null 2>&1

#Create Config File
echo -e "Creating $PHO_COIN_NAME config file"
  cat << EOF > $USERDIR/$PHO_CONFIGFOLDER/$PHO_CONFIG_FILE
$MAXCONNECTIONS
$RPCUSER
$RPCPASSWORD
$RPCALLOWIP
rpcport=$PHO_RPC_PORT
port=$PHO_P2P_PORT
$GEN
$LISTEN
$DAEMON
$SERVER
$TXINDEX
$PHO_PEERS
EOF

#Daemon_script
cat << 'EOT' > $COIN_PATH/$PHO_COIN_DAEMON
#!/bin/bash
  docker exec PHO /usr/bin/photond "$@"
EOT
sudo chmod u+x $COIN_PATH/$PHO_COIN_DAEMON

#Downloading Bootstrap
   if [[ $BSTRP == Y ]]; then
echo "Downloading $PHO_COIN_NAME $STRAP to $USERDIR/$PHO_CONFIGFOLDER"
  wget --progress=bar:force -O $USERDIR/$PHO_CONFIGFOLDER/$STRAP $FTP/$PHO_COIN_NAME/$STRAP 2>&1 | progressfilt; 
else
echo "$PHO_COIN_NAME Boostrap not selected"
fi

#Photon Docker compose entry
PHO=$(cat << EOF
  PHO:
    container_name: PHO
    image: sidgrip/photon:node
    restart: unless-stopped
    volumes:
      - $USERDIR/$PHO_CONFIGFOLDER:/root/.photon
    ports: 
      - "$PHO_RPC_PORT:$PHO_RPC_PORT"
      - "$PHO_P2P_PORT:$PHO_P2P_PORT"
EOF
)
    else
        echo "$PHO_COIN_NAME option not chosen"
    fi
}

function bbtc_install()  {
clear
if [ -f "$USERDIR/$BBTC_CONFIGFOLDER/peers.dat" ]; then
echo "$BBTC_COIN_NAME already installed skipping"
elif [[ $BBTC == Y || $ALL == Y ]]; then
        echo "Installing $BBTC_COIN_NAME Node"

#Blakebitcoin Variables
BBTC_CONFIG_FILE='blakebitcoin.conf'
BBTC_CONFIGFOLDER='.blakebitcoin'
BBTC_COIN_DAEMON='blakebitcoind'
BBTC_COIN_NAME='BlakeBitcoin'
BBTC_RPC_PORT='243'
BBTC_P2P_PORT='356'
NODES=$(curl -s https://chainz.cryptoid.info/bbtc/api.dws?q=nodes)
BBTC_PEERS=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' <<< "$NODES" | sed -e 's/^/addnode=/')

#Setup Firewall
 echo -e "Setting up firewall ${GREEN}$BBTC_P2P_PORT${NC}"
  ufw allow $BBTC_P2P_PORT/tcp comment "$BBTC_COIN_NAME" >/dev/null

#Make Coin Directory
mkdir $USERDIR/$BBTC_CONFIGFOLDER >/dev/null 2>&1

#Create Config File
echo -e "Creating $BBTC_COIN_NAME config file"
  cat << EOF > $USERDIR/$BBTC_CONFIGFOLDER/$BBTC_CONFIG_FILE
$MAXCONNECTIONS
$RPCUSER
$RPCPASSWORD
$RPCALLOWIP
rpcport=$BBTC_RPC_PORT
port=$BBTC_P2P_PORT
$GEN
$LISTEN
$DAEMON
$SERVER
$TXINDEX
$BBTC_PEERS
EOF

#Daemon_script
cat << 'EOT' > $COIN_PATH/$BBTC_COIN_DAEMON
#!/bin/bash
  docker exec BBTC /usr/bin/blakebitcoind "$@"
EOT
sudo chmod u+x $COIN_PATH/$BBTC_COIN_DAEMON

#Downloading Bootstrap
   if [[ $BSTRP == Y ]]; then
echo "Downloading $BBTC_COIN_NAME $STRAP to $USERDIR/$BBTC_CONFIGFOLDER"
  wget --progress=bar:force -O $USERDIR/$BBTC_CONFIGFOLDER/$STRAP $FTP/$BBTC_COIN_NAME/$STRAP 2>&1 | progressfilt; 
else
echo "$BBTC_COIN_NAME Boostrap not selected"
fi

#Blakebitcoin Docker compose entry
BBTC=$(cat << EOF
  BBTC:
    container_name: BBTC
    image: sidgrip/blakebitcoin:node
    restart: unless-stopped
    volumes:
      - $USERDIR/$BBTC_CONFIGFOLDER:/root/.blakebitcoin
    ports: 
      - "$BBTC_RPC_PORT:$BBTC_RPC_PORT"
      - "$BBTC_P2P_PORT:$BBTC_P2P_PORT"
EOF
)
    else
        echo "$BBTC_COIN_NAME option not chosen"
    fi
}

function elt_install()  {
clear
if [ -f "$USERDIR/$ELT_CONFIGFOLDER/peers.dat" ]; then
echo "$ELT_COIN_NAME already installed skipping"
elif [[ $ELT == Y || $ALL == Y ]]; then
        echo "Installing $ELT_COIN_NAME Node"

#Electron Variables
ELT_CONFIG_FILE='electron.conf'
ELT_CONFIGFOLDER='.electron'
ELT_COIN_DAEMON='electrond'
ELT_COIN_NAME='Electron'
ELT_RPC_PORT='6852'
ELT_P2P_PORT='6853'
NODES=$(curl -s https://chainz.cryptoid.info/elt/api.dws?q=nodes)
ELT_PEERS=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' <<< "$NODES" | sed -e 's/^/addnode=/')

#Setup Firewall
 echo -e "Setting up firewall ${GREEN}$ELT_P2P_PORT${NC}"
  ufw allow $ELT_P2P_PORT/tcp comment "$ELT_COIN_NAME" >/dev/null

#Make Coin Directory
mkdir $USERDIR/$ELT_CONFIGFOLDER >/dev/null 2>&1

#Create Config File
echo -e "Creating $ELT_COIN_NAME config file"
  cat << EOF > $USERDIR/$ELT_CONFIGFOLDER/$ELT_CONFIG_FILE
$MAXCONNECTIONS
$RPCUSER
$RPCPASSWORD
$RPCALLOWIP
rpcport=$ELT_RPC_PORT
port=$ELT_P2P_PORT
$GEN
$LISTEN
$DAEMON
$SERVER
$TXINDEX
$ELT_PEERS
EOF

#Daemon_script
cat << 'EOT' > $COIN_PATH/$ELT_COIN_DAEMON
#!/bin/bash
  docker exec ELT /usr/bin/electrond "$@"
EOT
sudo chmod u+x $COIN_PATH/$ELT_COIN_DAEMON

#Downloading Bootstrap
   if [[ $BSTRP == Y ]]; then
echo "Downloading $ELT_COIN_NAME $STRAP to $USERDIR/$ELT_CONFIGFOLDER"
  wget --progress=bar:force -O $USERDIR/$ELT_CONFIGFOLDER/$STRAP $FTP/$ELT_COIN_NAME/$STRAP 2>&1 | progressfilt; 
else
echo "$ELT_COIN_NAME Boostrap not selected"
fi

#Electron Docker compose entry
ELT=$(cat << EOF
  ELT:
    container_name: ELT
    image: sidgrip/electron:node
    restart: unless-stopped
    volumes:
      - $USERDIR/$ELT_CONFIGFOLDER:/root/.electron
    ports: 
      - "$ELT_RPC_PORT:$ELT_RPC_PORT"
      - "$ELT_P2P_PORT:$ELT_P2P_PORT"
EOF
)
    else
        echo "$ELT_COIN_NAME option not chosen"
    fi
}

function umo_install()  {
clear
if [ -f "$USERDIR/$UMO_CONFIGFOLDER/peers.dat" ]; then
echo "$UMO_COIN_NAME already installed skipping"
elif [[ $UMO == Y || $ALL == Y ]]; then
        echo "Installing $UMO_COIN_NAME Node"

#Universalmolecule Variables
UMO_CONFIG_FILE='universalmolecule.conf'
UMO_CONFIGFOLDER='.universalmolecule'
UMO_COIN_DAEMON='universalmoleculed'
UMO_COIN_NAME='UniversalMolecule'
UMO_RPC_PORT='19738'
UMO_P2P_PORT='24785'
# get list of curent active nodes from chainz block explorer sort and save to var
NODES=$(curl -s https://chainz.cryptoid.info/umo/api.dws?q=nodes)
UMO_PEERS=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' <<< "$NODES" | sed -e 's/^/addnode=/')

#Setup Firewall
 echo -e "Setting up firewall ${GREEN}$UMO_P2P_PORT${NC}"
  ufw allow $UMO_P2P_PORT/tcp comment "$UMO_COIN_NAME" >/dev/null

#Make Coin Directory
mkdir $USERDIR/$UMO_CONFIGFOLDER >/dev/null 2>&1

#Create Config File
echo -e "Creating $UMO_COIN_NAME config file"
  cat << EOF > $USERDIR/$UMO_CONFIGFOLDER/$UMO_CONFIG_FILE
$MAXCONNECTIONS
$RPCUSER
$RPCPASSWORD
$RPCALLOWIP
rpcport=$UMO_RPC_PORT
port=$UMO_P2P_PORT
$GEN
$LISTEN
$DAEMON
$SERVER
$TXINDEX
$UMO_PEERS
EOF

#Daemon_script
cat << 'EOT' > $COIN_PATH/$UMO_COIN_DAEMON
#!/bin/bash
  docker exec UMO /usr/bin/universalmoleculed "$@"
EOT
sudo chmod u+x $COIN_PATH/$UMO_COIN_DAEMON


#Downloading Bootstrap
   if [[ $BSTRP == Y ]]; then
echo "Downloading $UMO_COIN_NAME $STRAP to $USERDIR/$UMO_CONFIGFOLDER"
  wget --progress=bar:force -O $USERDIR/$UMO_CONFIGFOLDER/$STRAP $FTP/$UMO_COIN_NAME/$STRAP 2>&1 | progressfilt; 
else
echo "$UMO_COIN_NAME Boostrap not selected"
fi

#Universalmolecule Docker compose entry
UMO=$(cat << EOF
  UMO:
    container_name: UMO
    image: sidgrip/universalmolecule:node
    restart: unless-stopped
    volumes:
      - $USERDIR/$UMO_CONFIGFOLDER:/root/.universalmolecule
    ports: 
      - "$UMO_RPC_PORT:$UMO_RPC_PORT"
      - "$UMO_P2P_PORT:$UMO_P2P_PORT"
EOF
)
    else
        echo "$UMO_COIN_NAME option not chosen"
    fi
}

function lit_install()  {
clear
if [ -f "$USERDIR/$LIT_CONFIGFOLDER/wallet.dat" ]; then
echo "$LIT_COIN_NAME already installed skipping"
elif [[ $LIT == Y || $ALL == Y ]]; then
        echo "Installing $LIT_COIN_NAME Node"

#Lithium Variables
LIT_CONFIG_FILE='lithium.conf'
LIT_CONFIGFOLDER='.lithium'
LIT_COIN_DAEMON='lithiumd'
LIT_COIN_NAME='Lithium'
LIT_RPC_PORT='12345'
LIT_P2P_PORT='12007'
# get list of curent active nodes from chainz block explorer sort and save to var
NODES=$(curl -s https://chainz.cryptoid.info/lit/api.dws?q=nodes)
LIT_PEERS=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' <<< "$NODES" | sed -e 's/^/addnode=/')

#Setup Firewall
 echo -e "Setting up firewall ${GREEN}$LIT_P2P_PORT${NC}"
  ufw allow $LIT_P2P_PORT/tcp comment "$LIT_COIN_NAME" >/dev/null

#Make Coin Directory
mkdir $USERDIR/$LIT_CONFIGFOLDER >/dev/null 2>&1

#Create Config File
echo -e "Creating $LIT_COIN_NAME config file"
  cat << EOF > $USERDIR/$LIT_CONFIGFOLDER/$LIT_CONFIG_FILE
$MAXCONNECTIONS
$RPCUSER
$RPCPASSWORD
$RPCALLOWIP
rpcport=$LIT_RPC_PORT
port=$LIT_P2P_PORT
$GEN
$LISTEN
$DAEMON
$SERVER
$TXINDEX
$LIT_PEERS
EOF

#Daemon_script
cat << 'EOT' > $COIN_PATH/$LIT_COIN_DAEMON
#!/bin/bash
  docker exec LIT /usr/bin/lithiumd "$@"
EOT
sudo chmod u+x $COIN_PATH/$LIT_COIN_DAEMON

#Downloading Bootstrap
   if [[ $BSTRP == Y ]]; then
echo "Downloading $LIT_COIN_NAME $STRAP to $USERDIR/$LIT_CONFIGFOLDER"
  wget --progress=bar:force -O $USERDIR/$LIT_CONFIGFOLDER/$STRAP $FTP/$LIT_COIN_NAME/$STRAP 2>&1 | progressfilt; 
else
echo "Boostrap not selected"
fi

#Lithium Docker compose entry
LIT=$(cat << EOF
  LIT:
    container_name: LIT
    image: sidgrip/lithium:node
    restart: unless-stopped
    volumes:
      - $USERDIR/$LIT_CONFIGFOLDER:/root/.lithium
    ports: 
      - "$LIT_RPC_PORT:$LIT_RPC_PORT"
      - "$LIT_P2P_PORT:$LIT_P2P_PORT"
EOF
)
    else
        echo "$LIT_COIN_NAME option not chosen"
    fi
}

function build_compose() {
  cat << EOF > docker-compose.yml
version: "3.8"

services:
 $BLC
 $PHO
 $BBTC
 $ELT
 $UMO
 $LIT

networks:
  default:
    name: BlakeNodes
    driver: bridge
    ipam:
      driver: default
    driver_opts:
      com.docker.network.bridge.enable_icc: "true"
      com.docker.network.bridge.enable_ip_masquerade: "true"
EOF
}

function run_compose() {

docker-compose -f "docker-compose.yml" -p "BlakeNodes" up -d --build

}

function setup_node() {
  blc_install
  pho_install
  bbtc_install
  elt_install
  umo_install
  lit_install
  build_compose
  run_compose
}

##### Main #####
clear
menu
setup_node
