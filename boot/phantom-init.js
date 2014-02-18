// Run by phantomjs to load a page
console.log("uSDLC2 PhantomJS Initialisation");

if ( typeof(phantom) !== "undefined" ) {
  var system = require('system');
  var args = system.args;
  var page = require('webpage').create();

  // Route "console.log()" calls from within the Page context
  // to the main Phantom context (i.e. current "this")
  page.onConsoleMessage = function(msg) { console.log(msg); };
  page.onAlert = function(msg) { console.log(msg); };
  
  if (args.length > 1) {
    page.open(args[1]);
  }
}