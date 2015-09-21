restify = require 'restify'
util = require('util')
fs = require 'fs'
async = require 'async'

argv = require('minimist')(process.argv.slice(2))
if argv.h?
    console.log """
        -h view this help
        -l logfile (default: /var/log/kaanalnet.log)
        -z log level: (trace, debug, info, warn, error -  default value: info)
        -C sdn controller ip (Ex: tcp:0.0.0.0:6633 -   No default values)  
        -S switch type (openvswitch' or linuxbridge , default : linuxbridge)
        -W wan subnet (default - 172.17.1.0)
        -L Lan subnet (default - 10.10.10.0)
        -M Mgmt subnet (default - 10.0.3.0)
        -I Lxc image name (default: "nodeimg")  
    """
    return

config =
    logfile: argv.l ? "/var/log/kaanalnet.log"
    loglevel: if argv.z in [ 'trace','debug','info','warn','error' ] then argv.z else 'info'
    controller: argv.C ? null
    switchtype: if argv.S in ['openvswitch','linuxbridge'] then argv.S else 'linuxbridge'
    virtualization : 'lxc' #if argv.V in ['lxc','docker']  then argv.V else 'lxc'
    wansubnet : argv.W  ? '172.27.1.0'
    lansubnet : argv.L  ? '10.10.10.0'
    mgmtsubnet : argv.M ? '10.0.3.0'
    lxcimage : argv.I ? 'nodeimg'

#console.log config

#setting up the logger
log = require('./utils/logger').createLogger(config.loglevel,config.logfile)
log.info "kaanalNet application starts..... "
log.info "System Configuration " + JSON.stringify config
console.log "System Configuration " + JSON.stringify config
#log.debug, log.info, log.warn, log.notice,log.warning, log.critical, log.alert, log.emergency

#check the system capability to run kaanalnet
#run ins async series mode
systemcheck = ()->
    async.series([
        (callback)=>
            log.info "SYSTEMCHECK : Checking the LXC..."            
            lxc = require('lxcdriver')
            container = new lxc config.lxcimage
            container.exists (result)=>
                if result is true
                    log.info "SYSTEMCHECK: LXC Image < #{config.lxcimage} > present in the system.. PASSED "
                    callback(null,"LXC Check success") 
                else    
                    log.error "SYSTEMCHECK: LXC Image <#{config.lxcimage}> NOT present in the system.. FAILED"                    
                    callback new Error ('LXC Check failed') 
        ,
        (callback)=>
            log.info "SYSTEMCHECK : Checking the Linux bridge..."  
            brctl = require('brctldriver')
            testbridge = "testbridge"
            brctl.createBridge testbridge,(result)=>  
                if result is true
                    log.info "SYSTEMCHECK: LinuxBridge #{testbridge} creation success -- PASSED" 
                    brctl.deleteBridge testbridge,(result)=>
                    callback(null,"LinuxBridege Check success") 
                else
                    log.error "SYSTEMCHECK: LinuxBridge #{testbridge} creation Failure ..Failed" 
                    callback new Error ('LinuxBridge check failed')
        ,
        (callback)=>
            log.info "SYSTEMCHECK : Checking the OpenVSwitch..."  
            ovs = require('ovsdriver')
            testbridge = "testbridge"
            ovs.createBridge testbridge,(result)=>  
                if result is true
                    log.info "SYSTEMCHECK: OpenVSwitch #{testbridge} creation success -- PASSED" 
                    ovs.deleteBridge testbridge,(result)=>
                    callback(null,"OpenVSwitch Check success") 
                else
                    log.error "SYSTEMCHECK: OpenVSwitch #{testbridge} creation Failure ..Failed" 
                    callback new Error ('OpenVSwitch check failed')            

        ],
        (err,result)=>
            log.info "SYSTEMCHECK -  result is  %s ", result
            console.log "SYSTEMCHECK -  result is  %s ", result
            if err
                throw new Error "Dependent packages are not available - Failed"
    )         

#
systemcheck()


log.info "starting the REST api services..."
#---------------------------------------------------------------------------------------#
# REST APIs
#---------------------------------------------------------------------------------------#

topology = require('./Topology')
topology.configure(config)

#Topology Specific REST APIs
topologyPost = (req,res,next)->   
    log.info "REST API - POST /Topology received, body contents - " + JSON.stringify req.body
    topology.create req.body, (result) =>
        log.info "POST /Topology result " + JSON.stringify result 
        res.send result        
        next()

topologyList = (req,res,next)->     
    log.info "REST API - GET /Topology received "
    topology.list (result) =>
        log.info "REST API - GET /Topology result " + JSON.stringify result
        res.send result        
        next()

topologyGet = (req,res,next)->           
    log.info "REST API - GET /Topology/:id received ", req.params.id
    topology.get req.params.id, (result) =>
        util.log "REST API - GET /Topology/id result " + JSON.stringify result        
        res.send result   
        next()

topologyDelete = (req,res,next)->  
    log.info "REST API - DELETE /Topology/:id received - ",req.params.id
    topology.del req.params.id, (result) =>
        log.info "REST API - DELETE /Topology/:id result  " + JSON.stringify result
        res.send result   
        next()
 
#Device specific REST APIs

DeviceGet = (req,res,next)->
    log.info "REST API - GET /Topology/#{req.params.id}/Device/#{req.params.did} received "
    topology.deviceGet req.params.id,req.params.did, (result) =>
        log.info "REST API - GET /Topology/:id/Device/:did result  " + JSON.stringify result
        res.send result   
        next()



DeviceDel = (req,res,next)->
    log.info "REST API - DELETE /Topology/#{req.params.id}/Device/#{req.params.did} received "
    topology.deviceDelete req.params.id,req.params.did, (result) =>
        log.info "REST API - DELETE /Topology/:id/Device/:did result  " + JSON.stringify result
        res.send result   
        next()


DeviceStart = (req,res,next)->
    log.info "REST API - PUT /Topology/#{req.params.id}/Device/#{req.params.did}/start received "
    topology.deviceStart req.params.id,req.params.did, (result) =>
        log.info "REST API - PUT /Topology/:id/Device/:did/Start result  " + JSON.stringify result
        res.send result   
        next()

DeviceStop = (req,res,next)->
    log.info "REST API - PUT /Topology/#{req.params.id}/Device/#{req.params.did}/stop received "
    topology.deviceStop req.params.id,req.params.did, (result) =>
        log.info "REST API - PUT /Topology/:id/Device/:did/stop result  " + JSON.stringify result
        res.send result   
        next()    


#TestSuite API functions
testSuitePost = (req,res,next)->
    log.info "REST API - POST /Topology/#{req.params.id}/Test received "
    topology.testSuiteCreate req.params.id, req.body, (result) =>
        log.info "REST API - POST /Topology/:id/Test result  " + JSON.stringify result
        res.send result   
        next()    


testSuiteList = (req,res,next)->
    log.info "REST API - GET /Topology/#{req.params.id}/Device/#{req.params.did}/stop received "
    topology.testSuiteList req.params.id, (result) =>
        log.info "REST API - GET /Topology/:id/Test result  " + JSON.stringify result
        res.send result   
        next()    

testSuiteGet = (req,res,next)->
    log.info "REST API - GET /Topology/#{req.params.id}/Test/#{req.params.tid} received "
    topology.testSuiteGet req.params.id,req.params.tid, (result) =>
        log.info "REST API - GET /Topology/:id/Test/:tid result  " + JSON.stringify result
        res.send result   
        next()    

testSuiteDelete = (req,res,next)->
    log.info "REST API - DELETE /Topology/#{req.params.id}/Test/#{req.params.tid} received "
    topology.testSuiteDelete req.params.id,req.params.tid, (result) =>
        log.info "REST API - DELETE /Topology/:id/Test/:tid result  " + JSON.stringify result
        res.send result   
        next()    

#---------------------------------------------------------------------------------------#
# REST Server routine starts here
#---------------------------------------------------------------------------------------#
server = restify.createServer()
server.use(restify.acceptParser(server.acceptable));
server.use(restify.queryParser());
server.use(restify.jsonp());
server.use(restify.bodyParser());

#Topology APIs
server.post '/Topology', topologyPost
server.get '/Topology', topologyList
server.get '/Topology/:id', topologyGet
server.del '/Topology/:id', topologyDelete

server.get '/Topology/:id/Device/:did',DeviceGet
server.del '/Topology/:id/Device/:did',DeviceDel
#start and stop REST API format to be relooked
server.put '/Topology/:id/Device/:did/Start',DeviceStart
server.put '/Topology/:id/Device/:did/Stop',DeviceStop

#Test APIs
server.post '/Topology/:id/Test', testSuitePost
server.get '/Topology/:id/Test', testSuiteList
server.get '/Topology/:id/Test/:tid', testSuiteGet
server.del '/Topology/:id/Test/:tid', testSuiteDelete


server.listen 5050,()->
    console.log 'kaanalNet listening on port : 5050.....'
