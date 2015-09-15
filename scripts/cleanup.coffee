util = require 'util'
exec = require('child_process').exec
console.log "clean up container"


destroyContainer = (container,cb)->	
	command = "lxc-destroy -n #{container}"	
	console.log "executing #{command}..."        
	exec command, (error, stdout, stderr) =>
		console.log "Destroying the container  - Error : " + error
		console.log "Destroying the container  - stdout : " + stdout
		console.log "Destroying the container  - stderr : " + stderr		
		if error?			
			cb false
		else			
			cb true



GetContainerNames = (cb)->
	command  = "lxc-ls"
	exec command, (error, stdout, stderr) =>
		console.log "Error : " + error
		console.log "stdout : " + stdout
		console.log "stderr : " + stderr		
		if error?			
			cb false
		else		
			cb stdout.toString()			



stopContainer = (container,cb)->
	command  = "lxc-stop -n #{container}"
	console.log "Exec command ", command
	exec command, (error, stdout, stderr) =>
		console.log "Error : " + error
		console.log "stdout : " + stdout
		console.log "stderr : " + stderr		
		if error?			
			cb false
		else		
			cb stdout.toString()			


#Exclude = ['nodeimg']

console.log "Installing LXC ubuntu base image"
GetContainerNames (result)=>
	result.trim()
	console.log "GetContainerNames completed - result " + result
	tmparr = result.split "\n"
	for n in tmparr
		n = n.trim()	

		if n isnt 'nodeimg'
			stopContainer n, (result)=>
				console.log "stopContainer result ", result
				destroyContainer n, (result1)=>
					console.log "destroyContainer result ", result1
		else
			console.log "found exluced list", n
