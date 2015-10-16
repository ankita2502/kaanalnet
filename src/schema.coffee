SwitchSchema =
	name: "switch"
	type: "object"        
	properties:                        
		name: {type:"string", required:true}                       
		type:{ type: "string", required: true}
		make: { type: "string", required: false}           	
		controller: { type: "string", required: false}
		ofversion: { type: "number", required: false}

NodeSchema =
    name: "vm"
    type: "object"
    required: true
    properties:
        name : {"type":"string", "required":true}                    
        type : {"type":"string", "required":false}
        protocol : {"type":"string", "required":false}
        virtulization : {"type":"string", "required":false}
        image : {"type":"string", "required":false}
        memory : {"type":"string", "required":false}   
        vcpus : {"type":"string", "required":false}     
        ifmap:
            type: "array"
            required: false
            items:
                type: "object"
                name: "ifmapp"
                required: false
                properties:
                    ifname: {type:"string","required":true}
                    hwAddress: {type:"string","required":true}
                    brname: {type:"string","required":false}
                    ipaddress:{type:"string","required":true}
                    netmask:{type:"string","required":true}
                    gateway:{tye:"string","required":false}
                    type:{tye:"string","required":true}
                    config : 
                        type: "object"
                        required: false		
TestSchema =
    name: "Test"
    type: "object"        
    #additionalProperties: true
    properties:                        
        name: {type:"string", required:true}
        tests:
            type: "array"
            items:
                name: "test"
                type: "object"
                required: true
                properties:
                    sourcenodes :
                        type: "array"
                        items:
                            type: "string"
                            required: true
                    destnodes :
                        type: "array"
                        items:
                            type: "string"
                            required: true
                    traffictype: {type:"string", required:true}            
                    starttime:  {type:"number", required:false}    
                    duration:  {type:"number", required:true}                           
                    trafficconfig:
                        type: "object"
                        required: true
TopologySchema =
    name: "Topology"
    type: "object"        
    #additionalProperties: true
    properties:                        
        name: {type:"string", required:true}
        switches:
            type: "array"
            items:
                name: "switch"
                type: "object"
                required: true
                properties:
                    name: {type:"string", required:false}            
                    type:  {type:"string", required:false}                                                            
        nodes:
            type: "array"
            items:
                name: "node"
                type: "object"
                required: true
                properties:
                    name: {type:"string", required:true}            
                    type: {type:"string", required:false}
                    protocol: {type:"string", required:false}

        links:
            type: "array"
            items:
                name: "node"
                type: "object"
                required: true            
                properties:                
                    type: {type:"string", required:true}
                    switches:
                        type : "array"                     
                        required: false
                        items:
                            type : "object"
                            required: false
                    connected_nodes:
                        type: "array"
                        required: false
                        items:
                            type: "object"
                            required: false
                            properties:
                                name:{"type":"string", "required":true}
                                lag:{"type":"boolean", "required":false}


module.exports.topologyschema = TopologySchema
module.exports.switchschema = SwitchSchema
module.exports.nodeschema = NodeSchema
module.exports.testschema = TestSchema