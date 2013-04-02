(function(window) {
  var steps = roaster.steps
  var require = roaster.requireSync
  var process = roaster.process
  var module = {exports:{}}
  var exports =  module.exports;
  #{script};
  roaster.cache['#{url}'] = module.exports
})(window)