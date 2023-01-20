### Created by Abhishek Thakur AbhishekT@idrbt.ac.in, and Subhrendu Chattopadhyay subhrendu@idrbt.ac.in
# Procedure to install Devstack on Ubuntu 20.04
## as regular user
Create a user named `stack`
1. `sudo useradd -s /bin/bash -d /opt/stack -m stack`
1. `sudo chmod +x /opt/stack`
1. `echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack`
1. `sudo -u stack -i`

## as user stack
1. `sudo mkdir stack`
1. `sudo chmod 777 stack`
1. `cd stack`
1. `git clone https://opendev.org/openstack/devstack --branch stable/yoga`
1. `cd devstack/`
1. `git clone https://git.openstack.org/openstack/neutron-lbaas /opt/stack/neutron-lbaas --branch stable/yoga`
1. `git clone https://opendev.org/openstack/keystone.git /opt/stack/keystone --branch stable/yoga`
1. `git clone https://opendev.org/openstack/glance.git /opt/stack/glance --branch stable/yoga`
1. `git clone https://opendev.org/openstack/placement.git /opt/stack/placement --branch stable/yoga`
1. `git clone https://opendev.org/openstack/horizon.git /opt/stack/horizon --branch stable/yoga`
1. `git clone https://opendev.org/x/fenix.git /opt/stack/fenix --branch master`

## Modify the contents of `local.conf` as follows
```
   [[local|localrc]]
   HOST_IP=172.27.5.38

   ADMIN_PASSWORD=devstack
   MYSQL_PASSWORD=devstack
   RABBIT_PASSWORD=devstack
   SERVICE_PASSWORD=$ADMIN_PASSWORD
   SERVICE_TOKEN=devstack

   PIP_USE_MIRRORS=False
   USE_GET_PIP=1

   LOGFILE=$DEST/logs/stack.sh.log
   VERBOSE=True
   ENABLE_DEBUG_LOG_LEVEL=True
   ENABLE_VERBOSE_LOG_LEVEL=True

   # Neutron ML2 with OpenVSwitch
   Q_PLUGIN=ml2
   Q_AGENT=ovn

   # Disable security groups
   LIBVIRT_FIREWALL_DRIVER=nova.virt.firewall.NoopFirewallDriver

   # Enable neutron, heat, networking-sfc, barbican and mistral
   enable_plugin neutron https://opendev.org/openstack/neutron stable/yoga
   enable_plugin heat https://opendev.org/openstack/heat stable/yoga
   enable_plugin networking-sfc https://opendev.org/openstack/networking-sfc stable/yoga
   enable_plugin barbican https://opendev.org/openstack/barbican stable/yoga
   enable_plugin mistral https://opendev.org/openstack/mistral stable/yoga

   # Ceilometer
   #CEILOMETER_PIPELINE_INTERVAL=300
   enable_plugin ceilometer https://opendev.org/openstack/ceilometer stable/yoga
   enable_plugin aodh https://opendev.org/openstack/aodh stable/yoga


   # Blazar
   enable_plugin blazar https://github.com/openstack/blazar.git stable/yoga

   # Fenix
   enable_plugin fenix https://opendev.org/x/fenix.git master

   # Tacker
   enable_plugin tacker https://opendev.org/openstack/tacker stable/yoga

   enable_service n-novnc
   enable_service n-cauth

   disable_service tempest

   # Enable kuryr-kubernetes, docker, octavia
   KUBERNETES_VIM=True
   enable_plugin kuryr-kubernetes https://opendev.org/openstack/kuryr-kubernetes stable/yoga
   enable_plugin octavia https://opendev.org/openstack/octavia stable/yoga
   enable_plugin devstack-plugin-container https://opendev.org/openstack/devstack-plugin-container stable/yoga
   #KURYR_K8S_CLUSTER_IP_RANGE="10.0.0.0/24"

   enable_service kubernetes-master
   enable_service kuryr-kubernetes
   enable_service kuryr-daemon

   [[post-config|/etc/neutron/dhcp_agent.ini]]
   [DEFAULT]
   enable_isolated_metadata = True

   [[post-config|$OCTAVIA_CONF]]
   [controller_worker]
   amp_active_retries=9999
```

  111  sudo apt install net-tools
  112  cd /tmp
  113  wget https://packages.cloud.google.com/apt/doc/apt-key.gpg
  114  ls
  115  sudo apt-key add apt-key.gpg
  116  cd -

put following lines in stack.sh after 1075 - for each big step
+echo "\n\n\n\n\n\n==================  AT location $LINENO\n\n\n\n\n\n"; sleep 100
+echo "\n\n\n\n\n\n==================  AT location $LINENO\n\n\n\n\n\n"; sleep 100

Following is to start the stack – repeat only after clean+ unstack+ reboot
  203  ./stack.sh
  204  ./clean.sh
  205  ./unstack.sh
  206  sudo reboot now


Following may need to be repeated a few times
119  pushd /opt/stack/kuryr-kubernetes
  120  docker build -t kuryr/controller -f controller.Dockerfile .
  246  docker build -t kuryr/cni -f cni.Dockerfile .
  129  popd


  215  vi lib/neutron_plugins/ovn_agent; #8 changes OVS to OVN
  216  git diff lib/neutron_plugins/ovn_agent
@@ -697,17 +697,17 @@ function start_ovn {
         fi

         # Wait for the service to be ready
-        wait_for_sock_file $OVS_RUNDIR/ovnnb_db.sock
-        wait_for_sock_file $OVS_RUNDIR/ovnsb_db.sock
+        wait_for_sock_file $OVN_RUNDIR/ovnnb_db.sock
+        wait_for_sock_file $OVN_RUNDIR/ovnsb_db.sock

         if is_service_enabled tls-proxy; then
-            sudo ovn-nbctl --db=unix:$OVS_RUNDIR/ovnnb_db.sock set-ssl $INT_CA_DIR/private/$DEVSTACK_CERT_NAME.key $INT_CA_DIR/$DEVSTACK_CERT_NAME.crt $INT_CA_DIR/ca-chain.pem
-            sudo ovn-sbctl --db=unix:$OVS_RUNDIR/ovnsb_db.sock set-ssl $INT_CA_DIR/private/$DEVSTACK_CERT_NAME.key $INT_CA_DIR/$DEVSTACK_CERT_NAME.crt $INT_CA_DIR/ca-chain.pem
+            sudo ovn-nbctl --db=unix:$OVN_RUNDIR/ovnnb_db.sock set-ssl $INT_CA_DIR/private/$DEVSTACK_CERT_NAME.key $INT_CA_DIR/$DEVSTACK_CERT_NAME.crt $INT_CA_DIR/ca-chain.pem
+            sudo ovn-sbctl --db=unix:$OVN_RUNDIR/ovnsb_db.sock set-ssl $INT_CA_DIR/private/$DEVSTACK_CERT_NAME.key $INT_CA_DIR/$DEVSTACK_CERT_NAME.crt $INT_CA_DIR/ca-chain.pem
         fi
-        sudo ovn-nbctl --db=unix:$OVS_RUNDIR/ovnnb_db.sock set-connection p${OVN_PROTO}:6641:$SERVICE_LISTEN_ADDRESS -- set connection . inactivity_probe=60000
-        sudo ovn-sbctl --db=unix:$OVS_RUNDIR/ovnsb_db.sock set-connection p${OVN_PROTO}:6642:$SERVICE_LISTEN_ADDRESS -- set connection . inactivity_probe=60000
-        sudo ovs-appctl -t $OVS_RUNDIR/ovnnb_db.ctl vlog/set console:off syslog:$OVN_DBS_LOG_LEVEL file:$OVN_DBS_LOG_LEVEL
-        sudo ovs-appctl -t $OVS_RUNDIR/ovnsb_db.ctl vlog/set console:off syslog:$OVN_DBS_LOG_LEVEL file:$OVN_DBS_LOG_LEVEL
+        sudo ovn-nbctl --db=unix:$OVN_RUNDIR/ovnnb_db.sock set-connection p${OVN_PROTO}:6641:$SERVICE_LISTEN_ADDRESS -- set connection . inactivity_probe=60000
+        sudo ovn-sbctl --db=unix:$OVN_RUNDIR/ovnsb_db.sock set-connection p${OVN_PROTO}:6642:$SERVICE_LISTEN_ADDRESS -- set connection . inactivity_probe=60000
+        sudo ovs-appctl -t $OVN_RUNDIR/ovnnb_db.ctl vlog/set console:off syslog:$OVN_DBS_LOG_LEVEL file:$OVN_DBS_LOG_LEVEL
+        sudo ovs-appctl -t $OVN_RUNDIR/ovnsb_db.ctl vlog/set console:off syslog:$OVN_DBS_LOG_LEVEL file:$OVN_DBS_LOG_LEVEL
     fi

  285  cat ~/.docker/config.json
{
"proxies":
{
   "default":
   {
     "httpProxy": "http://172.27.10.67:3128",
     "httpsProxy": "http://172.27.10.67:3128",
     "noProxy": "*.test.example.com,.example2.com,172.27.5.38,172.27.5.39,172.27.5.37,127.0.0.0/8"
   }
}
}



  
    291 env
SHELL=/bin/bash
SUDO_GID=1000
no_proxy=localhost,127.0.0.1,::1,172.27.5.38,172.27.5.39,172.27.5.37
LANGUAGE=en_IN:en
SUDO_COMMAND=/usr/bin/su stack
SUDO_USER=idrbt
PWD=/home/idrbt/stack/devstack
LOGNAME=stack
ftp_proxy=http://172.27.10.67:3128/
HOME=/opt/stack
LANG=en_IN
LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:
https_proxy=http://172.27.10.67:3128/
TERM=xterm
USER=stack
SHLVL=1
http_proxy=http://172.27.10.67:3128/
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
SUDO_UID=1000
MAIL=/var/mail/stack
_=/usr/bin/env
OLDPWD=/home/idrbt