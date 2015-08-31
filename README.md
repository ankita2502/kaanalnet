# kaanalnet

Virtual Network Emulator for SDN and traditional networks 

Its a Network Emulator application, built with Linux Containers, Linux Bridge, OpenvSwitch.

The Goal of the project is, create a test platform for SDN  which aims to cover all the basic & advanced use cases of SDN (such as mix of SDN and traditional network components, service chaining etc), provides the Traffic Test support, REST API exposures etc.


NOTE: PLEASE DO ALL(INSTALLATION & EXECUTION) THE ACTIVITY AS  ROOT USER.

# 1.Installation

Note : Currently supported only on DEBIAN flavors (Tested only on UBUNTU 14.04)

Dependent packages (lxc,openvswitch,linuxbridge and ubuntu linux container) will be installed as part of this node package installation, Hence  ROOT access is required.
## a. npm 
    #npm install kaanalnet

Installation will take approx 15-30mins to complete.


## b. manual
    git clone https://github.com/sureshkvl/kaanalnet
    cd kaanalnet
    npm install
    node scripts/postinstall.js


# 2.Start the Application 

## a.Checklist before start the application:

    1. check "lxc","openvswitch-switch" packages are installed by using the below commands.
        dpkg-query -s lxc
        dpkg-query -s openvswitch-switch
        
         If not installed, 
         install with "apt-get install lxc openvswitch-switch"
    2. check "lxc-ls --fancy" command, and ensure "nodeimg"(the default image name) is present.
        If not present, Execute the below command to create a image.
        lxc-create -t ubuntu -n nodeimg

    3. start the nodeimg and login. (username : ubuntu password: ubuntu)
            lxcstart -n nodeimg
       Ensure you are able to login via ssh also.. 

       once checked, stop the "nodeimg" container as below,
            lxcstop -n nodeimg

    3. The default lxc bridge ip range is 10.0.3.0. To check,
       ifconfig lxcbr0  
    
       If not 10.0.3.0 subnet, then the correct IP Range should be given "-M Mgmt subnet" as parameter during the application  start


## b.Command line options:
To know the command line options

    # npm start -- -h
    kaanalnet@0.0.4 start /root/node_modules/kaanalnet
    nodejs lib/app.js "-h"
    -h vew this help
    -l logfile (default: /var/log/kaanalnet.log)
    -z log level: (trace, debug, info, warn, error -  default value: info)
    -C sdn controller ip (Ex: tcp:0.0.0.0:6633 -   No default values)  
    -S switch type (openvswitch' or linuxbridge , default : linuxbridge)
    -W wan subnet (default - 172.17.1.0)
    -L Lan subnet (default - 10.10.10.0)
    -M Mgmt subnet (default - 10.0.3.0)
    -I Lxc image name (default: "nodeimg")


## c.Traditional network:

### i) Start the application with default values


     # npm start 
    > kaanalnet@0.0.4 start /root/node_modules/kaanalnet
    > nodejs lib/app.js
    System Configuration {"logfile":"/var/log/kaanalnet.log","loglevel":"info","controller":null,"switchtype":"linuxbridge","virtualization":"lxc","wansubnet":"172.27.1.0","lansubnet":"10.10.10.0","mgmtsubnet":"10.0.3.0","lxcimage":"nodeimg"}
    kaanalNet listening on port : 5050.....


### ii) Start the application with openvswitch and different imagename
    # npm start -- -z debug -S openvswitch -I device
    > kaanalnet@0.0.4 start /root/kaanalnet
    > nodejs lib/app.js "-z" "debug" "-S" "openvswitch" "-I" "device"
    System Configuration {"logfile":"/var/log/kaanalnet.log","loglevel":"debug","controller":null,"switchtype":"openvswitch","virtualization":"lxc","wansubnet":"172.27.1.0","lansubnet":"10.10.10.0","mgmtsubnet":"10.0.3.0","lxcimage":"device"}
    kaanalNet listening on port : 5050.....


## d. SDN Network:

Note: Linux bridge doesnt support openflow, hence only openvswitch to be used for SDN network

Start the SDN Controller(Ex: opendaylight) and ensure it is running.

    
    # npm start -- -z debug -S openvswitch -I device -C tcp:0.0.0.0:6633
    > kaanalnet@0.0.4 start /root/node_modules/kaanalnet
    > nodejs lib/app.js "-z" "debug" "-S" "openvswitch" "-I" "device" "-C" "tcp:0.0.0.0:6633"
    System Configuration {"logfile":"/var/log/kaanalnet.log","loglevel":"debug","controller":"tcp:0.0.0.0:6633","switchtype":"openvswitch","virtualization":"lxc","wansubnet":"172.27.1.0","lansubnet":"10.10.10.0","mgmtsubnet":"10.0.3.0","lxcimage":"device"}
    kaanalNet listening on port : 5050.....


# 3.REST APIs

KaanalNet works based on the REST APIs. RESTAPI document is available in

https://github.com/sureshkvl/kaanalnet/blob/master/RestAPIs.md

Sample Topology examples are located in 

https://github.com/sureshkvl/kaanalnet/tree/master/docs/topology-apis


# 4.How to use the Emulator

1. start the kaanalnet application as mentioned in chapter(2)
2. Use the REST Client(CHROME PostMAN, Curl,etc) to post the topology.REST API guide have the detailed information about topology creation status etc.
3. Once topology is created, SSH to the Nodes via Mgmt IP and ping other Nodes.
4. lxc command line tool and openvswitch command line utilities can be used to understand the topology.
