// Generated by CoffeeScript 1.9.3
(function() {
  var InstallLXCBaseContainer, exec, templatepath, util;

  util = require('util');

  exec = require('child_process').exec;

  console.log("setup container");

  templatepath = __dirname + "/lxc-ubuntu";

  console.log("template is ", templatepath);

  InstallLXCBaseContainer = function(cb) {
    var command;
    command = "lxc-create -t " + templatepath + " -n nodeimg ";
    console.log("executing " + command + "...");
    return exec(command, (function(_this) {
      return function(error, stdout, stderr) {
        console.log("installing LXC Base container - Error : " + error);
        console.log("Installing LXC Base container - stdout : " + stdout);
        console.log("Installing LXC Base container - stderr : " + stderr);
        if (error != null) {
          return cb(false);
        } else {
          return cb(true);
        }
      };
    })(this));
  };

  console.log("Installing LXC ubuntu base image");

  InstallLXCBaseContainer((function(_this) {
    return function(result) {
      return console.log("InstallLXCBaseContainer completed - result " + result);
    };
  })(this));

}).call(this);
