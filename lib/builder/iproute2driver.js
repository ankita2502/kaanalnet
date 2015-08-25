// Generated by CoffeeScript 1.9.3
(function() {
  var IPRoute2, Schema, exec, fs, util, validate;

  util = require('util');

  exec = require('child_process').exec;

  fs = require('fs');

  validate = require('json-schema').validate;

  Schema = {
    name: "netem",
    type: "object",
    required: true,
    properties: {
      ifname: {
        "type": "string",
        "required": true
      },
      bandwidth: {
        "type": "string",
        "required": true
      },
      latency: {
        "type": "string",
        "required": false
      },
      jitter: {
        "type": "string",
        "required": false
      },
      pktloss: {
        "type": "string",
        "required": false
      }
    }
  };

  IPRoute2 = (function() {
    var setBandwidth, setDelayLoss, setLinkChars;

    function IPRoute2() {}

    setDelayLoss = function(data, callback) {
      var command, correlation, distribution, ifname, latency, loss, variation;
      ifname = data.ifname;
      latency = data.latency;
      distribution = "normal";
      variation = data.jitter;
      correlation = "10%";
      loss = data.pktloss;
      correlation = "10%";
      command = "tc qdisc add dev " + ifname + " root handle 1:0  netem delay " + latency + " " + variation + " " + correlation + " distribution " + distribution + " loss " + loss + " " + correlation;
      util.log("netstats executing " + command + "...");
      return exec(command, (function(_this) {
        return function(error, stdout, stderr) {
          if (error != null) {
            util.log("netstats: execute - Error : " + error);
          }
          if (stdout != null) {
            util.log("netstats: execute - stdout : " + stdout);
          }
          if (stderr != null) {
            util.log("netstats: execute - stderr : " + stderr);
          }
          return callback(true);
        };
      })(this));
    };

    setBandwidth = function(data, callback) {
      var avgpkt, bandwidth, command, ifname;
      ifname = data.ifname;
      avgpkt = "1000";
      bandwidth = data.bandwidth;
      command = "tc qdisc add dev " + ifname + " parent 1:1 handle 10: tbf rate  " + bandwidth + " buffer 1600 limit 3000";
      util.log("netstats executing " + command + "...");
      return exec(command, (function(_this) {
        return function(error, stdout, stderr) {
          if (error != null) {
            util.log("netstats: execute - Error : " + error);
          }
          if (stdout != null) {
            util.log("netstats: execute - stdout : " + stdout);
          }
          if (stderr != null) {
            util.log("netstats: execute - stderr : " + stderr);
          }
          return callback(true);
        };
      })(this));
    };

    setLinkChars = function(data, callback) {
      var chk;
      chk = validate(data, Schema);
      console.log('validate result ', chk);
      if (!chk.valid) {
        throw new Error("schema check failed" + chk.valid);
        return callback(false);
      }
      callback(true);
      util.log("setLinkChars data input " + JSON.stringify(data));
      return this.setDelayLoss(data, (function(_this) {
        return function(result) {
          util.log("setDelay result" + result);
          return _this.setBandwidth(data, function(result) {
            return util.log("setBandwidth result " + result);
          });
        };
      })(this));
    };

    return IPRoute2;

  })();

  module.exports = new IPRoute2;

}).call(this);