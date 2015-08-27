# kaanalnet
Virtual Network Emulator for SDN and traditional networks 


Features:

Virtualization   -  LXC 
Switch  -           OpenVSwitch, Bridge


How to Run
---

To know the command line options

 # npm start -- -h
 
 nodejs lib/app.js "-h"

-h view this help
-l logfile (ex: /var/log/vnetlabs.log)
-z log level: trace, debug, info, warn, error
-C sdn controller ip (eg " loalhost:6633)
-S switch type ('openvswitch' or 'linuxbridge')
-W wan subnet 
-L Lan subnet
-M Mgmt subnet
-I Lxc image name (eg: "node")  


Start the application with openvswitch switch, and Lxc image name "device" and No SDN Controller (default openvswitch behavior)

 # npm start -- -z debug -S openvswitch -I device







