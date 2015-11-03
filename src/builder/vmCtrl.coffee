Vm = require('lxcdriver')
util = require('util')
netem = require('linuxtcdriver')
request = require('request-json')
#===============================================================================================#

keystore = require('mem-db')
Schema = require('./../schema').nodeschema

#===============================================================================================#

class VmBuilder    

    constructor: () ->      
        @registry = new keystore "vmbuilder",Schema
        #@registry = new VmRegistry #"/tmp/vm.db"
        @vmobjs = {}

    list : (callback) ->
        callback @registry.list()

    get: (id, callback) ->        
        callback @registry.get id

    create : (data, callback) ->
        id = @registry.add data
        #util.log "new vmbuilder data created - id #{id}, data #{data.image} "        
        return callback new Error "invalid Schema" if id instanceof Error or id is false
        vmobj = new Vm data.name

        #util.log "vmobj state is #{vmobj.state}  name is #{vmobj.name}"        
        data.status = "creation-in-progress"
        @registry.update id, data

        callback({"id": id,"status": vmobj.state})       

        vmobj.clone data.image,(result)=>
            util.log "clone vm " + result
            if result instanceof Error
                data.status = vmobj.state #"failed"
                data.reason = "VM already exists"
                @registry.update id, data
                return #callback({"id": id,"status": vmobj.state})
            util.log "state is " + vmobj.state
            #remove the interface file
            vmobj.deleteFile "/etc/network/interfaces"

            #processing the interfaces map
            if data.ifmap?
                for x in data.ifmap                      
                    if x.type is "mgmt"
                        #ubuntu interfaces file format
                        text = "\nauto #{x.ifname}\niface #{x.ifname} inet static \n\t address #{x.ipaddress} \n\t netmask #{x.netmask} \n"
                        vmobj.appendFile("/etc/network/interfaces",text)
    
                    else # for wan, lan interfaces                                    
                        vmobj.addEthernetInterface(x.veth,x.hwAddress)
                        text = "\nauto #{x.ifname}\niface #{x.ifname} inet static \n\t address #{x.ipaddress} \n\t netmask #{x.netmask} \n\t gateway #{x.gateway}\n"
                        vmobj.appendFile("/etc/network/interfaces",text)    
                    #write in to db

            #processing the lag intefaces array
            if data.lagmap?
                for x in data.lagmap
                    vmobj.addEthernetInterface(x.veth1,x.hwAddress1)
                    vmobj.addEthernetInterface(x.veth2,x.hwAddress2)
                    text = "\nauto #{x.lagif1}\niface #{x.lagif1} inet static \n\t address 0.0.0.0 \n\t netmask 255.255.255.0 \n"
                    vmobj.appendFile("/etc/network/interfaces",text)                    
                    text = "\nauto #{x.lagif2}\niface #{x.lagif2} inet static \n\t address 0.0.0.0 \n\t netmask 255.255.255.0 \n"
                    vmobj.appendFile("/etc/network/interfaces",text)                                        

            #vmdata.data.id = vmdata.id
            data.status = vmobj.state #"created"
            #default router protocol ospf if not mentioned
            data.protocol ?= "ospf" if data.type is "router"
            @registry.update id, data
            @vmobjs[id] = vmobj
            return #callback({"id": id,"status": vmobj.state})       

    start : (id,callback) ->        
        console.log "start called id is ", id
        vmdata = @registry.get id
        return callback new Error "VM details not found in DB" if vmdata is false or vmdata instanceof Error
        console.log "start ", vmdata
        
        vmobj = @vmobjs[id]        
        return callback new Error "vm obj not found" unless vmobj?
        @configStartup(vmdata)

        vmobj.start (res) =>
            util.log "startvm" + res
            if res is true
                vmdata.status = vmobj.state
                @registry.update id, vmdata
                return callback 
                    "id": id
                    "status":vmdata.status
            else
                vmdata.status = "failed"
                vmddata.reason = "failed to start"   
                @registry.update vmdata.id, vmdata
                return callback 
                    "id": vmdata.id
                    "status":vmdata.status
                    "reason": vmdata.reason
    provision : (id, callback) ->
        console.log "Dummy provisioning is called ", id
        vmdata = @registry.get id
        return callback new Error "VM details not found in DB" if vmdata is false or vmdata instanceof Error
        console.log "provision ", vmdata
        vmobj = @vmobjs[id]        
        return callback new Error "vm obj not found" unless vmobj?
        #Todo - provisioning routines to be placed here
        # provision the LAG Bonding interfaces
        @provisionBonding(vmdata)
        return callback
            "id" : vmdata.id
            "status" : "provisioned"

    provisionBonding : (vmdata)->
        bondindex = 0
        for lag in vmdata.lagmap
            bonddata =
                "bondname": "bond#{bondindex}"
                "ipaddress": lag.ipaddress
                "interfaces":[lag.lagif1,lag.lagif2]
            bondindex++
            client = request.newClient("http://#{vmdata.mgmtip}:5051")
            client.post "/bonding", bonddata , (err, res, body) =>
                console.log "Post Bonding API Error  %s ", err if err?            
                console.log "PosT Bonding API result body %s " , JSON.stringify body

    stop:(id,callback) ->
        vmdata = @registry.get id
        return callback new Error "VM details not found in DB" if vmdata is false or vmdata instanceof Error
        vmobj = @vmobjs[id]
        vmobj.stop (result) =>
            util.log "stopvm" + result
            if result is true
                vmdata.status = vmobj.state #"stopped"   
                @registry.update id, vmdata
                return callback  
                    "id":vmdata.id
                    "status":vmdata.status
            else
                vmdata.status = "failed"
                vmdata.reason = "failed to stop"   
                @registry.update id, vmdata
                return callback 
                    "id":vmdata.id
                    "status":vmdata.status
                    "reason" : vmdata.reason

    del:(id,callback)->
        vmdata = @registry.get id
        return callback new Error "VM details not found in DB" if vmdata is false or vmdata instanceof Error
        vmobj = @vmobjs[id]

        vmobj.stop (res) =>
            vmobj.destroy (result) =>
                util.log "deleteVM " + result
                if result is true
                    vmdata.status = vmobj.state   
                    @registry.remove vmdata.id
                    #delete @vmobjs[id]
                    return callback 
                        "id":vmdata.id
                        "status":vmdata.status
                else
                    vmdata.status = "failed"
                    vmddata.reason = "failed to stop"   
                    @registry.update vmdata.id, vmdata
                    return callback 
                        "id":vmdata.id
                        "status":vmdata.status
                        "reason":vmdata.reason
    status:(id,callback) ->
        vmdata = @registry.get id
        return callback new Error "VM details not found in DB" if vmdata is false or vmdata instanceof Error
        vmobj = @vmobjs[id]
        vmobj.runningstatus (res)=>
            util.log "statusvm" + res           
            vmdata.status = res  
            @registry.update vmdata.id, vmdata            
            return callback 
                "id": vmdata.id
                "status":vmdata.status  

    setLinkChars : (id,callback)->
        vmdata = @registry.get id
        return callback new Error "VM details not found in DB" if vmdata is false or vmdata instanceof Error
        for i in vmdata.ifmap            
            util.log "Vmctrl - setLinkChars " + JSON.stringify i
            if i.config?                
                Netem =  new netem(i.veth,i.config)
                Netem.create()
        callback true

    configStartup :(vmdata)->
        util.log "in configStartup routine", JSON.stringify vmdata
        vmobj = @vmobjs[vmdata.id]        


        #updating the link charactristics simulation        
        for i in vmdata.ifmap            
            util.log "Vmctrl - setLinkChars " + JSON.stringify i
            if i.config?
                #host side configuration
                Netem =  new netem(i.ifname,i.config)
                #Netem.create()
                console.log Netem.commands
                text = " "
                for command in Netem.commands
                    console.log "command ", command
                    text += "\n #{command}"
                text += "\n"
                console.log "string command ", text
                #text = "\n/usr/lib/quagga/zebra -f /etc/zebra.conf -d & \n /usr/lib/quagga/ospfd -f /etc/ospf.conf -d & \n"
                vmobj.appendFile("/etc/init.d/rc.local",text)            

        if vmdata.type is "router"
            util.log 'its router'

            #zebra config
            zebraconf = @buildZebraConfig(vmdata)
            vmobj.appendFile("/etc/zebra.conf",zebraconf)
            text = "\n/usr/lib/quagga/zebra -f /etc/zebra.conf -d & \n"
            vmobj.appendFile("/etc/init.d/rc.local",text)
            #protocol config
            console.log "vmdata.protocol " ,vmdata.protocol
            switch vmdata.protocol
                when 'rip'
                    console.log "ripd case"
                    ripconf = @buildRipConfig(vmdata)  
                    vmobj.appendFile("/etc/rip.conf",ripconf)
                    text = "/usr/lib/quagga/ripd -f /etc/rip.conf -d & \n"
                    vmobj.appendFile("/etc/init.d/rc.local",text)             
                when 'ospf'              
                    console.log "ospf case" 
                    ospfconf = @buildOspfConfig(vmdata)
                    vmobj.appendFile("/etc/ospf.conf",ospfconf)
                    text = "/usr/lib/quagga/ospfd -f /etc/ospf.conf -d & \n"
                    vmobj.appendFile("/etc/init.d/rc.local",text)                           

                else
                    console.log "default case"

            util.log "its router- to be returned here"
            return
        else
            util.log 'its host'
            #updating the startup script
            text = "\nnodejs /node_modules/testagent/lib/app.js > /var/log/testagent.log & \n  iperf -s > /var/log/iperf_tcp_server.log & \n iperf -s -u > /var/log/iperf_udp_server.log & \n"
            vmobj.appendFile("/etc/init.d/rc.local",text)
            return

    buildZebraConfig :(vmdata)->
        #updating the zebra config file
        zebraconf = "hostname zebra \npassword zebra \nenable password zebra \n log file /tmp/zebra.log debugging \n"
        for i in vmdata.ifmap
            zebraconf += "interface  #{i.ifname} \n"            
            zebraconf += "   ip address #{i.ipaddress}/29 \n" if i.type is "wan"
            zebraconf += "   ip address #{i.ipaddress}/24 \n" if i.type is "lan"
            zebraconf += "   ip address #{i.ipaddress}/24 \n" if i.type is "mgmt"       
        util.log "zebrafile " +  zebraconf  
        return zebraconf

    buildOspfConfig :(vmdata)->
        ospfconf = "hostname zebra \npassword zebra \nenable password zebra \n log file /tmp/ospf.log debugging \n router ospf\n  "
        for i in vmdata.ifmap
            ospfconf += "   network #{i.ipaddress}/24 area 0 \n" unless i.type is "mgmt"
        util.log "ospfconffile " + ospfconf
        return ospfconf

    buildBgpConfig :(vmdata)->
        bgpconf = "hostname zebra \npassword zebra \nenable password zebra \nrouter bgp 1\n  "
        for i in vmdata.ifmap
            bgpconf += "   network #{i.ipaddress}/24  \n" unless i.type is "mgmt"
        util.log "bgpconffile " + bgpconf
        return bgpconf        


    buildRipConfig :(vmdata)->
        ripconf = "hostname zebra \npassword zebra \nenable password zebra \n log file /tmp/rip.log debugging \n  router rip\n  "
        for i in vmdata.ifmap
            ripconf += "   network #{i.ipaddress}/24 \n" unless i.type is "mgmt"
        util.log "ripconffile " + ripconf
        return ripconf


module.exports = new VmBuilder
