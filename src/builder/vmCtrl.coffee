StormData = require('stormdata')
StormRegistry = require('stormregistry')
#vm = require('./lxcdriver')
Vm = require('lxcdriver')
util = require('util')
netem = require('./iproute2driver')
#===============================================================================================#

class VmRegistry extends StormRegistry
    constructor: (filename) ->
        @on 'load', (key,val) ->
            #console.log "restoring #{key} with:" + val
            entry = new VmData key,val
            if entry?
                entry.saved = true
                @add entry

        @on 'removed', (entry) ->
            entry.destructor() if entry.destructor?

        super filename

    add: (data) ->
        return unless data instanceof VmData
        entry = super data.id, data

    update: (data) ->        
        super data.id, data    

    get: (key) ->
        entry = super key
        return unless entry?

        if entry.data? and entry.data instanceof VmData
            entry.data.id = entry.id
            entry.data
        else
            entry

#===============================================================================================#

class VmData extends StormData
    Schema =
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
        
    constructor: (id, data) ->
        super id, data, Schema

#===============================================================================================#
class VmBuilder    
    constructor: () ->      
        @registry = new VmRegistry #"/tmp/vm.db"
        @vmobjs = {}
    list : (callback) ->
        callback @registry.list()

    get: (data, callback) ->        
        callback @registry.get data

    create: (data,callback) ->
        try         
            vmdata = new VmData(null, data )
        catch err
            util.log "invalid schema" + err
            return callback new Error "Invalid Input "
        finally 
            vmdata.data.status = "creation-in-progress"
            @registry.add vmdata        
            
            vmobj = new Vm vmdata.data.name
            
            callback 
                "id": vmdata.id
                "status": vmobj.state
            
            vmobj.clone vmdata.data.image,(result)=>
                util.log "clone vm " + result
                if result instanceof Error
                    vmdata.data.status = vmobj.state #"failed"
                    vmdata.data.reason = "VM already exists"
                    @registry.update vmdata.id, vmdata.data
                    return 
                util.log "state is " + vmobj.state
                #remove the interface file
                vmobj.deleteFile "/etc/network/interfaces"

                #processing the interfaces map
                if vmdata.data.ifmap?
                    for x in vmdata.data.ifmap                      
                        if x.type is "mgmt"
                            #ubuntu interfaces file format
                            text = "\nauto #{x.ifname}\niface #{x.ifname} inet static \n\t address #{x.ipaddress} \n\t netmask #{x.netmask} \n"
                            vmobj.appendFile("/etc/network/interfaces",text)
    
                        else # for wan, lan interfaces                                    
                            vmobj.addEthernetInterface(x.veth,x.hwAddress)
                            text = "\nauto #{x.ifname}\niface #{x.ifname} inet static \n\t address #{x.ipaddress} \n\t netmask #{x.netmask} \n\t gateway #{x.gateway}\n"
                            vmobj.appendFile("/etc/network/interfaces",text)    
                        #write in to db
                vmdata.data.id = vmdata.id
                vmdata.data.status = vmobj.state #"created"                                
                @registry.update vmdata.id, vmdata.data
                @vmobjs[vmdata.id] = vmobj
                return 

    start:(id,callback) ->        
        vmdata = @registry.get id
        util.log "start ", vmdata
        return callback new Error "VM details not found in DB" unless vmdata?
        vmobj = @vmobjs[id]
        @configStartup(vmdata)
        return callback new Error "vm obj not found" unless vmobj?


        vmobj.start (res) =>
            util.log "startvm" + res
            if res is true
                vmdata.data.status = vmobj.state
                @registry.update vmdata.id, vmdata.data
                return callback 
                    "id": vmdata.id
                    "status":vmdata.data.status
            else
                vmdata.data.status = "failed"
                vmddata.data.reason = "failed to start"   
                @registry.update vmdata.id, vmdata.data
                return callback 
                        "id": vmdata.id
                        "status":vmdata.data.status
                        "reason": vmdata.data.reason

    stop:(id,callback) ->
        vmdata = @registry.get id
        return callback new Error "VM details not found in DB" unless vmdata?
        vmobj = @vmobjs[id]
        vmobj.stop (result) =>
            util.log "stopvm" + result
            if result is true
                vmdata.data.status = vmobj.state #"stopped"   
                @registry.update vmdata.id, vmdata.data
                return callback  
                    "id":vmdata.id
                    "status":vmdata.data.status
            else
                vmdata.data.status = "failed"
                vmdata.data.reason = "failed to stop"   
                @registry.update vmdata.id, vmdata.data
                return callback 
                    "id":vmdata.id
                    "status":vmdata.data.status
                    "reason" : vmdata.data.reason
    del:(id,callback)->
        vmdata = @registry.get id
        return callback new Error "VM details not found in DB" unless vmdata?
        vmobj = @vmobjs[id]

        vmobj.stop (res) =>
            vmobj.destroy (result) =>
                util.log "deleteVM " + result
                if result is true
                    vmdata.data.status = vmobj.state   
                    @registry.remove vmdata.id
                    #delete @vmobjs[id]
                    return callback 
                        "id":vmdata.id
                        "status":vmdata.data.status
                else
                    vmdata.data.status = "failed"
                    vmddata.data.reason = "failed to stop"   
                    @registry.update vmdata.id, vmdata.data
                    return callback 
                        "id":vmdata.id
                        "status":VmDataa.data.status
                        "reason":vmdata.data.reason
    status:(id,callback) ->
        vmdata = @registry.get id
        return callback new Error "VM details not found in DB" unless vmdata?
        vmobj = @vmobjs[id]
        vmobj.runningstatus (res)=>
            util.log "statusvm" + res           
            vmdata.data.status = res  
            @registry.update vmdata.id, vmdata.data
            return callback 
                "id": vmdata.id
                "status":vmdata.data.status  

    setLinkChars : (id,callback)->
        vmdata = @registry.get id
        return callback new Error "VM details not found in DB" unless vmdata?
        for i in vmdata.data.ifmap            
            util.log "Vmctrl - setLinkChars " + JSON.stringify i
            if i.config?
                netem.setLinkChars i.veth, i.config,(result)=>
                    console.log "setLinkCahrs output " + result
                callback true



    configStartup :(vmdata)->
        util.log "in configStartup routine", JSON.stringify vmdata
        vmobj = @vmobjs[vmdata.id]        
        if vmdata.data.type is "router"
            util.log 'its router'

            #updating the zebra config file
            zebraconf = "hostname zebra \npassword zebra \nenable password zebra \n"
            for i in vmdata.data.ifmap
                zebraconf += "interface  #{i.ifname} \n"            
                zebraconf += "   ip address #{i.ipaddress}/30 \n" if i.type is "wan"
                zebraconf += "   ip address #{i.ipaddress}/27 \n" if i.type is "lan"
                zebraconf += "   ip address #{i.ipaddress}/24 \n" if i.type is "mgmt"       
            util.log "zebrafile " +  zebraconf            
            vmobj.appendFile("/etc/zebra.conf",zebraconf)

            #ospf config
            ospfconf = "hostname ospf \npassword zebra \nenable password zebra \nrouter ospf\n  "
            for i in vmdata.data.ifmap
                ospfconf += "   network #{i.ipaddress}/24 area 0 \n" unless i.type is "mgmt"
            util.log "ospfconffile " + ospfconf
            vmobj.appendFile("/etc/ospf.conf",ospfconf)
            
            #updating the startup script
            text = "\n/usr/lib/quagga/zebra -f /etc/zebra.conf -d & \n /usr/lib/quagga/ospfd -f /etc/ospf.conf -d & \n"
            vmobj.appendFile("/etc/init.d/rc.local",text)            
            util.log "its router- to be returned here"
            return
        else
            util.log 'its host'
            #updating the startup script
            text = "\nnodejs /node_modules/testagent/lib/app.js > /var/log/testagent.log & \n  iperf -s > /var/log/iperf_tcp_server.log & \n iperf -s -u > /var/log/iperf_udp_server.log & \n"
            vmobj.appendFile("/etc/init.d/rc.local",text)
            return

###
class VmBuilder
    @records = []
    constructor: () ->		
        @registry = new VmRegistry #"/tmp/vm.db"
    		
        @registry.on 'load',(key,val) ->
            #util.log "Loading key #{key} with val #{val}"	

    list : (callback) ->
        callback @registry.list()

    get: (data, callback) ->
        
        callback @registry.get data

    #This create code to be relooked.. To be converted to async
    create:(data,callback) ->
        try         
            vmdata = new VmData(null, data )
        catch err
            util.log "invalid schema" + err
            return callback new Error "Invalid Input "
        finally 
            vmdata.data.status = "creation-in-progress"
            @registry.add vmdata
            callback 
                "id": vmdata.id
                "status":vmdata.data.status          
            #Delete the VM if already in the same name exists
            console.log "stopcontainer", vmdata.data.name

            vm.stopContainer vmdata.data.name, (result) =>
                #Need to check the result?
                vm.destroyContainer vmdata.data.name, (result) =>
                    #Need to check the result

                    vm.createContainer vmdata.data.name, vmdata.data.image, (result) =>
                        util.log "createvm " + result
                        if result is false
                            vmdata.data.status = "failed"
                            vmdata.data.reason = "VM already exists"
                            @registry.update vmdata.id, vmdata.data
                            return       
                        vm.clearInterface(vmdata.data.name)
                        if vmdata.data.ifmap?
                            for x in vmdata.data.ifmap                      
                                if x.type is "mgmt"
                                    result2 = vm.assignIP(vmdata.data.name,x.ifname,x.ipaddress,x.netmask,null)
                                    console.log "assignIP " + result2
                                    if result2 is false
                                        vmdata.data.status = "failure"
                                        vmdata.data.reason = "Fail to assign mgmt ip"
                                        @registry.update vmdata.id, vmdata.data
                                        return 
                                else # for wan, lan interfaces
                                    #result1 = vm.addEthernetInterface(vmdata.data.name,x.brname,x.hwAddress)              
                                    result1 = vm.addEthernetInterface(vmdata.data.name,x.veth,x.hwAddress)
                                    console.log "addEthernetInterface " + result1               
                                    if result is false
                                        vmdata.data.status = "failure"
                                        vmdata.data.reason = "Fail to add Interface"
                                        @registry.update vmdata.id, vmdata.data
                                        return 
                                    result2 = vm.assignIP(vmdata.data.name,x.ifname,x.ipaddress,x.netmask,x.gateway)
                                    console.log "assignIP " + result2
                                    if result is false
                                        vmdata.data.status = "failure"
                                        vmdata.data.reason = "Fail to add Interface"
                                        @registry.update vmdata.id, vmdata.data
                                        return 
                        #write in to db
                        vmdata.data.id = vmdata.id
                        vmdata.data.status = "created"                                
                        @registry.update vmdata.id, vmdata.data
                        return 

    status:(data,callback) ->
        vmdata = @registry.get data
        return callback new Error "VM details not found in DB" unless vmdata?
        vm.getStatus vmdata.data.name, (res) =>
            util.log "statusvm" + res           
            vmdata.data.status = res  
            @registry.update vmdata.id, vmdata.data
            return callback 
                "id": vmdata.id
                "status":vmdata.data.status           

    start:(data,callback) ->        
        vmdata = @registry.get data
        return callback new Error "VM details not found in DB" unless vmdata?
        @configStartup(vmdata)
        vm.startContainer vmdata.data.name, (res) =>
            util.log "startvm" + res
            if res is true
                vmdata.data.status = "started"   
                @registry.update vmdata.id, vmdata.data
                return callback 
                    "id": vmdata.id
                    "status":vmdata.data.status
            else
                vmdata.data.status = "failed"
                vmddata.data.reason = "failed to start"   
                @registry.update vmdata.id, vmdata.data
                return callback 
                        "id": vmdata.id
                        "status":vmdata.data.status
                        "reason": vmdata.data.reason

    stop:(data,callback) ->
        vmdata = @registry.get data
        return callback new Error "VM details not found in DB" unless vmdata?
        vm.stopContainer vmdata.data.name, (result) =>
            util.log "stopvm" + result
            if result is true
                vmdata.data.status = "stopped"   
                @registry.update vmdata.id, vmdata.data
                return callback  
                    "id":vmdata.id
                    "status":vmdata.data.status
            else
                vmdata.data.status = "failed"
                vmdata.data.reason = "failed to stop"   
                @registry.update vmdata.id, vmdata.data
                return callback 
                    "id":vmdata.id
                    "status":vmdata.data.status
                    "reason" : vmdata.data.reason

    del:(data,callback)->
        vmdata = @registry.get data
        return callback new Error "VM details not found in DB" unless vmdata?
        @stop data, (res) =>
            vm.destroyContainer vmdata.data.name, (result) =>
                util.log "deleteVM " + result
                if result is true
                    vmdata.data.status = "deleted"   
                    @registry.remove vmdata.id
                    return callback 
                        "id":vmdata.id
                        "status":vmdata.data.status
                else
                    vmdata.data.status = "failed"
                    vmddata.data.reason = "failed to stop"   
                    @registry.update vmdata.id, vmdata.data
                    return callback 
                        "id":vmdata.id
                        "status":VmDataa.data.status
                        "reason":vmdata.data.reason

    setLinkChars : (data,callback)->
        vmdata = @registry.get data
        return callback new Error "VM details not found in DB" unless vmdata?
        for i in vmdata.data.ifmap            
            util.log "Vmctrl - setLinkChars " + JSON.stringify i
            if i.config?
                netem.setLinkChars i.veth, i.config,(result)=>
                    console.log "setLinkCahrs output " + result
                callback true

    configStartup :(vmdata)->
        util.log "in configStartup routine", JSON.stringify vmdata
        if vmdata.data.type is "router"
            util.log 'its router'
            vm.updateRouterConfig(vmdata.data.ifmap,vmdata.data.name)            
            vm.updateRouterStartupScript(vmdata.data.name)
            util.log "its router- to be returned here"
            return
        else
            util.log 'its host'
            vm.updateHostStartupScript(vmdata.data.name)                        
            return
###
###
    packettrace:(data, callback)->
        vmdata = @registry.get data
        return callback new Error "VM details not found in DB" unless vmdata?
        #check whether trace is already enabled
        if vmdata.data.traceEnabled is true
            return callback     
                "id":vmdata.id
                "status":"Packet Trace already enabled"  

        vmdata.data.traceEnabled = true
        @registry.update vmdata.id, vmdata.data

        if vmdata.data.ifmap?
            for x in vmdata.data.ifmap  
                unless x.type is "mgmt"
                    command = "tcpdump -vv -S -i #{x.veth} > /var/log/#{x.veth}.txt &"
                    util.log "executing #{command}..."    
                    exec = require('child_process').exec    
                    exec command, (error, stdout, stderr) =>
                        util.log "lxcdriver: execute - Error : " + error
                        util.log "lxcdriver: execute - stdout : " + stdout
                        util.log "lxcdriver: execute - stderr : " + stderr    

            return callback        
                "id":vmdata.id
                "status":"Packet Trace enabled"                
###


module.exports = new VmBuilder
