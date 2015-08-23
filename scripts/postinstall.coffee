#verify the required debian packages are installed in the system

util = require 'util'
exec = require('child_process').exec

dpkgquery = (command,callback) ->
	callback false unless command?
	command = "dpkg-query -s #{command}"
	util.log "executing #{command}..."        
	exec command, (error, stdout, stderr) =>
		#util.log "execute - Error : " + error
		#util.log "execute - stdout : " + stdout
		#util.log "execute - stderr : " + stderr
		
		if error?
			callback false
		else			
			callback true


config = require('../package.json').config

console.log "=========================================================="
for pack1 in config.debianpackages.virtualization.lxc
	dpkgquery pack1,(result)->
		console.log "#{pack1}  :  " + result
	
for pack2 in config.debianpackages.switch.linuxbridge
	dpkgquery pack2,(result)->
		console.log "#{pack2}    : " + result

for pack3 in config.debianpackages.switch.openvswitch
	dpkgquery pack3,(result)->
		console.log "#{pack3}    : " + result

console.log "=========================================================="