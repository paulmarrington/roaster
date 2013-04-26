/* Copyright (C) 2012 paul@marrington.net, see GPL for license */
var fs = require('fs'), path = require('path')
var mode = 0777 & (~process.umask());

mkdirs = function (dir, next) {
  paths = []
  existence = function(exists) {
    if (exists) {
      mkdir = function() {
        if (paths.length == 0) return next(null)
        fs.mkdir(paths.pop(), mkdir)
      }
      mkdir()
    } else {
      paths.push(dir)
      fs.exists(dir = path.dirname(dir), existence)
    }
  }
  fs.exists(dir, existence)
}

mkdirsSync = function (dir) {
  if (fs.existsSync(dir)) return
  var current = path.resolve(dir), parent = path.dirname(current);
  mkdirsSync(parent)
  fs.mkdirSync(current)
}

deleteFolderRecursive = function(path, next) {
  fs.readdir(path, function(err, files) {
    if (err) return next()
    var delete_one = function() {
      if (files.length === 0) {
        return fs.rmdir(path, next);
      }
      var curPath = path + "/" + files.pop();
      fs.stat(curPath, function(err, stats) {
        if(err)console.log(err)
        if (err) return
        if (stats.isDirectory()) { // recurse
          deleteFolderRecursive(curPath, delete_one);
        } else { // delete file
          fs.unlink(curPath, delete_one);
        }
      })
    };
    delete_one()
  });
}
// run a function with current working directory set - then set back afterwards
in_directory = function(to, action) {
  var cwd = process.cwd()
  try {
    process.chdir(to)
    action()
  } catch(e) {
    console.log("Error: can't change to "+to)
    throw e
  } finally {
    process.chdir(cwd)
  }
}

var __slice = [].slice;

node = function() {
  var names = (1 <= arguments.length) ? __slice.call(arguments, 0) : [];
  return path.join.apply(path, [process.env.uSDLC_node_path].concat(names));
};

base = function() {
  var names = (1 <= arguments.length) ? __slice.call(arguments, 0) : [];
  return path.join.apply(path, [process.env.uSDLC_base_path].concat(names));
};
// bases used to find relative address files
bases = [process.env.uSDLC_base_path, process.env.uSDLC_node_path]

module.exports = {
  mkdirs: mkdirs,
  mkdirsSync: mkdirsSync,
  rmdirs: deleteFolderRecursive,
  in_directory: in_directory,
  node: node, base:base, bases: bases
}
