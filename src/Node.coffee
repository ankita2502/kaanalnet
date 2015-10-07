util = require('util')
request = require('request-json');
extend = require('util')._extend
ip = require 'ip'
async = require 'async'

vmctrl = require('./builder/vmCtrl')


log = require('./utils/logger').getLogger()
log.info "Node - Logger test message"


#utility functions 
#Todo:  Not scalable....To be modified
#HWADDR_PREFIX = "00:16:3e:5a:55:"
HWADDR_PREFIX = "00:00:00:00:00:"

HWADDR_START = 10
getHwAddress = () ->
    HWADDR_START++      
    hwaddr= "#{HWADDR_PREFIX}#{HWADDR_START}"
    hwaddr


class node
    constructor:(data) ->
        @ifmap = []        
        @ifindex = 1
        @config = extend {}, data   
        @config.ifmap = @ifmap        
        @statistics = {}
        @status = {}
        log.debug "node object created with  " + JSON.stringify @config

   
    addLanInterface :(brname, ipaddress, subnetmask, gateway, characterstics) ->         
        interf =
            "ifname" : "eth#{@ifindex}"
            "hwAddress" : getHwAddress()
            "brname" : brname 
            "ipaddress": ipaddress 
            "netmask" : subnetmask
            "gateway" : gateway if gateway?
            "type":"lan"
            "veth" : "#{@config.name}_veth#{@ifindex}"
            "config": characterstics
        log.debug "lan interface " + JSON.stringify interf
        @ifindex++
        @ifmap.push  interf
        @lanip = ipaddress

    addWanInterface :(brname, ipaddress, subnetmask, gateway , characterstics) ->         
        #console.log "inside addWanInterface function"
        interf =
            "ifname" : "eth#{@ifindex}"
            "hwAddress" : getHwAddress()
            "brname" : brname
            "ipaddress": ipaddress
            "netmask" : subnetmask
            "gateway" : gateway if gateway?
            "type":"wan"
            "veth" : "#{@config.name}_veth#{@ifindex}"
            "config": characterstics
        log.debug "waninterface " + JSON.stringify  interf
        @ifindex++
        @ifmap.push  interf

    addMgmtInterface :(ipaddress, subnetmask) ->
        interf =
            "ifname" : "eth0"
            "hwAddress" : getHwAddress()                
            "ipaddress": ipaddress
            "netmask" : subnetmask                
            "type":"mgmt"
        log.debug "mgmt interface" + JSON.stringify interf
        @ifmap.push  interf
        @mgmtip = ipaddress
        #console.log @ifmap

    create : (callback)->
        log.info "createing node " + JSON.stringify @config
        vmctrl.create @config, (result) =>
            @uuid = result.id
            @config.id = @uuid
            @config.status = result.status
            log.info "node creation result " + JSON.stringify result
            callback result
    start : (callback)->
        log.info "starting a node "  +  @config.name
        vmctrl.start @uuid, (result) =>
            log.info "node start result " + JSON.stringify result
            @config.status = result.status
            callback result
    provision : (callback)->
        log.info "provisioning  a node " + @config.name
        vmctrl.provision @uuid, (result) =>
            log.info "node provision result " + JSON.stringify result
            #@config.status = result. status
            callback result
    stop : (callback)->
        log.info "stopping a node " + @config.name
        vmctrl.stop @uuid, (result) =>
            log.info "node stop result " + JSON.stringify result            
            @config.status = result.status
            callback result
    trace : (callback)->
        vmctrl.packettrace @uuid, (res) =>
            log.info "node packettrace result " + res            
            callback res    
    del : (callback)->
        log.info "node deleting  " + @config.name
        vmctrl.del @uuid, (res) =>
            log.info "node del result " + JSON.stringify res            
            @config.status = result.status
            callback res    
    getstatus : (callback)->
        log.info "getstatus called" + @uuid
        vmctrl.get @uuid, (result) =>
            log.info "node getstatus result " + JSON.stringify result
            @config.status = result.status
            callback result
    getrunningstatus : (callback)->
        vmctrl.status @params.id, (res) =>
            log.info "node running status result " +  res
            callback res  

    setLinkChars : (callback)->
        log.info "setting the link characterstics " + @config.name
        vmctrl.setLinkChars @uuid, (result) =>
            log.info "setLinkChars result " +  result            
            callback result

    get : () ->
        "id" : @uuid
        "config": @config
        #"status": @status
        #"statistics":@statistics
module.exports = node


#Todo items
#request.json - HTTP response  code
#Timeout condition - if server is not reachable
     