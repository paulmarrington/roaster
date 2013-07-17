/* Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license */
var fs = require('fs'), path = require('path'), util = require('util')
var dirs = require('dirs'), newer = require('newer')
// check for out-of-date files and recompile on an as-needs basis.
// morph(source, target-ext, builder)
//   builder(error, target-file-name, code, saver)
//     saver(error, code, next)
//       next(error)
var multi_morph = function (source, reader, target_ext, builder) {
  var target = source
  if (source.indexOf('/gen/') == -1) {
    var split = dirs.split(source)
    var base_dir = split[0], source_name = split[1]
    target = path.join(base_dir, 'gen', source_name)
  }
  target += target_ext
  // we only need to rebuild if source is newer
  if (newer(source, target)) {
      var code = reader()
      if (code.charCodeAt(0) === 0xFEFF) {
          code = code.substring(1);
      }
      dirs.mkdirsSync(path.dirname(target))
      builder(null, target, code, function(error, built) {
        fs.writeFileSync(target, built, 'utf8')
      })
  } else {
    builder(null, target)
  }
  return target
}
var morph = function(source, target_ext, builder) {
  reader = function() { return fs.readFileSync(source, 'utf8') }
  return multi_morph(source, reader, target_ext, builder)
}
module.exports = morph
module.exports.multi_morph = multi_morph
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
        if (content) {
          try {
            var js = compiler.compile(content, {filename:filename})
            save(null, js)
          } catch(err) {
            console.log("Error compiling " + source +
              " to JavaScript\n" + util.inspect(err))
            throw err
          }
          next(error, filename, true)
        } else {
            next(null, filename, false)
        }
    })
}
// Simple morph that does nothing but copy to destination dir.
// Used when templates are going to up date source otherwise
module.exports.copier = function(source, next) {
    morph(source, '', function(error, filename, content, save) {
        if (error) return next(error, filename)
        if (content) {
          save(null, content)
          next(error, filename, true)
        } else {
          next(null, filename, false)
        }
    })
}

