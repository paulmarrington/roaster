// Copyright (C) 2013 paul@marrington.net, see /GPL license
function Sequential() {
  this.queue = [];
}
Sequential.prototype.add = function(action, next) {
  this.queue.push({action:action, next:next});
  if (this.queue.length === 1) this.next();
};
Sequential.prototype.next = function() {
  if (!this.queue.length) return;
  var one = this.queue[0];
  var my = this;
  var next = function() {
    one.next.apply(one, arguments);
    my.queue.shift();
    my.next();
  };
  one.action.call(this, next);
};

module.exports = Sequential;
