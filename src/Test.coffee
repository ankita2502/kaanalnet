util = require('util')
request = require('request-json');
extend = require('util')._extend

log = require('./utils/logger').getLogger()
log.info "Test - Logger test message"


class Test
    constructor:(data) ->
        @config = extend {}, data  
        @testsuiteid = data.testsuiteid         
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
      
module.exports = Test
