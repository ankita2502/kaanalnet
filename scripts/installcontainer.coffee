util = require 'util'
exec = require('child_process').exec
console.log "setup container"

templatepath = __dirname + "/lxc-ubuntu"
console.log "template is ", templatepath

InstallLXCBaseContainer = (cb)->
	#lxc-create -t ubuntu -n node -- -r trusty
	#command = "lxc-create -t ubuntu -n nodeimg -- -r trusty"
	command = "lxc-create -t #{templatepath} -n nodeimg "	
	console.log "executing #{command}..."        
	exec command, (error, stdout, stderr) =>
		console.log "installing LXC Base container - Error : " + error
		console.log "Installing LXC Base container - stdout : " + stdout
		console.log "Installing LXC Base container - stderr : " + stderr		
		if error?			
			cb false
		else			
			cb true




console.log "Installing LXC ubuntu base image"
InstallLXCBaseContainer (result)=>
	console.log "InstallLXCBaseContainer completed - result " + result
