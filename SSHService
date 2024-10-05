# Expose any system
## Get AWS machine with public IP or SSH server with public IP
* Say the machine has the following configuration
  * GwIP: `103.196.191.175` [Gateway IP/ Public IP]
  * GWport: `4444` [Gateway SSH Port]
  * GWuserName: `gateway` [Gateway Username]
## The intended configuration is as following
```
[Private M/C] <-----------------> [AWS/Public IP] <--------------------> [Client]
                                    [GateWay]
```
## Create Reverse Proxy Tunnel
### Open reverse Tunnel from the private machine 
* ReverseTunPort: `9000`
* PriMcPort: `22` [Private M/C SSH Port]
* PriUname: `subhrendu` [Username in Private M/C]
```
ssh -R <ReverseTunPort>:localhost:<PriMcPort> <GWuserName>@<GwIP> -p <GWport>
```
e.g.
```
ssh -R 9000:localhost:22 gateway@103.196.191.175 -p 4444
```
* Access from any system
```
ssh -J <GWuserName>@<GwIP>:<GWport> <PriUname>@localhost -p <ReverseTunPort>
```
e.g.
```
ssh -J gateway@103.196.191.175:4444 subhrendu@localhost -p 9000
```
