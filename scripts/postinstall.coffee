#verify the required debian packages are installed in the system
util = require 'util'
exec = require('child_process').exec
async = require('async')

config = require('../package.json').config

packagestatus = []

templatepath = "ubuntu"

dpkgquery = (pkg,callback) ->
	return callback false unless pkg?
	command = "dpkg-query -s #{pkg}"
	util.log "executing #{command}..."        
	exec command, (error, stdout, stderr) =>
		#util.log "execute - Error : " + error
		#util.log "execute - stdout : " + stdout
		#util.log "execute - stderr : " + stderr		
		if error?			
			callback false
		else			
			callback true

#aptget install is sync function
aptgetinstall = (pkg,callback)->
	callback false unless pkg?
	command = "apt-get install -y #{pkg}"
	util.log "executing #{command}..."        
	exec command, (error, stdout, stderr) =>
		util.log "execute - Error : " + error
		util.log "execute - stdout : " + stdout
		util.log "execute - stderr : " + stderr		
		if error?
			callback  error
		else			
			callback true


checkPackageExistence  = (cb)->
	async.each config.debianpackages, (pack,callback) =>
		console.log "checking the < #{pack} > package  existence in the system"
		dpkgquery pack,(result)=>
			console.log "#{pack} existence status :  " + result	
			pk = {}
			pk.name = pack
			pk.status = result
			packagestatus.push pk
			callback()
	,(err)=>
		if err
			console.log "checkPackageExistence error occured " + JSON.stringify err
			cb(false)
		else
			#console.log "checkPackageExistence completed for all packages "
			cb (true)

InstallPackages = (cb)->
	async.eachSeries packagestatus, (pack,callback) =>
		console.log "checking the package installation status " + JSON.stringify pack
		if pack.status is false
			console.log "Triggering the package installation - " + JSON.stringify pack.name
			aptgetinstall pack.name,(result)=>
				console.log "#{pack.name} installation status " + result
				callback()
		else
			callback()
	,(err)=>
		if err
			console.log "InstallPackages error occured " + JSON.stringify err
			cb(false)
		else
			#console.log "InstallPackages completed "
			cb (true)


InstallLXCBaseContainer = (cb)->
	#lxc-create -t ubuntu -n node -- -r trusty
	#command = "lxc-create -t ubuntu -n nodeimg -- -r trusty"
	command = "lxc-create -t #{templatepath} -n nodeimg -- -r trusty"	
	util.log "executing #{command}..."        
	exec command, (error, stdout, stderr) =>
		util.log "installing LXC Base container - Error : " + error
		util.log "Installing LXC Base container - stdout : " + stdout
		util.log "Installing LXC Base container - stderr : " + stderr		
		if error?			
			cb false
		else			
			cb true



# Main Routine starts here
async.series([
	(callback)=>
		console.log "Dependent Debian packages are" , config.debianpackages 
		console.log "Checking the package existence staus" 
		checkPackageExistence (rsult)->
			console.log "checkPackageExistence completed - result " + rsult
			callback(null,"debian package existence check success")
	,
	(callback)=>
		console.log "Installing the packages "
		InstallPackages (result)->
			console.log "InstallPackages completed - result " + result
			callback(null,"Install packages success")
	,
	(callback)=>
		console.log "Installing LXC ubuntu base image"
		InstallLXCBaseContainer (result)=>
			console.log "InstallLXCBaseContainer completed - result " + result
			callback(null,"InstallLXCBaseContainer success")
	],
	(err,result)=>
		console.log "TOPOLOGY -  RUN result is  %s ", result
)
