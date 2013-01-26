/* Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license */
var fs = require('fs'), path = require('path'), mkdirs = require('dirs').mkdirs
// all files are cached in /gen under the main project directory
var base_dir = process.env.uSDLC_base_path
var base_length = base_dir.length
// check for out-of-date files and recompile on an as-needs basis.
// morph(source, target-ext, builder)
//   builder(error, target-file-name, code, saver)
//     saver(error, code, next)
//       next(error)
var morph = function (source, target_ext, builder) {
    var target = source
    if (source.length > base_length && source.substring(0,base_length) == base_dir) {
        // drop base so that we can find out where gen/ starts from
        target = source.substring(base_length)
    }
    var target = path.join(base_dir, 'gen', (target + target_ext))

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
module.exports = morph
// Extend node require() to include a new source file type
// Has to be synhronous because require() is synchronous
module.exports.extend_require = function (source_ext, compiler) {
  require.extensions[source_ext] = function(module, source) {
    morph(source, '.js', function(error, filename, code, save) {
      compiler(error, filename, code, function(error, js) {
        save(error, js)
      })
      require.extensions['.js'](module, filename)
    })
  }
}
// Helper for coffee-script derivatives to compile to Javascript
// Has to be asynchronous because some compilers are asynchronous
module.exports.compileJavascript = function(source, compiler, next) {
    morph(source, '.js', function(error, filename, content, save) {
        if (error) return next(error, filename)
        if(content) {
            js = compiler.compile(content, {filename:filename})
            save(null, js, function(error) {return next(error, filename)})
        } else {
            next(null, filename)
        }
    })
}
