/**
 * Spec-compliant `Function.prototype.bind` polyfill specifically published to
 * use within PhantomJS, which does not ship with this method.
 *
 * All code was extracted from https://github.com/zloirock/core-js and is in no
 * way my own work. The core-js MIT license has been retained.
 *
 * Background:
 *
 * The Mozilla `Function.prototype.bind` polyfill results in a failure during
 * Babel's `_classCallCheck` with this message:
 *
 *   "Cannot call a class as a function"
 *
 * Specifically, this would be triggered by Babel compiled code such as:
 *
 *   var store = new (_bind.apply(_Store, [null].concat(constructorArgs)))();
 */

(function() {
  // Do not overwrite exsiting Function#bind:
  if (Function.prototype.bind) return;

  // Everything below is from core-js:
  function aFunction(it){
    if(typeof it != 'function') throw TypeError(it + ' is not a function!');
    return it;
  };

  function isObject (it){
    return it !== null && (typeof it == 'object' || typeof it == 'function');
  };

  var _slice = [].slice;
  var factories = {};

  function construct(F, len, args){
    if(!(len in factories)){
      for(var n = [], i = 0; i < len; i++)n[i] = 'a[' + i + ']';
      factories[len] = Function('F,a', 'return new F(' + n.join(',') + ')');
    }
    return factories[len](F, args);
  };

  function invoke(fn, args, that){
    var un = that === undefined;
    switch(args.length){
      case 0: return un ? fn()
                        : fn.call(that);
      case 1: return un ? fn(args[0])
                        : fn.call(that, args[0]);
      case 2: return un ? fn(args[0], args[1])
                        : fn.call(that, args[0], args[1]);
      case 3: return un ? fn(args[0], args[1], args[2])
                        : fn.call(that, args[0], args[1], args[2]);
      case 4: return un ? fn(args[0], args[1], args[2], args[3])
                        : fn.call(that, args[0], args[1], args[2], args[3]);
    } return              fn.apply(that, args);
  };

  Function.prototype.bind = function bind(that /*, args... */){
    var fn       = aFunction(this)
      , partArgs = _slice.call(arguments, 1);
    var bound = function(/* args... */){
      var args = partArgs.concat(_slice.call(arguments));
      return this instanceof bound ? construct(fn, args.length, args) : invoke(fn, args, that);
    };
    if(isObject(fn.prototype))bound.prototype = fn.prototype;
    return bound;
  }
})();
