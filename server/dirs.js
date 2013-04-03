/* Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license */
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

deleteFolderRecursive = function(path) {
    var files = [];
    if( fs.existsSync(path) ) {
        files = fs.readdirSync(path);
        files.forEach(function(file,index){
            var curPath = path + "/" + file;
            if(fs.statSync(curPath).isDirectory()) { // recurse
                deleteFolderRecursive(curPath);
            } else { // delete file
                fs.unlinkSync(curPath);
            }
        });
        fs.rmdirSync(path);
    }
}
// run a function with current working directory set - then set back afterwards
in_directory = function(to, action) {
  var cwd = process.cwd()
  try {
    process.chdir(to)
    action()
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
