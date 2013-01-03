/* Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license */
var fs = require('fs'), path = require('path'), mkdirs = require('mkdirs')
// all files are cached in /gen under the main project directory
var base_dir = process.env.uSDLC_base_path, base_length = base_dir.length
var gen_dir = base_dir + '/gen'

var build = function (source, target_ext, builder) {
    var target = source
    if (source.length > base_length && source.substring(0,base_length) == base_dir) {
        // drop base so that we can find out where gen/ starts from
        target = source.substring(base_length)
    }
    var target = path.normalize(gen_dir + target + target_ext)

    // Get modified dates for source and target files
    var stat = fs.statSync(source)
    var source_modified = stat.mtime.getTime()
    var target_modified
    try {
        target_modified = fs.statSync(target).mtime.getTime()
    } catch (exception) {
        target_modified = 0
    }
    // we only need to rebuild if source is newer
    if (source_modified > target_modified) {
        var code = fs.readFileSync(source, 'utf8')
        if (code.charCodeAt(0) === 0xFEFF) {
            code = code.substring(1);
        }
        mkdirs(path.dirname(target))
        builder(null, target, code, function(error, built) {
          fs.writeFileSync(target, built, 'utf8')
        })
    } else {
      builder(null, target)
    }
    return target
}

module.exports = build
module.exports.extend_require = function (source_ext, builder) {
  require.extensions[source_ext] = function(module, source) {
    build(source, '.js', function (error, filename, js, next) {
      builder(error, filename, js, next)
      require.extensions['.js'](module, filename)
    })
  }
}
