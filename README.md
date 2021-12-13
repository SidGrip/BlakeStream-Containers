<b>Deploy BlakeStream Coins with Docker Compose</b>
<br>
*** Curently everything is run as root ***
<br>
https://hub.docker.com/u/sidgrip
<br>
<br>
This was tested on a clean & updated install of Ubuntu 20.04
<br>
<br>
<b>Install Docker Compose</b>
<br>
Copy & paste into terminal window
<br>
```wget https://raw.githubusercontent.com/SidGrip/BlakeStream-Containers/main/Install_Docker.sh```
<br>
Then run ```bash Install_Docker.sh```
<br>
<br>
<b> Deploy Blake Nodes with Docker Compose</b>
<br>
Copy & paste into terminal window
<br>
```wget https://raw.githubusercontent.com/SidGrip/BlakeStream-Containers/main/BlakeStream_Docker.sh```
<br>
<br>
Edit the varables for the wallet configs at the top of the script
<br>
Then run ```bash BlakeStream_Docker.sh```
<br>
<br>
<b>I tried to make this as seamless as possable</b>
<br>
This script:
<br>
-- will create data directories
<br>
-- will give you an option to download a bootstrap that is a week behind
<br>
-- will autogen a config with random user/pass and add active nodes
<br>
-- will create scripts in ```/usr/local/bin``` that runs the same as the Daemons
<br>
-- will build and run a ```docker-compose.yml```
<br>
<br>
To help manage containers I recommend using a GUI like Portainer
<br>
```https://www.portainer.io/```
