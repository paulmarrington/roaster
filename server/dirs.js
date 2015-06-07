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
  var error = null;
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
      if (error) return next(error);
      var delete_one = function() {
        if (files.length === 0) {
          return fs.rmdir(path, callback(next));
        }
        var curPath = path + "/" + files.pop();
        fs.stat(curPath, callback(function(err, stats) {
          if (error) return next(error);
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
    try { process.chdir(to); } catch(e) {
      console.log("Error: can't change to "+to);
      throw e; }
    action();
  } finally {
    process.chdir(cwd);
  }
};

var __slice = [].slice;

var node = function() {
  var names = (1 <= arguments.length) ?
      __slice.call(arguments, 0) : [];
  return path.join.apply(path,
             [process.env.rwd].concat(names));
};

var base = function() {
  var names = (1 <= arguments.length) ?
      __slice.call(arguments, 0) : [];
  return path.join.apply(path,
             [process.env.cwd].concat(names));
};

var home = function() {
  var home = process.env.HOME || process.env.HOMEPATH ||
    process.env.USERPROFILE;
  var names = (1 <= arguments.length) ?
      __slice.call(arguments, 0) : [];
  return path.join.apply(path, [home].concat(names));
};

// Normalise a path - ensuring path separator is always slash /
var normalise = function(full_path) {
    full_path = path.normalize(full_path);
    if (path.sep !== '/') {
        full_path = full_path.replace(new RegExp("\\"+path.sep,"g"), "/");
    }
    return full_path;
};

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
  normalise: normalise,
  normalize: normalise,
  split: split,
  node: node, base: base, home: home, 
  bases: [process.env.cwd, process.env.rwd, '']
};
