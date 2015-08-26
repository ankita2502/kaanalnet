#verify the required debian packages are installed in the system
util = require 'util'
exec = require('child_process').exec
async = require('async')

config = require('../package.json').config

packagestatus = []


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
	command = "apt-get install -f #{pkg}"
	util.log "executing #{command}..."        
	exec command, (error, stdout, stderr) =>
		#util.log "execute - Error : " + error
		#util.log "execute - stdout : " + stdout
		#util.log "execute - stderr : " + stderr		
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




# Main Routine starts here
console.log "Dependent Debian packages " , config.debianpackages 
checkPackageExistence (rsult)->
	console.log "checkPackageExistence completed - result " + rsult
	#console.log JSON.stringify packagestatus
	InstallPackages (result)->
		console.log "InstallPackages completed - result " + result


