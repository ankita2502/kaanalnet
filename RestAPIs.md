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



# Test APIs

## Ping Test


1. Post /Topology/:id/Test
Example :

http://localhost:5050/Topology/44264229-fb79-468b-80bb-e3a608fa25f3/Test

Request Data :

{
    "name":"sampletest",
    "tests":[
        {
            "sourcenodes":["n1"],
            "destnodes":["n2"],
            "traffictype":"ping",
            "starttime":"0",
            "duration":"60",
            "trafficconfig":
            {
                "adaptive":"yes",
                "flood":"no",
                "count":60,
                "packetsize":100,
                "interval":100
            }
        },
        {
            "sourcenodes":["n1"],
            "destnodes":["n3"],
            "traffictype":"ping",
            "starttime":"0",
            "duration":"60",
            "trafficconfig":
            {
                "adaptive":"yes",
                "flood":"no",
                "count":60,
                "packetsize":100,
                "interval":100
            }
        },
        {
            "sourcenodes":["n1"],
            "destnodes":["n4"],
            "traffictype":"ping",
            "starttime":"0",
            "duration":"60",
            "trafficconfig":
            {
                "adaptive":"yes",
                "flood":"no",
                "count":60,
                "packetsize":100,
                "interval":100
            }
        }
        
        
        ]
}


Response Data :

{
  "id": "97cd4ab3-fa75-462f-b479-6b0529ee68b4",
  "data": {
    "name": "sampletest",
    "tests": [
      {
        "sourcenodes": [
          "n1"
        ],
        "destnodes": [
          "n2"
        ],
        "traffictype": "ping",
        "starttime": "0",
        "duration": "60",
        "trafficconfig": {
          "adaptive": "yes",
          "flood": "no",
          "count": 60,
          "packetsize": 100,
          "interval": 100
        }
      },
      {
        "sourcenodes": [
          "n1"
        ],
        "destnodes": [
          "n3"
        ],
        "traffictype": "ping",
        "starttime": "0",
        "duration": "60",
        "trafficconfig": {
          "adaptive": "yes",
          "flood": "no",
          "count": 60,
          "packetsize": 100,
          "interval": 100
        }
      },
      {
        "sourcenodes": [
          "n1"
        ],
        "destnodes": [
          "n4"
        ],
        "traffictype": "ping",
        "starttime": "0",
        "duration": "60",
        "trafficconfig": {
          "adaptive": "yes",
          "flood": "no",
          "count": 60,
          "packetsize": 100,
          "interval": 100
        }
      }
    ]
  },
  "saved": false
}


2. Get Test Status

Get /Topology/:id/Test/:tid

http://localhost:5050/Topology/44264229-fb79-468b-80bb-e3a608fa25f3/Test/97cd4ab3-fa75-462f-b479-6b0529ee68b4

Response Data:

[
  {
    "testsuiteid": "a61e8512-2402-4588-902a-228d7b44e0b1",
    "name": "test_10.0.3.2_10.10.10.2",
    "source": "10.0.3.2",
    "destination": "10.10.10.2",
    "type": "ping",
    "starttime": "0",
    "duration": "60",
    "config": {
      "adaptive": "yes",
      "flood": "no",
      "count": 60,
      "packetsize": 100,
      "interval": 100
    },
    "createdTime": "2015-09-01T10:23:35.030Z",
    "startedTime": "2015-09-01T10:23:35.035Z",
    "status": "completed",
    "testResult": {
      "transmitted": "60 packets transmitted",
      "received": " 59 received",
      "packetloss": " 1% packet loss",
      "totaltime": " time 9597ms",
      "rtt_min": "rtt min/avg/max/mdev = 1.474/42.199/1049.751/133.312 ms",
      "rtt_max": "rtt min/avg/max/mdev = 1.474/42.199/1049.751/133.312 ms",
      "rtt_avg": "rtt min/avg/max/mdev = 1.474/42.199/1049.751/133.312 ms",
      "rtt_mdev": "rtt min/avg/max/mdev = 1.474/42.199/1049.751/133.312 ms",
      "ipg": " pipe 3",
      "ewma": " pipe 3"
    },
    "completedTime": "2015-09-01T10:23:46.893Z"
  },
  {
    "testsuiteid": "a61e8512-2402-4588-902a-228d7b44e0b1",
    "name": "test_10.0.3.2_10.10.10.3",
    "source": "10.0.3.2",
    "destination": "10.10.10.3",
    "type": "ping",
    "starttime": "0",
    "duration": "60",
    "config": {
      "adaptive": "yes",
      "flood": "no",
      "count": 60,
      "packetsize": 100,
      "interval": 100
    },
    "createdTime": "2015-09-01T10:23:35.048Z",
    "startedTime": "2015-09-01T10:23:35.049Z",
    "status": "completed",
    "testResult": {
      "transmitted": "60 packets transmitted",
      "received": " 60 received",
      "packetloss": " 0% packet loss",
      "totaltime": " time 2281ms",
      "rtt_min": "rtt min/avg/max/mdev = 5.499/32.665/127.439/20.989 ms",
      "rtt_max": "rtt min/avg/max/mdev = 5.499/32.665/127.439/20.989 ms",
      "rtt_avg": "rtt min/avg/max/mdev = 5.499/32.665/127.439/20.989 ms",
      "rtt_mdev": "rtt min/avg/max/mdev = 5.499/32.665/127.439/20.989 ms",
      "ipg": " pipe 4",
      "ewma": " pipe 4"
    },
    "completedTime": "2015-09-01T10:23:37.507Z"
  },
  {
    "testsuiteid": "a61e8512-2402-4588-902a-228d7b44e0b1",
    "name": "test_10.0.3.2_10.10.10.4",
    "source": "10.0.3.2",
    "destination": "10.10.10.4",
    "type": "ping",
    "starttime": "0",
    "duration": "60",
    "config": {
      "adaptive": "yes",
      "flood": "no",
      "count": 60,
      "packetsize": 100,
      "interval": 100
    },
    "createdTime": "2015-09-01T10:23:35.054Z",
    "startedTime": "2015-09-01T10:23:35.054Z",
    "status": "completed",
    "testResult": {
      "transmitted": "60 packets transmitted",
      "received": " 60 received",
      "packetloss": " 0% packet loss",
      "totaltime": " time 1556ms",
      "rtt_min": "rtt min/avg/max/mdev = 0.050/26.105/64.685/14.406 ms",
      "rtt_max": "rtt min/avg/max/mdev = 0.050/26.105/64.685/14.406 ms",
      "rtt_avg": "rtt min/avg/max/mdev = 0.050/26.105/64.685/14.406 ms",
      "rtt_mdev": "rtt min/avg/max/mdev = 0.050/26.105/64.685/14.406 ms",
      "ipg": " pipe 3",
      "ewma": " pipe 3"
    },
    "completedTime": "2015-09-01T10:23:36.771Z"
  },
  {
    "testsuiteid": "97cd4ab3-fa75-462f-b479-6b0529ee68b4",
    "name": "test_10.0.3.2_10.10.10.3",
    "source": "10.0.3.2",
    "destination": "10.10.10.3",
    "type": "ping",
    "starttime": "0",
    "duration": "60",
    "config": {
      "adaptive": "yes",
      "flood": "no",
      "count": 60,
      "packetsize": 100,
      "interval": 100
    },
    "createdTime": "2015-09-01T10:29:02.551Z",
    "startedTime": "2015-09-01T10:29:02.551Z",
    "status": "completed",
    "testResult": {
      "transmitted": "60 packets transmitted",
      "received": " 60 received",
      "packetloss": " 0% packet loss",
      "totaltime": " time 1408ms",
      "rtt_min": "rtt min/avg/max/mdev = 3.082/23.991/47.969/9.415 ms",
      "rtt_max": "rtt min/avg/max/mdev = 3.082/23.991/47.969/9.415 ms",
      "rtt_avg": "rtt min/avg/max/mdev = 3.082/23.991/47.969/9.415 ms",
      "rtt_mdev": "rtt min/avg/max/mdev = 3.082/23.991/47.969/9.415 ms",
      "ipg": " pipe 3",
      "ewma": " pipe 3"
    },
    "completedTime": "2015-09-01T10:29:03.996Z"
  },
  {
    "testsuiteid": "97cd4ab3-fa75-462f-b479-6b0529ee68b4",
    "name": "test_10.0.3.2_10.10.10.2",
    "source": "10.0.3.2",
    "destination": "10.10.10.2",
    "type": "ping",
    "starttime": "0",
    "duration": "60",
    "config": {
      "adaptive": "yes",
      "flood": "no",
      "count": 60,
      "packetsize": 100,
      "interval": 100
    },
    "createdTime": "2015-09-01T10:29:02.544Z",
    "startedTime": "2015-09-01T10:29:02.544Z",
    "status": "completed",
    "testResult": {
      "transmitted": "60 packets transmitted",
      "received": " 60 received",
      "packetloss": " 0% packet loss",
      "totaltime": " time 1444ms",
      "rtt_min": "rtt min/avg/max/mdev = 0.115/27.617/52.741/11.070 ms",
      "rtt_max": "rtt min/avg/max/mdev = 0.115/27.617/52.741/11.070 ms",
      "rtt_avg": "rtt min/avg/max/mdev = 0.115/27.617/52.741/11.070 ms",
      "rtt_mdev": "rtt min/avg/max/mdev = 0.115/27.617/52.741/11.070 ms",
      "ipg": " pipe 5",
      "ewma": " pipe 5"
    },
    "completedTime": "2015-09-01T10:29:04.017Z"
  },
  {
    "testsuiteid": "97cd4ab3-fa75-462f-b479-6b0529ee68b4",
    "name": "test_10.0.3.2_10.10.10.4",
    "source": "10.0.3.2",
    "destination": "10.10.10.4",
    "type": "ping",
    "starttime": "0",
    "duration": "60",
    "config": {
      "adaptive": "yes",
      "flood": "no",
      "count": 60,
      "packetsize": 100,
      "interval": 100
    },
    "createdTime": "2015-09-01T10:29:02.556Z",
    "startedTime": "2015-09-01T10:29:02.557Z",
    "status": "completed",
    "testResult": {
      "transmitted": "60 packets transmitted",
      "received": " 59 received",
      "packetloss": " 1% packet loss",
      "totaltime": " time 1388ms",
      "rtt_min": "rtt min/avg/max/mdev = 1.920/26.099/72.122/12.425 ms",
      "rtt_max": "rtt min/avg/max/mdev = 1.920/26.099/72.122/12.425 ms",
      "rtt_avg": "rtt min/avg/max/mdev = 1.920/26.099/72.122/12.425 ms",
      "rtt_mdev": "rtt min/avg/max/mdev = 1.920/26.099/72.122/12.425 ms",
      "ipg": " pipe 4",
      "ewma": " pipe 4"
    },
    "completedTime": "2015-09-01T10:29:04.096Z"
  }
]



## TCP Test

1. Post Test
http://localhost:5050/Topology/44264229-fb79-468b-80bb-e3a608fa25f3/Test

Request Data:

{
    "name":"sampletest",
    "tests":[
        {
            "sourcenodes":["n1"],
            "destnodes":["n2"],
            "traffictype":"tcp",
            "starttime":"0",
            "duration":"60",
            "trafficconfig":
            {
            }
        },
        {
            "sourcenodes":["n1"],
            "destnodes":["n3"],
            "traffictype":"tcp",
            "starttime":"0",
            "duration":"60",
            "trafficconfig":
            {
            }
        },
        {
            "sourcenodes":["n1"],
            "destnodes":["n4"],
            "traffictype":"tcp",
            "starttime":"0",
            "duration":"60",
            "trafficconfig":
            {
            }
        }
        
        
        ]
}

Response Data:

{
  "id": "0ba0fff0-3e3c-46c0-9b58-5bf6bdf4f2db",
  "data": {
    "name": "sampletest",
    "tests": [
      {
        "sourcenodes": [
          "n1"
        ],
        "destnodes": [
          "n2"
        ],
        "traffictype": "tcp",
        "starttime": "0",
        "duration": "60",
        "trafficconfig": {}
      },
      {
        "sourcenodes": [
          "n1"
        ],
        "destnodes": [
          "n3"
        ],
        "traffictype": "tcp",
        "starttime": "0",
        "duration": "60",
        "trafficconfig": {}
      },
      {
        "sourcenodes": [
          "n1"
        ],
        "destnodes": [
          "n4"
        ],
        "traffictype": "tcp",
        "starttime": "0",
        "duration": "60",
        "trafficconfig": {}
      }
    ]
  },
  "saved": false
}

Get the test status:

Get  /Topology/:id/Test/:tid

Request :
http://localhost:5050/Topology/0e469af1-f2b8-47a4-a1b3-101cc11e7ef4/Test/0ba0fff0-3e3c-46c0-9b58-5bf6bdf4f2db

Response:

[
  {
    "testsuiteid": "0ba0fff0-3e3c-46c0-9b58-5bf6bdf4f2db",
    "name": "test_10.0.3.2_10.10.10.2",
    "source": "10.0.3.2",
    "destination": "10.10.10.2",
    "type": "tcp",
    "starttime": "0",
    "duration": "60",
    "config": {},
    "createdTime": "2015-09-01T10:41:22.915Z",
    "startedTime": "2015-09-01T10:41:22.919Z",
    "status": "completed",
    "testResult": {
      "date": "20150901161232",
      "senderip": "10.10.10.1",
      "senderport": "55493",
      "receiverip": "10.10.10.2",
      "receiverport": "5001",
      "iperf_test_id": "3",
      "interval": "0.0-68.1",
      "transfer": "1310720",
      "bandwidth": "153970\n"
    },
    "completedTime": "2015-09-01T10:42:32.075Z"
  },
  {
    "testsuiteid": "0ba0fff0-3e3c-46c0-9b58-5bf6bdf4f2db",
    "name": "test_10.0.3.2_10.10.10.3",
    "source": "10.0.3.2",
    "destination": "10.10.10.3",
    "type": "tcp",
    "starttime": "0",
    "duration": "60",
    "config": {},
    "createdTime": "2015-09-01T10:41:22.936Z",
    "startedTime": "2015-09-01T10:41:22.936Z",
    "status": "completed",
    "testResult": {
      "date": "20150901161232",
      "senderip": "10.10.10.1",
      "senderport": "35326",
      "receiverip": "10.10.10.3",
      "receiverport": "5001",
      "iperf_test_id": "3",
      "interval": "0.0-68.2",
      "transfer": "1966080",
      "bandwidth": "230627\n"
    },
    "completedTime": "2015-09-01T10:42:32.231Z"
  },
  {
    "testsuiteid": "0ba0fff0-3e3c-46c0-9b58-5bf6bdf4f2db",
    "name": "test_10.0.3.2_10.10.10.4",
    "source": "10.0.3.2",
    "destination": "10.10.10.4",
    "type": "tcp",
    "starttime": "0",
    "duration": "60",
    "config": {},
    "createdTime": "2015-09-01T10:41:22.941Z",
    "startedTime": "2015-09-01T10:41:22.941Z",
    "status": "completed",
    "testResult": {
      "date": "20150901161228",
      "senderip": "10.10.10.1",
      "senderport": "52687",
      "receiverip": "10.10.10.4",
      "receiverport": "5001",
      "iperf_test_id": "3",
      "interval": "0.0-65.4",
      "transfer": "1966080",
      "bandwidth": "240358\n"
    },
    "completedTime": "2015-09-01T10:42:28.466Z"
  }
]


# UDP Test
1. POST UDP Test

http://localhost:5050/Topology/0e469af1-f2b8-47a4-a1b3-101cc11e7ef4/Test



Request Data :
{
    "name":"sampletest",
    "tests":[
        {
            "sourcenodes":["n1"],
            "destnodes":["n2"],
            "traffictype":"udp",
            "starttime":"0",
            "duration":"60",
            "trafficconfig":
            {
            }
        },
        {
            "sourcenodes":["n1"],
            "destnodes":["n3"],
            "traffictype":"udp",
            "starttime":"0",
            "duration":"60",
            "trafficconfig":
            {
            }
        },
        {
            "sourcenodes":["n1"],
            "destnodes":["n4"],
            "traffictype":"udp",
            "starttime":"0",
            "duration":"60",
            "trafficconfig":
            {
            }
        }
        
        
        ]
}



Response Data :

{
  "id": "8f53d8af-6753-4471-a954-ccd6082ff557",
  "data": {
    "name": "sampletest",
    "tests": [
      {
        "sourcenodes": [
          "n1"
        ],
        "destnodes": [
          "n2"
        ],
        "traffictype": "udp",
        "starttime": "0",
        "duration": "60",
        "trafficconfig": {}
      },
      {
        "sourcenodes": [
          "n1"
        ],
        "destnodes": [
          "n3"
        ],
        "traffictype": "udp",
        "starttime": "0",
        "duration": "60",
        "trafficconfig": {}
      },
      {
        "sourcenodes": [
          "n1"
        ],
        "destnodes": [
          "n4"
        ],
        "traffictype": "udp",
        "starttime": "0",
        "duration": "60",
        "trafficconfig": {}
      }
    ]
  },
  "saved": false
}


2. Get the Status of the test

GET 

http://localhost:5050/Topology/0e469af1-f2b8-47a4-a1b3-101cc11e7ef4/Test/8f53d8af-6753-4471-a954-ccd6082ff557


[
  {
    "testsuiteid": "8f53d8af-6753-4471-a954-ccd6082ff557",
    "name": "test_10.0.3.2_10.10.10.2",
    "source": "10.0.3.2",
    "destination": "10.10.10.2",
    "type": "udp",
    "starttime": "0",
    "duration": "60",
    "config": {},
    "createdTime": "2015-09-01T10:45:34.733Z",
    "startedTime": "2015-09-01T10:45:34.733Z",
    "status": "completed",
    "testResult": {
      "sender_date": "20150901161634",
      "sender_senderip": "10.10.10.1",
      "sender_senderport": "33291",
      "sender_receiverip": "10.10.10.2",
      "sender_receiverport": "5001",
      "sender_iperf_test_id": "3",
      "sender_interval": "0.0-60.0",
      "sender_transfer": "7865970",
      "sender_bandwidth": "1048593",
      "reported_date": "20150901161634",
      "reported_senderip": "10.10.10.2",
      "reported_senderport": "5001",
      "reported_receivedip": "10.10.10.1",
      "reported_receiverport": "33291",
      "reported_iperf_test_id": "3",
      "reported_interval": "0.0-60.0",
      "reported_transfer": "1705200",
      "reported_bandwidth": "227172",
      "reported_jitter": "13.714",
      "reported_lostdatagrams": "4191",
      "reported_totaldatagrams": "5351",
      "reported_unknown1": "78.322",
      "reported_unknown2": "0"
    },
    "completedTime": "2015-09-01T10:46:34.845Z"
  },
  {
    "testsuiteid": "8f53d8af-6753-4471-a954-ccd6082ff557",
    "name": "test_10.0.3.2_10.10.10.3",
    "source": "10.0.3.2",
    "destination": "10.10.10.3",
    "type": "udp",
    "starttime": "0",
    "duration": "60",
    "config": {},
    "createdTime": "2015-09-01T10:45:34.737Z",
    "startedTime": "2015-09-01T10:45:34.738Z",
    "status": "completed",
    "testResult": {
      "sender_date": "20150901161634",
      "sender_senderip": "10.10.10.1",
      "sender_senderport": "35304",
      "sender_receiverip": "10.10.10.3",
      "sender_receiverport": "5001",
      "sender_iperf_test_id": "3",
      "sender_interval": "0.0-60.0",
      "sender_transfer": "7865970",
      "sender_bandwidth": "1048593",
      "reported_date": "20150901161635",
      "reported_senderip": "10.10.10.3",
      "reported_senderport": "5001",
      "reported_receivedip": "10.10.10.1",
      "reported_receiverport": "35304",
      "reported_iperf_test_id": "3",
      "reported_interval": "0.0-60.3",
      "reported_transfer": "1719900",
      "reported_bandwidth": "228317",
      "reported_jitter": "22.116",
      "reported_lostdatagrams": "4181",
      "reported_totaldatagrams": "5351",
      "reported_unknown1": "78.135",
      "reported_unknown2": "0"
    },
    "completedTime": "2015-09-01T10:46:35.047Z"
  },
  {
    "testsuiteid": "8f53d8af-6753-4471-a954-ccd6082ff557",
    "name": "test_10.0.3.2_10.10.10.4",
    "source": "10.0.3.2",
    "destination": "10.10.10.4",
    "type": "udp",
    "starttime": "0",
    "duration": "60",
    "config": {},
    "createdTime": "2015-09-01T10:45:34.743Z",
    "startedTime": "2015-09-01T10:45:34.744Z",
    "status": "completed",
    "testResult": {
      "sender_date": "20150901161634",
      "sender_senderip": "10.10.10.1",
      "sender_senderport": "43321",
      "sender_receiverip": "10.10.10.4",
      "sender_receiverport": "5001",
      "sender_iperf_test_id": "3",
      "sender_interval": "0.0-60.0",
      "sender_transfer": "7865970",
      "sender_bandwidth": "1048593",
      "reported_date": "20150901161635",
      "reported_senderip": "10.10.10.4",
      "reported_senderport": "5001",
      "reported_receivedip": "10.10.10.1",
      "reported_receiverport": "43321",
      "reported_iperf_test_id": "3",
      "reported_interval": "0.0-60.3",
      "reported_transfer": "1702260",
      "reported_bandwidth": "225982",
      "reported_jitter": "23.256",
      "reported_lostdatagrams": "4193",
      "reported_totaldatagrams": "5351",
      "reported_unknown1": "78.359",
      "reported_unknown2": "0"
    },
    "completedTime": "2015-09-01T10:46:35.097Z"
  }
]
