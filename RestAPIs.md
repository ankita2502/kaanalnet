#Topology REST APIs

## 1. POST /Topology

This API creates a new Topology. The input JSON data majorly divides in 3 sections - switches, nodes, links.

This API returns the topology ID, this  ID will be used by other APIs.

This API is async API. It returns the data immediately and started creating the topology in the backend..It might take 2-3 mins to create the topology. Refer GET /Topology to retrive the status of the topology creation.

Example :

    URL :  http://localhost:5050/Topology

Request data    

    { 
      "name":"testtopology", 
      "switches":[
      { "name":"sw1","type":"lan"},
      { "name":"sw2","type":"lan"}
      ],        
      "nodes":[
      { "name":"n1"},
      { "name":"n2"}
      ],
      "links":[
      {
      "type":"lan",
      "switches":[
         { "name":"sw1","connected_nodes":[{"name":"n1","config":{"bandwidth":"256kbit","latency":"10ms","pktloss":"2%","jitter":"10ms"}}],"connected_switches":[{"name":"sw2"}] },
         { "name":"sw2", "connected_nodes":[{"name":"n2"}] }
        ]
      }    
      ]  
    }

Response Data:

    {
    "id": "2bbf9115-34d8-4789-bae9-ef9fdda52b3d",
    "data": {
    "name": "testtopology",
    "switches": [
      {
        "name": "sw1",
        "type": "lan",
        "make": "openvswitch"
      },
      {
        "name": "sw2",
        "type": "lan",
        "make": "openvswitch"
      }
    ],
    "nodes": [
      {
        "name": "n1",
        "virtualization": "lxc",
        "image": "device"
      },
      {
        "name": "n2",
        "virtualization": "lxc",
        "image": "device"
      }
    ],
    "links": [
      {
        "type": "lan",
        "switches": [
          {
            "name": "sw1",
            "connected_nodes": [
              {
                "name": "n1",
                "config": {
                  "bandwidth": "256kbit",
                  "latency": "10ms",
                  "pktloss": "2%",
                  "jitter": "10ms"
                }
              }
            ],
            "connected_switches": [
              {
                "name": "sw2"
              }
            ]
          },
          {
            "name": "sw2",
            "connected_nodes": [
              {
                "name": "n2"
              }
            ]
          }
        ]
      }
    ]
      },
    "saved": false
    }



## 2. GET /Topology/:id


This API, retrives the status Topology creation details and individual device details. (Device ID will be used for controlling the device by Device specific APIs)

Example :

    URL :   http://localhost:5050/Topology/2bbf9115-34d8-4789-bae9-ef9fdda52b3d

Response Data :

    {
      "nodes": [
    {
      "id": "88ab4406-7296-4c31-b9c5-ebb9ed9c3e4c",
      "config": {
        "image": "device",
        "virtualization": "lxc",
        "name": "n1",
        "ifmap": [
          {
            "ifname": "eth0",
            "hwAddress": "00:00:00:00:00:11",
            "ipaddress": "10.0.3.2",
            "netmask": "255.255.255.0",
            "type": "mgmt"
          },
          {
            "ifname": "eth1",
            "hwAddress": "00:00:00:00:00:13",
            "brname": "sw1",
            "ipaddress": "10.10.10.1",
            "netmask": "255.255.255.224",
            "gateway": "10.10.10.1",
            "type": "lan",
            "veth": "n1_veth1",
            "config": {
              "bandwidth": "256kbit",
              "latency": "10ms",
              "pktloss": "2%",
              "jitter": "10ms"
            }
          }
        ],
        "status": "started",
        "id": "88ab4406-7296-4c31-b9c5-ebb9ed9c3e4c"
      }
    },
    {
      "id": "6bb21df3-8585-42b3-88c1-86aff8a52547",
      "config": {
        "image": "device",
        "virtualization": "lxc",
        "name": "n2",
        "ifmap": [
          {
            "ifname": "eth0",
            "hwAddress": "00:00:00:00:00:12",
            "ipaddress": "10.0.3.3",
            "netmask": "255.255.255.0",
            "type": "mgmt"
          },
          {
            "ifname": "eth1",
            "hwAddress": "00:00:00:00:00:14",
            "brname": "sw2",
            "ipaddress": "10.10.10.2",
            "netmask": "255.255.255.224",
            "gateway": "10.10.10.1",
            "type": "lan",
            "veth": "n2_veth1"
          }
        ],
        "status": "started",
        "id": "6bb21df3-8585-42b3-88c1-86aff8a52547"
      }
    }
      ],
      "switches": [
    {
      "uuid": "4434d3fb-cdde-4669-8136-ba88abcfa1e9",
      "config": {
        "make": "openvswitch",
        "type": "lan",
        "name": "sw1",
        "status": "started"
      }
    },
    {
      "uuid": "0818bef0-7746-4a1b-bc13-2b7282b82a08",
      "config": {
        "make": "openvswitch",
        "type": "lan",
        "name": "sw2",
        "status": "started"
      }
    }
      ]
    }

Note:  In the response data ,all Node and Switch "status" should be "started". It means the devices are created and running fine.  



## 3. DELETE /Topology/:id

This API deletes the topology..It deletes the Nodes,switches,links 

Ex:

    URL : http://localhost:5050/Topology/2bbf9115-34d8-4789-bae9-ef9fdda52b3d

Response Data :

    {
    "id": "2bbf9115-34d8-4789-bae9-ef9fdda52b3d",
      "status": "deleted"
    }



#Device specific REST APIs

Only Nodes are supported.  Switches are not yet supported.
Device ID (:did) can be retrived by GET /Topology/:id API

## 1. GET /Topology/:id/Device/:did

Retrives the details and status of the device.


Example:

    URL :  http://localhost:5050/Topology/6d742db4-c121-4ddd-8c13-d5c83bd93996/Device/815ddb9b-2152-40d1-9c97-16152c9cf10b

Response data :

    {
      "id": "815ddb9b-2152-40d1-9c97-16152c9cf10b",
      "data": {
    "image": "device",
    "virtualization": "lxc",
    "name": "n1",
    "ifmap": [
      {
        "ifname": "eth0",
        "hwAddress": "00:00:00:00:00:15",
        "ipaddress": "10.0.3.2",
        "netmask": "255.255.255.0",
        "type": "mgmt"
      },
      {
        "ifname": "eth1",
        "hwAddress": "00:00:00:00:00:17",
        "brname": "sw1",
        "ipaddress": "10.10.10.1",
        "netmask": "255.255.255.224",
        "gateway": "10.10.10.1",
        "type": "lan",
        "veth": "n1_veth1",
        "config": {
          "bandwidth": "256kbit",
          "latency": "10ms",
          "pktloss": "2%",
          "jitter": "10ms"
        }
      }
    ],
    "status": "started",
    "id": "815ddb9b-2152-40d1-9c97-16152c9cf10b"
      },
    "saved": false
    }


## 2. DELETE /Topology/:id/Device/:did
Deletes the device.


##3. PUT /Topology/:id/Device/:did/stop
stops the device temporarily, which can be started again by Start API.

Example :

    URL :  http://localhost:5050/Topology/6d742db4-c121-4ddd-8c13-d5c83bd93996/Device/815ddb9b-2152-40d1-9c97-16152c9cf10b/stop

Response data:

    {
    "id": "815ddb9b-2152-40d1-9c97-16152c9cf10b",
      "status": "stopped"
    }


## 4. PUT /Topology/:id/Device/:did/Start
Starts the device.

Example : 
 

    URL:    http://localhost:5050/Topology/6d742db4-c121-4ddd-8c13-d5c83bd93996/Device/815ddb9b-2152-40d1-9c97-16152c9cf10b/start

Response data:

    {  
    "id": "815ddb9b-2152-40d1-9c97-16152c9cf10b",
    "status": "started"
    }

