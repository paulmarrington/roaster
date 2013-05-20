/* Copyright (C) 2012 paul@marrington.net, see GPL for license */
var fs = require('fs'), path = require('path')
var mode = 0777 & (~process.umask());

var mkdirs = function (dir, next) {
  paths = []
  var existence = function(exists) {
    if (exists) {
      var mkdir = function() {
        if (paths.length == 0) return next()
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

var mkdirsSync = function (dir) {
  if (fs.existsSync(dir)) return
  var current = path.resolve(dir), parent = path.dirname(current);
  mkdirsSync(parent)
  fs.mkdirSync(current)
}

var rmdirs = function(path, next) {
  fs.readdir(path, function(err, files) {
    if (err) return next()
    var delete_one = function() {
      if (files.length === 0) {
        return fs.rmdir(path, next);
      }
      var curPath = path + "/" + files.pop();
      fs.stat(curPath, function(err, stats) {
        if(err) console.log(err)
        if (err) return
        if (stats.isDirectory()) { // recurse
          rmdirs(curPath, delete_one);
        } else { // delete file
          fs.unlink(curPath, delete_one);
        }
      })
    }
    delete_one()
  })
}
// run a function with current working directory set - then set back afterwards
var in_directory = function(to, action) {
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

var node = function() {
  var names = (1 <= arguments.length) ? __slice.call(arguments, 0) : [];
  return path.join.apply(path, [process.env.uSDLC_node_path].concat(names));
}

var base = function() {
  var names = (1 <= arguments.length) ? __slice.call(arguments, 0) : [];
  return path.join.apply(path, [process.env.uSDLC_base_path].concat(names));
}

// bases used to find relative address files
process.env.uSDLC_base_path = fs.realpathSync(process.env.uSDLC_base_path)
process.env.uSDLC_node_path = fs.realpathSync(process.env.uSDLC_node_path)

// split and return [base,relative] based on known bases
var split = function(full_path) {
  var to_find = path.resolve(full_path)
  for (var i = 0, l = module.exports.bases.length; i < l; i++) {
    var base = module.exports.bases[i]
    if (!base.length) base = process.cwd()
    if (to_find.slice(0, base.length) === base) {
      return [base, to_find.slice(base.length)]
    }
  }
  console.log("NOT FOUND\n")
  return ['', full_path]
}

module.exports = {
  mkdirs: mkdirs,
  mkdirsSync: mkdirsSync,
  rmdirs: rmdirs,
  in_directory: in_directory,
  split: split,
  node: node, base: base, 
  bases: ['',process.env.uSDLC_base_path, process.env.uSDLC_node_path]
}
