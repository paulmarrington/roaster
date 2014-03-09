/* Copyright (C) 2013 paul@marrington.net, see /GPL license */
// tweak module loading path
var module = require('module'), path = require('path');
globalPaths = [];
var dlm = path.delimiter, sep = path.sep;
var ext = path.resolve(process.execPath, "..", "..", "..");
var rwd = path.resolve(ext, ".."); process.env.rwd = rwd;
var cwd = process.cwd(); process.env.cwd = cwd;
function ap(p) { globalPaths.push(p); }
function nwd(bwd) {
  ap(bwd);
  globalPaths.push(
    bwd+sep+"server", bwd+sep+"common", bwd+sep+"scripts");
}
nwd(cwd); nwd(rwd);
ap([ext,"node_modules"].join(sep));
ap([ext,"node","lib","node_modules"].join(sep));
// var np = ext+"/node/bin".replace(/\//g, sep);
var np = [ext,"node","bin"].join(sep);
process.env.PATH = np + dlm + process.env.PATH;
process.env.NODE_PATH = globalPaths.join(dlm);
module._initPaths();

// load modules required for base operation
var modules = [
  'send', 'coffee-script', 'underscore'
];
// Now load languages that can be used in node requires()
// js: javascript comes for free with V8
extend_require = require('morph').extend_require;
extend_for = function(compile, ext) {
  extend_require(ext, function(error, filename, content, save) {
    var js = '';
    if (content) {
      try {
        js = compile(content, {filename:filename});
      } catch (error) {
        console.log("Error compiling "+filename+ ": " + error);
      }
      save(null, js);
    } else if (content === '') {
      save(null,''); // Empty file, not undefined because already compiled
    }
  });
};

// load required modules and when done extend requires and go on
// with processing. Sequential as npm requires that dammit
var npm = require('npm');
loader = function(index) {
  npm(modules[index], function() {
    if (++index < modules.length) {
      loader(index);
    } else {
      extend_for(require('coffee-script').compile, '.coffee');
      require("init");
      // and lastly, require the main module from the command line to run it
      require(process.argv[2]);
    }
  });
};
loader(0); // kick off the module loading