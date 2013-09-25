/* Copyright (C) 2012 paul@marrington.net, see /GPL license */
var fs = require('fs'), path = require('path');
var mode = 0777 & (~process.umask());

var mkdirs = function (dir, next) {
  paths = [];
  var existence = function(exists) {
    if (exists) {
      var mkdir = function() {
        if (paths.length === 0) return next();
        fs.mkdir(paths.pop(), mkdir);
      };
      mkdir();
    } else {
      paths.push(dir);
      fs.exists(dir = path.dirname(dir), existence);
    }
  };
  fs.exists(dir, existence);
};

var mkdirsSync = function (dir) {
  if (fs.existsSync(dir)) return;
  var current = path.resolve(dir);
  var parent = path.dirname(current);
  mkdirsSync(parent);
  fs.mkdirSync(current);
};

var rmdirs = function(path, next) {
  error = null;
  var callback = function(next) {
    return function() {
      if (arguments[0]) {
        error = arguments[0];
      }
      next.apply(this, arguments);
    };
  };
  var _rmdirs = function(path, next) {
    fs.readdir(path, callback(function(err, files) {
      if (error) return next();
      var delete_one = function() {
        if (files.length === 0) {
          return fs.rmdir(path, callback(next));
        }
        var curPath = path + "/" + files.pop();
        fs.stat(curPath, callback(function(err, stats) {
          if (error) return next();
          if (stats.isDirectory()) { // recurse
            _rmdirs(curPath, callback(delete_one));
          } else { // delete file
            fs.unlink(curPath, callback(delete_one));
          }
        }));
      };
      delete_one();
    }));
  };
  _rmdirs(path, next);
};
// run a function with current working directory set
// then set back afterwards
var in_directory = function(to, action) {
  var cwd = process.cwd();
  try {
    process.chdir(to);
    action();
  } catch(e) {
    console.log("Error: can't change to "+to);
    throw e;
  } finally {
    process.chdir(cwd);
  }
};

var __slice = [].slice;

var node = function() {
  var names = (1 <= arguments.length) ?
      __slice.call(arguments, 0) : [];
  return path.join.apply(path,
             [process.env.uSDLC_node_path].concat(names));
};

var base = function() {
  var names = (1 <= arguments.length) ?
      __slice.call(arguments, 0) : [];
  return path.join.apply(path,
             [process.env.uSDLC_base_path].concat(names));
};

// bases used to find relative address files
process.env.uSDLC_base_path =
  fs.realpathSync(process.env.uSDLC_base_path);
process.env.uSDLC_node_path =
  fs.realpathSync(process.env.uSDLC_node_path);

// split and return [base,relative] based on known bases
var split = function(full_path) {
  var to_find = path.resolve(full_path);
  bases = module.exports.bases;
  for (var i = 0, l = bases.length; i < l; i++) {
    var base = bases[i];
    if (!base.length) base = process.cwd();
    if (to_find.slice(0, base.length) === base) {
      return [base, to_find.slice(base.length)];
    }
  }
  return ['', full_path];
};

module.exports = {
  mkdirs: mkdirs,
  mkdirsSync: mkdirsSync,
  rmdirs: rmdirs,
  in_directory: in_directory,
  split: split,
  node: node, base: base, 
  bases: ['',process.env.uSDLC_base_path,
             process.env.uSDLC_node_path]
};
