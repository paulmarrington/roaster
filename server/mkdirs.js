/* Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license */
var fs = require('fs'), path = require('path')
var mode = 0777 & (~process.umask());

module.exports = mkdirs = function (dir) {
  if (fs.existsSync(dir)) return
  var current = path.resolve(dir), parent = path.dirname(current);
  mkdirs(parent)
  fs.mkdirSync(current)
}