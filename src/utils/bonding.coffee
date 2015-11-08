util = require 'util'
exec = require('child_process').exec
async = require 'async'
fs = require 'fs'

execute = (command, callback) ->
    callback false unless command?
    util.log "executing #{command}..."        
    exec command, (error, stdout, stderr) =>
        if error
            callback false
        else
            callback true   


#modprobe bonding
#echo "4" > /sys/class/net/bond0/bonding/mode
#echo "+bond1" > /sys/class/net/bonding_masters
#echo "4" > /sys/class/net/bond1/bonding/mode
#echo "+bond2" > /sys/class/net/bonding_masters
#echo "4" > /sys/class/net/bond2/bonding/mode

enableBonding = (callback)->
#step1 :
    bondifs = ["bond1","bond2","bond3","bond4"]
    #console.log "createbonding input data ", JSON.stringify config
    async.series([
        (callback)=>
            console.log "create bonding interface"
            filename = "/etc/modprobe.d/bonding.conf"
            text = "alias bond0 bonding \noptions bonding mode=4\n"
            fs.writeFileSync(filename,text)

            command = "modprobe bonding"
            execute command,(result)=>  
                console.log "Result ", result
                if result is false
                    callback new Error ('load bonding driver failed') 
                else
                    callback(null,"load bonding driver success")         
        ,
        (callback)=>
            console.log "creating a multiple  bond interfaces"
            console.log bondifs
            async.each bondifs, (ifname,callback) =>
                console.log "interface  #{ifname}"
                command = "echo \"+#{ifname}\" > /sys/class/net/bonding_masters"
                execute command,(result)=>
                    #callback new Error ('attaching  interface failed ') if result instanceof Error
                    #callback new Error 'create bond interface failed' if result is false 
                    command = "echo \"4\" > /sys/class/net/#{ifname}/bonding/mode"
                    execute command,(result)=>
                        console.log "Result ", result
                        if result is false 
                            callback new Error 'create bond interface failed'
                        else
                            callback (null)
            ,(err) =>
                if err
                    console.log  "creating multiple bond inferfaces failed - error occured " + JSON.stringify err
                    callback err
                else
                    console.log  "creating muliple bond interfaces - success "
                    callback(null,"creating multiple bond interfaces - success")
        ],
        (err,result)=>
            console.log "Bonding -  RUN result is  %s ", result
            return callback false if err
            return callback true unless err

        )


module.exports = enableBonding