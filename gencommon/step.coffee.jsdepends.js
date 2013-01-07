
_dependency_0=function(module){
  (function() {
  var step,
    __slice = [].slice;

  step = function() {
    var counter, next, pending, results, step_index, steps;
    steps = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    step_index = counter = pending = 0;
    results = [];
    next = function() {
      var args, err, fn, lock, result;
      err = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      counter = pending = 0;
      if (step_index >= steps.length) {
        if (err) {
          throw err;
        }
        return;
      }
      fn = steps[step_index++];
      results = [];
      try {
        lock = true;
        result = fn.apply(next, arguments);
      } catch (exception) {
        next(exception);
      }
      if (counter > 0 && pending === 0) {
        next.apply(null, results);
      } else if (result !== void 0) {
        next(void 0, result);
      }
      return lock = false;
    };
    next.parallel = function() {
      var parallel_index;
      parallel_index = ++counter;
      pending++;
      return function() {
        var args, err;
        err = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        pending--;
        if (err) {
          results[0] = err;
        }
        results[parallel_index] = args[0];
        if (!lock && pending === 0) {
          return next.apply(null, results);
        }
      };
    };
    next.group = function() {
      var check, error, localCallback, result;
      localCallback = next.parallel();
      counter = pending = 0;
      result = [];
      error = void 0;
      check = function() {
        if (pending === 0) {
          return localCallback.apply(null, [error].concat(__slice.call(result)));
        }
      };
      if (typeof process !== "undefined" && process !== null ? process.nextTick : void 0) {
        process.nextTick(check);
      } else {
        setTimeout(check, 0);
      }
      return function() {
        var args, error, index;
        error = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        index = counter++;
        pending++;
        return function() {
          pending--;
          result[index] = args[0];
          if (!lock) {
            return check();
          }
        };
      };
    };
    return next();
  };

  module.exports = step;

}).call(this);

}
