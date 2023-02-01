# FreshSystemSetup
## Proxy settings for IDRBT
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

#gping
function gping(){
    IFS=($(ip a | grep -o '^[[:digit:]]*[:][[:alnum:][:space:]]*:'| awk -F  ':' '/1/ {print $2}'|tr -d ' '))
    ips=($(hostname -I))
    for ip in "${ips[@]}"
    do
        echo $ip
    done
    for %%i in 200 to 254 do ping 10.1.1.%%i 

}
```
### Add the following lines to /etc/apt/apt.conf
```
Acquire::http::Proxy "http://172.27.10.67:3128/";
Acquire::https::Proxy "http://172.27.10.67:3128/";
```


## Use the following commands
```
sudo apt update
## Useful packages
sudo apt install openssh-server git -y
## Useful network-tools
sudo apt install nmap lynx traceroute net-tools -y

```
