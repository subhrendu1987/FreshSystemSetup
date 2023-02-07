# FreshSystemSetup
## Proxy settings for IDRBT
### Add the following lines to ~/.bashrc
```
# Set Proxy
function setproxy() {
    export {http,https,ftp,HTTP,HTTPS}_proxy="http://172.27.10.67:3128/"
    sudo snap set system proxy.http="http://172.27.10.67:3128"
    sudo snap set system proxy.http="http://172.27.10.67:3128"
}

# Unset Proxy
function unsetproxy() {
    unset {http,https,ftp,HTTP,HTTPS}_proxy
    sudo snap set system proxy.http=""
    sudo snap set system proxy.http=""
}

#gping
function gping(){
    #ips=($(hostname -I))
    #for ip in "${ips[@]}"
    #do
    #    echo $ip
    #done
    #for %%i in 200 to 254 do ping 10.1.1.%%i
    #done

    IFS=($(ip a | grep -o '^[[:digit:]]*[:][[:alnum:][:space:]]*:'| awk -F  ':' '/1/ {print $2}'|tr -d ' '))
    for iface in "${IFS[@]}"
    do
        ip_mask=($(ip -f inet addr show $iface | grep inet|awk -F' ' '{print $2}'))  ### IP address with subnet mask
        #ip=$(echo $ip_mask |awk -F'/' '{print $2}')); mask=$2
        all_ips=($(nmap -sL -n $ip_mask | awk '/Nmap scan report/{print $NF}'))
        for target in "${all_ips[@]}"
        do
            ping $target -c1 2>&1 >/dev/null
            #op=($(ping $target -c1))
            rc=$?
            if [[ $rc -eq 0 ]] ; then
                echo $target" is reachable via "$iface
            fi
        done
    done
}

setproxy
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
sudo apt install ubuntu-desktop -y
```
