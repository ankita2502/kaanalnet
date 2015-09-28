store = require "jfs"
validate = require('json-schema').validate


class keystore 
	constructor : (dbname, Schema)->			
		return false unless dbname? and Schema?
		@schema = Schema
		@db = new store(dbname,{type:'memory',saveId:true})		
		return true

	validate : (data)->
		chk = validate data, @schema
		console.log 'validate result ', chk
		unless chk.valid
			throw new Error "schema check failed"+  chk.valid
			return  false
		return true
		
	add : (data)->
		#json validations
		return false unless data?
		result = @validate data
		return result if result is false

		@db.save data, (err,id)->
			console.log "error is ",err
			console.log "id is", id
			return  id if id?
			return  err if err?

	del : (id)->
		return false unless id?
		@db.delete id,(err)->
			return  err if err?
			return  true

	get: (id)->
		return  false unless id?		
		@db.get id,(err, obj)->
			return  err if err?
			return  obj

	list : ()->	
		@db.all (err, objs)->
			return err if err?
			return  objs

	update : (id,data)->
		return false unless id? and data?
		result = @validate data
		return result if result is false

		@db.delete id,(err) =>
			return err if err?
			@db.save id, data , (err)=>
				return  true

module.exports = keystore


###
# test
Schema =
    name: "netem"
    type: "object"
    required: true
    properties:        
        bandwidth:  {"type":"string", "required":true}
        latency:  {"type":"string", "required":false}
        jitter:  {"type":"string", "required":false}
        pktloss:  {"type":"string", "required":false}

data = 
	bandwidth: "129kb"
	latency : "10ms"
	jitter: "0ms"

data1 =
	bandwidth: "129kb"
	latency : "10ms"
	jitter: "0ms"
	pktloss: "45"




netemstore  = new keystore "netem", Schema
id = netemstore.add data
console.log "id is ",id
#netemstore.list()
data = netemstore.get(id)
console.log "fata is ", data

console.log "update ", netemstore.update id,data1
console.log netemstore.list()
console.log netemstore.del id
console.log netemstore.list()
###











