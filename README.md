# FreshSystemSetup
## Proxy settings for IDRBT
### Add the following lines to ~/.bashrc
```
# Set Proxy
function setproxy() {
    export {http,https,ftp,HTTP,HTTPS}_proxy="http://172.27.10.67:3128/"
    sudo snap set system proxy.http="http://172.27.10.67:3128"
    sudo snap set system proxy.http="http://172.27.10.67:3128"
    echo "Acquire::http::Proxy \"http://172.27.10.67:3128/\";" | sudo tee -a /etc/apt/apt.conf
    echo "Acquire::https::Proxy \"http://172.27.10.67:3128/\";" | sudo tee -a /etc/apt/apt.conf
    git config --global http.proxy http://172.27.10.67:3128
    git config --global https.proxy http://172.27.10.67:3128
}

# Unset Proxy
function unsetproxy() {
    unset {http,https,ftp,HTTP,HTTPS}_proxy
    sudo snap set system proxy.http=""
    sudo snap set system proxy.http=""
    sudo sed -i '/^Acquire::http/d' /etc/apt/apt.conf
    git config --global --unset http.proxy
    git config --global --unset https.proxy
}
#####-------------------------------------------------------#####
function gettemp() {
    paste <(cat /sys/class/thermal/thermal_zone*/type) <(cat /sys/class/thermal/thermal_zone*/temp) | column -s $'\t' -t | sed 's/\(.\)..$/.\1°C/'
}
#####-------------------------------------------------------#####
function gettopcpu(){
    ps aux --sort -%cpu | head -2
}
#####-------------------------------------------------------#####
function execute_with_timestamp() {
    local cmd="$1"
    while true; do
        echo "<$(date '+%Y-%m-%d %H:%M:%S')>\n  $(eval $cmd)"
        sleep 1
    done
}
#####-------------------------------------------------------#####
#gping
function gping(){
    #nmap -sP 208.109.192.1-255
    IFS=$'\n'
    declare -A reachability
    readarray -t IPS <<< "$(ip a | grep -o '^[[:digit:]]*[:][[:alnum:][:space:]]*:'| awk -F  ':' '/1/ {print $2}'|tr -d ' ')"
    for iface in "${IPS[@]}"
    do
        ip_mask=($(ip -f inet addr show $iface | grep inet|awk -F' ' '{print $2}'))  ### IP address with subnet mask
        echo "Using "$iface": "$ip_mask 
        nmap -sP $ip_mask
    done
}

setproxy
```
## Docker proxy
### Add user specific settings
Edit/Create `~/.docker/config` and add the following lines
```
{
 "proxies":
 {
   "default":
   {
     "httpProxy": "http://172.27.10.67:3128",
     "httpsProxy": "http://172.27.10.67:3128",
     "noProxy": "172.27.0.0/16,127.0.0.0/8"
   }
 }
}
```
### Add daemon specific settings
Create `sudo mkdir -p /etc/systemd/system/docker.service.d`. Now create/edit `/etc/systemd/system/docker.service.d/http-proxy.conf` and add following lines
```
[Service]
Environment="HTTP_PROXY=http://172.27.10.67:3128"
Environment="HTTPS_PROXY=http://172.27.10.67:3128"
Environment="NO_PROXY=localhost,127.0.0.1"
```
Use the following commands to reload the docker service and verify the settings
```
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl show --property=Environment docker
```

## Remote Desktop
```
sudo apt install tightvncserver
vncserver 
vncserver -kill :1
mv ~/.vnc/xstartup ~/.vnc/xstartup.bak
```
Now add the following lines in `~/.vnc/xstartup`
```
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
```

```
chmod +x ~/.vnc/xstartup
vncserver 
nmap
nmap 127.0.0.1
```


## Use the following commands
```
sudo apt update
## Useful packages
sudo apt install openssh-server git -y
## Useful network-tools
sudo apt install nmap lynx traceroute net-tools iputils-ping telnet iptables curl wget  nmap -y
## Kernel headers
sudo apt install linux-headers-$(uname -r)
sudo apt install ubuntu-desktop -y
```

# GUI with noVNC and TightVNC
## Install and configure server
```
sudo apt update
sudo apt install xfce4 xfce4-goodies
sudo apt install tightvncserver
vncserver
sudo snap install novnc
sudo snap set novnc services.n6082.listen=6082 services.n6082.vnc=localhost:5901
sudo snap get novnc services.n6082
novnc --listen 6081 --vnc localhost:5901
```
## Connect to the server over SSH tunnel
### Scenario
```
                      ┌───────────┐                                        
                      │           │Internal Network Facing Interface       
                      │    PUB    ├─────────────────────────────────────┐  
                      │           │                                     │  
                      └────┬──────┘                                     │  
                           │                                            │  
             Public Facing │Interface                                   │  
                           │                                            │  
                           │                                         ┌──┴─┐
                           │                                         │INT │
                        ┌──┴─────┐                                   │    │
                        │Internet│                                   └────┘
                        └────────┘                                         
```
Select a VNC service forwarding port (i.e. <FWD_PORT>)
### Relevant Commands
```
# Terminal-1:
ssh -J <PUB_Uname>@<PUB_IP>:<PUB_SSH_PORT>  <INT_Uname>@<INT_IP>
novnc --listen 6081 --vnc localhost:5901
# Terminal-2:
ssh -L <FWD_PORT>:<INT_IP>:6081 -p <PUB_SSH_PORT> <PUB_IP> -l gateway -N
# Firefox:
http://localhost:<FWD_PORT>/vnc.html
```
# GUI with noVNC and TigerVNC
## Install and configure server
Use the following commands
```
sudo apt install tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer -y
sudo apt install ubuntu-gnome-desktop -y
sudo systemctl enable gdm
sudo systemctl start gdm
nano ~/.vnc/xstartup
```
Add the following at the end of file
```
#####
[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
vncconfig -iconic &
dbus-launch --exit-with-session gnome-session &
##############################
```
Use the following commands
```
vncserver 
## Check VNC server
pgrep Xtigervnc
ss -tulpn | grep -E -i 'vnc|590'
telnet 127.0.0.1 5902
novnc --listen 6081 --vnc localhost:5902
```
## Connect to the server over SSH tunnel
### Scenario
```
                      ┌───────────┐                                        
                      │           │Internal Network Facing Interface       
                      │    PUB    ├─────────────────────────────────────┐  
                      │           │                                     │  
                      └────┬──────┘                                     │  
                           │                                            │  
             Public Facing │Interface                                   │  
                           │                                            │  
                           │                                         ┌──┴─┐
                           │                                         │INT │
                        ┌──┴─────┐                                   │    │
                        │Internet│                                   └────┘
                        └────────┘                                         
```
Select a VNC service forwarding port (i.e. <FWD_PORT>)
### Relevant Commands
```
# Terminal-1:
ssh -J <PUB_Uname>@<PUB_IP>:<PUB_SSH_PORT>  <INT_Uname>@<INT_IP>
novnc --listen 6081 --vnc localhost:5901
# Terminal-2:
ssh -L <FWD_PORT>:<INT_IP>:6081 -p <PUB_SSH_PORT> <PUB_IP> -l gateway -N
# Firefox:
http://localhost:<FWD_PORT>/vnc.html
```
