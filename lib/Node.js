// Generated by CoffeeScript 1.9.3
(function() {
  var HWADDR_PREFIX, HWADDR_START, StormData, StormRegistry, async, extend, getHwAddress, ip, log, node, request, util, vmctrl;

  StormRegistry = require('stormregistry');

  StormData = require('stormdata');

  util = require('util');

  request = require('request-json');

  extend = require('util')._extend;

  ip = require('ip');

  async = require('async');

  vmctrl = require('./builder/vmCtrl');

  log = require('./utils/logger').getLogger();

  log.info("Node - Logger test message");

  HWADDR_PREFIX = "00:00:00:00:00:";

  HWADDR_START = 10;

  getHwAddress = function() {
    var hwaddr;
    HWADDR_START++;
    hwaddr = "" + HWADDR_PREFIX + HWADDR_START;
    return hwaddr;
  };

  node = (function() {
    function node(data) {
      this.ifmap = [];
      this.ifindex = 1;
      this.config = extend({}, data);
      this.config.ifmap = this.ifmap;
      this.statistics = {};
      this.status = {};
      log.debug("node object created with  " + JSON.stringify(this.config));
    }

    node.prototype.addLanInterface = function(brname, ipaddress, subnetmask, gateway, characterstics) {
      var interf;
      interf = {
        "ifname": "eth" + this.ifindex,
        "hwAddress": getHwAddress(),
        "brname": brname,
        "ipaddress": ipaddress,
        "netmask": subnetmask,
        "gateway": gateway != null ? gateway : void 0,
        "type": "lan",
        "veth": this.config.name + "_veth" + this.ifindex,
        "config": characterstics
      };
      log.debug("lan interface " + JSON.stringify(interf));
      this.ifindex++;
      return this.ifmap.push(interf);
    };

    node.prototype.addWanInterface = function(brname, ipaddress, subnetmask, gateway, characterstics) {
      var interf;
      interf = {
        "ifname": "eth" + this.ifindex,
        "hwAddress": getHwAddress(),
        "brname": brname,
        "ipaddress": ipaddress,
        "netmask": subnetmask,
        "gateway": gateway != null ? gateway : void 0,
        "type": "wan",
        "veth": this.config.name + "_veth" + this.ifindex,
        "config": characterstics
      };
      log.debug("waninterface " + JSON.stringify(interf));
      this.ifindex++;
      return this.ifmap.push(interf);
    };

    node.prototype.addMgmtInterface = function(ipaddress, subnetmask) {
      var interf;
      interf = {
        "ifname": "eth0",
        "hwAddress": getHwAddress(),
        "ipaddress": ipaddress,
        "netmask": subnetmask,
        "type": "mgmt"
      };
      log.debug("mgmt interface" + JSON.stringify(interf));
      return this.ifmap.push(interf);
    };

    node.prototype.create = function(callback) {
      log.info("createing node " + JSON.stringify(this.config));
      return vmctrl.create(this.config, (function(_this) {
        return function(result) {
          _this.uuid = result.id;
          _this.config.id = _this.uuid;
          _this.status.result = result.status;
          if (result.reason != null) {
            _this.status.result = result.reason;
          }
          log.info("node creation result " + JSON.stringify(result));
          return callback(result);
        };
      })(this));
    };

    node.prototype.start = function(callback) {
      log.info("starting a node " + this.config.name);
      return vmctrl.start(this.uuid, (function(_this) {
        return function(result) {
          log.info("node start result " + JSON.stringify(result));
          return callback(result);
        };
      })(this));
    };

    node.prototype.stop = function(callback) {
      log.info("stopping a node " + this.config.name);
      return vmctrl.stop(this.uuid, (function(_this) {
        return function(result) {
          log.info("node stop result " + JSON.stringify(result));
          return callback(result);
        };
      })(this));
    };

    node.prototype.trace = function(callback) {
      return vmctrl.packettrace(this.uuid, (function(_this) {
        return function(res) {
          log.info("node packettrace result " + res);
          return callback(res);
        };
      })(this));
    };

    node.prototype.del = function(callback) {
      log.info("node deleting  " + this.config.name);
      return vmctrl.del(this.uuid, (function(_this) {
        return function(res) {
          log.info("node del result " + JSON.stringify(res));
          return callback(res);
        };
      })(this));
    };

    node.prototype.getstatus = function(callback) {
      log.info("getstatus called" + this.uuid);
      return vmctrl.get(this.uuid, (function(_this) {
        return function(result) {
          log.info("node getstatus result " + JSON.stringify(result));
          return callback(result);
        };
      })(this));
    };

    node.prototype.getrunningstatus = function(callback) {
      return vmctrl.status(this.params.id, (function(_this) {
        return function(res) {
          log.info("node running status result " + res);
          return callback(res);
        };
      })(this));
    };

    node.prototype.setLinkChars = function(ifname, callback) {
      var i, iface, len, ref, results, temp;
      ref = this.ifmap;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        iface = ref[i];
        if (iface.veth === ifname) {
          temp = extend({}, iface.config);
          temp.ifname = ifname;
          log.info("setLinkChars " + JSON(stringify(temp)));
          results.push(vmctrl.setLinkChars(temp, (function(_this) {
            return function(result) {
              return callback(result);
            };
          })(this)));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    node.prototype.get = function() {
      return {
        "id": this.uuid,
        "config": this.config,
        "status": this.status,
        "statistics": this.statistics
      };
    };

    return node;

  })();

  module.exports = node;

}).call(this);