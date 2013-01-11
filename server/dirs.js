/* Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license */
var fs = require('fs'), path = require('path')
var mode = 0777 & (~process.umask());

mkdirs = function (dir) {
  if (fs.existsSync(dir)) return
  var current = path.resolve(dir), parent = path.dirname(current);
  mkdirs(parent)
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
};

module.exports = {
    mkdirs: mkdirs,
    rmdirs: deleteFolderRecursive
}