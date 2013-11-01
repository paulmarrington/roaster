// Copyright (C) 2013 paul@marrington.net, see /GPL license
// Use steps.add(->) unless you need a js solution (startup)
function OneByOne() {
  this.queue = [];
}
OneByOne.prototype.add = function(action, next) {
  this.queue.push({action:action, next:next});
  if (this.queue.length === 1) this.next();
};
OneByOne.prototype.next = function() {
  if (!this.queue.length) return;
  var one = this.queue[0];
  var my = this;
  var next = function() {
    one.next();
    my.queue.shift();
    my.next();
  };
  one.action.call(this, next);
};

module.exports = OneByOne;
