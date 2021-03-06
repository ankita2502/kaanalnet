// Generated by CoffeeScript 1.9.3
(function() {
  var keystore, store, validate;

  store = require("jfs");

  validate = require('json-schema').validate;

  keystore = (function() {
    function keystore(dbname, Schema) {
      if (!((dbname != null) && (Schema != null))) {
        return false;
      }
      this.schema = Schema;
      this.db = new store(dbname, {
        type: 'memory',
        saveId: true
      });
      return true;
    }

    keystore.prototype.validate = function(data) {
      var chk;
      chk = validate(data, this.schema);
      console.log('validate result ', chk);
      if (!chk.valid) {
        throw new Error("schema check failed" + chk.valid);
        return false;
      }
      return true;
    };

    keystore.prototype.add = function(data) {
      var result;
      if (data == null) {
        return false;
      }
      result = this.validate(data);
      if (result === false) {
        return result;
      }
      return this.db.save(data, function(err, id) {
        console.log("error is ", err);
        console.log("id is", id);
        if (id != null) {
          return id;
        }
        if (err != null) {
          return err;
        }
      });
    };

    keystore.prototype.del = function(id) {
      if (id == null) {
        return false;
      }
      return this.db["delete"](id, function(err) {
        if (err != null) {
          return err;
        }
        return true;
      });
    };

    keystore.prototype.get = function(id) {
      if (id == null) {
        return false;
      }
      return this.db.get(id, function(err, obj) {
        if (err != null) {
          return err;
        }
        return obj;
      });
    };

    keystore.prototype.list = function() {
      return this.db.all(function(err, objs) {
        if (err != null) {
          return err;
        }
        return objs;
      });
    };

    keystore.prototype.update = function(id, data) {
      var result;
      if (!((id != null) && (data != null))) {
        return false;
      }
      result = this.validate(data);
      if (result === false) {
        return result;
      }
      return this.db["delete"](id, (function(_this) {
        return function(err) {
          if (err != null) {
            return err;
          }
          return _this.db.save(id, data, function(err) {
            return true;
          });
        };
      })(this));
    };

    return keystore;

  })();

  module.exports = keystore;

}).call(this);
