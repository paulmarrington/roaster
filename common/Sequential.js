// Copyright (C) 2013 paul@marrington.net, see /GPL license
function Sequential() {
  this.queue = [];
}
Sequential.prototype.add = function(action, next) {
  this.queue.push({action:action, next:next});
  if (this.queue.length === 1) this.next();
};
Sequential.prototype.on_empty = function() {};
Sequential.prototype.next = function() {
  if (!this.queue.length) return this.on_empty();
  var one = this.queue[0];
  var my = this;
  var next = function() {
    one.next.apply(one, arguments);
    my.queue.shift();
    my.next();
  };
  one.action.call(this, next);
};

Sequential.list = function(list, end, action) {
  //list = list.slice(0);
  if (!action) action = end;
  next = function() {
    if (!list.length) return end(); // return null for end
    action(list.shift(), next);
    if (action.length == 1) next() // synchronous
  };
  next();
}
Sequential.actions = function(actions, end) {
  Sequential.list(actions, end, function(action, next) {
    action(next);
    if (action.length == 0) next(); // sync
  })
}
Sequential.object = function(object, end, action) {
  Sequential.list(Object.keys(object), end, action)
}

module.exports = Sequential;
