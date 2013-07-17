(function(window) {
  var steps = roaster.steps
  var require = roaster.request.requireSync
  var process = roaster.process
  var module = {exports:{}}
  var exports =  module.exports;
  #{definitions};
  var log = function() {console.log(arguments)};
  #{script};
  roaster.cache['#{url}'] = module.exports
})(window)