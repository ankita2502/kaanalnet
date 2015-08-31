util = require('util')
request = require('request-json');
extend = require('util')._extend

log = require('./utils/logger').getLogger()
log.info "Test - Logger test message"


class Test
    constructor:(data) ->
        @config = extend {}, data           
        @statistics = {}
        @status = {}
        log.info "Test object created with  " + JSON.stringify @config

    start : (callback)->
        log.info "starting a test "  + JSON.stringify @config
        @URL = "http://#{@config.source}:5051"
        log.info "Agent url is " + @URL
        client = request.newClient(@URL)
        client.post '/Test', @config, (err, res, body) =>            
            log.info "err" + JSON.stringify err if err?
            log.info "start test result " + JSON.stringify body
            @uuid = body.id                 
            callback @body

    run : (callback)->
        @start (result)=>
            callback result

    get: (callback)->
        client = request.newClient(@URL)
        client.get "/Test/#{@uuid}", (err, res, body) =>            
            log.info "err" + JSON.stringify err if err?
            log.info "get test result " + JSON.stringify body
            @status = body
            return callback body
###
    create : (callback)->
        log.info "c node " + JSON.stringify @config

        vmctrl.create @config, (result) =>
            @uuid = result.id
            @config.id = @uuid
            @status.result = result.status
            @status.result = result.reason if result.reason?
            log.info "node creation result " + JSON.stringify result
            callback result


    stop : (callback)->
        log.info "stopping a node " + @config.name
        vmctrl.stop @uuid, (result) =>
            log.info "node stop result " + JSON.stringify result            
            callback result

    del : (callback)->
        log.info "node deleting  " + @config.name
        vmctrl.del @uuid, (res) =>
            log.info "node del result " + JSON.stringify res            
            callback res    
    getstatus : (callback)->
        log.info "getstatus called" + @uuid
        vmctrl.get @uuid, (result) =>
            log.info "node getstatus result " + JSON.stringify result
            callback result
    getrunningstatus : (callback)->
        vmctrl.status @params.id, (res) =>
            log.info "node running status result " +  res
            callback res  
    get : () ->
        "id" : @uuid
        "config": @config
        #"status": @status
        #"statistics":@statistics
###        
module.exports = Test
