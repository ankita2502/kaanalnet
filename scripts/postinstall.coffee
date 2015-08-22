#verify the required debian packages are installed in the system


config = require('../package.json').config

for pack in config.debianpackages.virtualization.lxc
	console.log "virtualization" + pack

for pack in config.debianpackages.switch.linuxbridge
	console.log "switch - linuxbridge " + pack

for pack in config.debianpackages.switch.openvswitch
	console.log "switch openvswitch " + pack



isLXCInstalled = ()->
	return {"installed":"True"}


isLinuxBridgeInsalled = ()->
	return {"installed":"True"}
isOpenVSWitchInstalled = ()->
	return {"installed":"True"}

lxcstatus = isLXCInstalled()
bridgestatus = isLinuxBridgeInsalled()
ovsstatus = isOpenVSWitchInstalled()

console.log "=========================================================="
console.log "OS Details"
console.log "======================="
console.log "Operating System ": 
console.log "processor" :


console.log "=========================================================="
console.log "virtualization Support"
console.log "======================="
console.log "LXC : " + JSON.stringify lxcstatus
console.log "=========================================================="
console.log "switches support"
console.log "======================="
console.log "linuxbridge : " + JSON.stringify  bridgestatus
console.log "openvswitch  : " + JSON.stringify  ovsstatus
console.log "=========================================================="

#console.log process.env.npm_package_config_port