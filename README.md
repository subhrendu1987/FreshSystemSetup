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
