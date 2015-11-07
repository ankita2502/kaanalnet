brctl = require('brctldriver')
ovs = require('ovsdriver')
util = require('util')

netem = require('linuxtcdriver')
delLink = require('linuxtcdriver').delLink

#===============================================================================================#

keystore = require('mem-db')
Schema = require('./../schema').switchschema



class SwitchBuilder
	#@records = []
	bridge = null
	#@dpid = 1

	constructor: () ->		
		
		@registry = new keystore "switch",Schema

	list : (callback) ->
        return callback @registry.list()

    get: (id, callback) ->
    	callback @registry.get id		

	create:(data,callback) ->	
		id = @registry.add data 		
		util.log "new switch data created - data #{id} "
		return callback new Error "invalid Schema" if id instanceof Error or false
		if data.make is "openvswitch"
			bridge  = ovs
		else
			bridge  = brctl

		# if switch make is "bridge"
		bridge.createBridge data.name, (result) =>
			util.log "Bridge creation " + result								
			if result is false
				data.status = "failed"
				data.reason = "failed to create"
			else
				data.status = "created"
			@registry.update id, data
			return callback
				"id" : id
				"status" : data.status
				"reason" : data.reason if data.reason?		

	addInterface : (id, body, callback) ->
		util.log "addInterface body is " + JSON.stringify body
		util.log "addInterface data is " + id
		sdata = @registry.get id
		util.log "addInterface sdata is "+ JSON.stringify sdata
		return callback new Error "Switch details not found in DB" unless sdata?
		if sdata.make is "openvswitch"
			bridge  = ovs
		else
			bridge  = brctl

		bridge.addInterface sdata.name, body.ifname, (result) =>
			util.log "addif" + result			

			return callback 
				"id" : sdata.id
				"status" : sdata.status					
				"reason" : sdata.reason if sdata.reason?


	CreateTapInterfaces : (ifname1,ifname2) ->		
		bridge = brctl
		bridge.createTapPeers ifname1, ifname2, (result) =>
			util.log "createTapPeers " + result			
			return result 

	start : (id, callback) ->
		sdata = @registry.get id
		return callback new Error "Switch details not found in DB" unless sdata?
		if sdata.make is "openvswitch"
			bridge  = ovs
			if sdata.controller?				
				bridge.setController sdata.name, sdata.controller, (result) =>
					util.log result
					bridge.setOFVersion sdata.name, sdata.ofversion, (res) =>
						util.log res
						val = "00000000000000" + sdata.datapathid
						bridge.setDPid sdata.name, val, (res) =>
							#@dpid++
							util.log res

		else
			bridge  = brctl


		bridge.enableBridge sdata.name, (result) =>
			util.log "enableBridge" + result			
			if result is false	
				sdata.status = "failed"
				sdata.reason = "failed to start"
			else
				sdata.status = "started"				
			@registry.update sdata.id , sdata
			return callback 
				"id" : sdata.id
				"status" : sdata.status					
				"reason" : sdata.reason if sdata.reason?

	stop : (id, callback) ->
		sdata = @registry.get id
		return callback new Error "Switch details not found in DB" unless sdata?

		if sdata.make is "openvswitch"
			bridge  = ovs
		else
			bridge  = brctl

		bridge.disableBridge sdata.name, (result) =>
			util.log "disableBridge" + result			
			if result is false	
				sdata.status = "failed"
				sdata.reason = "failed to stop"
			else
				sdata.status = "stopped"
			@registry.update sdata.id , sdata
			return callback 
				"id" : sdata.id
				"status" : sdata.status					
				"reason" : sdata.reason if sdata.reason?

	del: (id,callback) -> 	 
		#Get the Switchname from db
		sdata = @registry.get id
		if sdata.make is "openvswitch"
			bridge  = ovs
		else
			bridge  = brctl
		return callback new Error "Switch details not found in DB" unless sdata?
		
		bridge.deleteBridge sdata.name, (result) =>
			util.log "deletBridge" + result
			return callback new Error "Failed to Delete the Switch" if result is false
			#delete the switch from db
			@registry.del sdata.id
			return callback 
				"id":sdata.id
				"status": "deleted"

	dellink: (ifname,callback)->
		netem.delLink ifname,(result)->
			callback result

	status: (id, callback) ->
		#Todo
		sdata = @registry.get id
		return callback new Error "Switch details not found in DB" unless sdata?
		if sdata.data.make is "openvswitch"
			bridge  = ovs
		else
			bridge  = brctl
		bridge.getStatus sdata.name, (result) =>
			util.log "SwitchCtrl getStatus" + result
			sdata.status = result
			@registry.update id, sdata
			return callback sdata
			#delete the switch from db

	setLinkChars: (id, chars, callback)->
		sdata = @registry.get id
		if sdata.make is "openvswitch"
			bridge  = ovs
		else
			bridge  = brctl
		return callback new Error "Switch details not found in DB" unless sdata?
		return callback true unless chars.config?

		Netem = new netem(chars.name, chars.config)
		Netem.create()
		callback true


module.exports = new SwitchBuilder
