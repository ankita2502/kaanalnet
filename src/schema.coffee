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








module.exports.switchschema = SwitchSchema
module.exports.nodeschema = NodeSchema                        