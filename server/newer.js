/* Copyright (C) 2013 paul@marrington.net, see /GPL  license */
var fs = require('fs');

module.exports = function(left, right) {
    function modified(file_name) {
      try {
        return fs.statSync(file_name).mtime.getTime();
      } catch (exception) {
        return 0;
      }
    }
    // we only need to rebuild if source is newer
    return modified(left) > modified(right);
};