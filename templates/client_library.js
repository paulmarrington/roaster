(function(window) {
  var document = window.document
  if (window.roaster && window.roaster.context['#{key}']) {
    var context = roaster.context['#{key}']
    if (context.document) document = context.document
    if (context.window) window = context.window
  }
  #{script};
})(window)
