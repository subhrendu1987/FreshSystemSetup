# FreshSystemSetup
## Use the following commands
```
sudo apt update
## Useful packages
sudo apt install openssh-server git -y
## Useful network-tools
sudo apt install nmap lynx traceroute net-tools -y
```
## Proxy settings
### Add the following lines to ~/.bashrc
```
# Set Proxy
function setproxy() {
    export {http,https,ftp,HTTP,HTTPS}_proxy="http://172.27.10.67:3128/"
}

# Unset Proxy
function unsetproxy() {
    unset {http,https,ftp,HTTP,HTTPS}_proxy
}
```
### Add the following lines to /etc/apt/apt.conf
```
Acquire::http::Proxy "http://172.27.10.67:3128/";
Acquire::https::Proxy "http://172.27.10.67:3128/";
```