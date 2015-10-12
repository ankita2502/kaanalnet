util = require('util')
request = require('request-json');
extend = require('util')._extend
ip = require 'ip'
async = require 'async'

log = require('./utils/logger').getLogger()
log.info "IPManager - Logger test message"

##########################################################################################################
#It works perfectly, even its not clean.
# revisit later.

# utility functions
wansubnetting = (net, curprefix, newprefix ) ->
    
    netmask = ip.fromPrefixLen(curprefix)
    newmask = ip.fromPrefixLen(newprefix)
    xx = new Buffer 4
    iter =  ( newprefix - curprefix ) 
    iterations = Math.pow(2, iter)
    answer = []
    do () ->
        for i in [0..iterations-1]
            result = ip.subnet(net,newmask)            
            result.status = "free"
            result.iparray = []

            xx = ip.toBuffer(result.firstAddress)
            for i in [0..result.numHosts-1]                               
                result.iparray[i] = ip.toString(xx)
                xx[3]++ 

            answer.push result
            xx = ip.toBuffer(result.broadcastAddress)
            xx[3]++     
            if xx[3] == 0x00
                xx[2]++
            str = ip.toString(xx)
            net = str
    return answer


iplist = (address) ->
    iparray = []
    result = ip.subnet(address, '255.255.255.0')
    xx = ip.toBuffer(result.firstAddress)
    for i in [0..result.numHosts-1]
        iparray[i] = ip.toString(xx)
        xx[3]++ 
    return iparray

lanipsubnets = (address)->

    netmask = '255.255.255.0'
    net = address
    iterations = 255
    xx = new Buffer 4
    answer = []
    do () ->
        for i in [0..iterations-1]
            result = ip.subnet(net,netmask)            
            result.status = "free"
            result.iparray = []

            xx = ip.toBuffer(result.firstAddress)
            for i in [0..result.numHosts-1]                               
                result.iparray[i] = ip.toString(xx)
                xx[3]++ 

            answer.push result

            xx = ip.toBuffer(net)
            xx[2]++     
            net = ip.toString(xx)
    return answer 




##########################################################################################################
class IPManager
    constructor :(wan,lan,mgmt) ->
        log.info "IPManager starts with wan pool #{wan} lan pool #{lan} mgmt pool #{mgmt}"        
        @wansubnets = wansubnetting wan, 24, 29
        @lansubnets = lanipsubnets lan
        @wanindex = 0
        @lanindex = 0
        @mgmtindex = 1
        @mgmtips = iplist(mgmt)

    listwansubnets:()->
        log.info " IPManager - listwansubnets " + JSON.stringify @wansubnets
    listlanubnets:()->
        log.info "IPManager - listlansubnets " + JSON.stringify @lansubnets
    getFreeWanSubnet:()->
        @wansubnets[@wanindex++]
    getFreeLanSubnet:()->
        @lansubnets[@lanindex++]
    getFreeMgmtIP :()->
        @mgmtips[@mgmtindex++]

###################################################################################################
module.exports = IPManager


#Test code
#lansubnets = subnetting "192.168.1.0"\
#result = lanipsubnets("10.10.10.1")
#console.log result;