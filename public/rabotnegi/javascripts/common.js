/* DO NOT MODIFY. This file was compiled Sat, 28 Jan 2012 10:36:45 GMT from
 * /Volumes/Code/abox/app/javascripts/common.coffee
 */

(function() {
  var Spinner;

  window.q = $;

  $.extend(Array.prototype, {
    last: function() {
      return this[this.length - 1];
    }
  });

  $.extend(String.prototype, {
    evalJSON: function() {
      return eval("(" + this + ")");
    },
    unescapeHTML: function() {
      return this.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
    },
    modelId: function() {
      var digitsFound;
      digitsFound = this.match(/\d+/);
      return digitsFound && digitsFound[0];
    },
    blank: function() {
      return /^\s*$/.test(this);
    },
    present: function() {
      return !this.blank();
    },
    trim: function() {
      return $.trim(this);
    },
    query: function() {
      return $(this.toString());
    }
  });

  jQuery.extend({
    initializers: {}
  });

  jQuery.fn.extend({
    self: function() {
      return this.get(0);
    },
    dump: function() {
      return this;
    },
    loaded: function(fn) {
      var _base, _name;
      if ((_base = $.initializers)[_name = this.selector] == null) {
        _base[_name] = [];
      }
      $.initializers[this.selector].push(fn);
      return this;
    },
    record_id: function() {
      return this.attr('id').split(/_|-/).last();
    },
    requiredField: function() {
      return this.each(function() {
        var input, tip;
        input = $(this);
        tip = input.attr('title');
        return input.blur(function() {
          if (input.val().present() && input.val() !== tip) {
            return input.removeClass('required-field');
          } else {
            return input.addClass('required-field');
          }
        });
      });
    },
    tooltip: function() {
      return this.each(function() {
        var input, tip;
        input = $(this);
        tip = input.attr('title');
        if (input.val().blank()) input.addClass('inner-tooltip').val(tip);
        input.focus(function() {
          if (input.val() === tip) {
            return input.removeClass('inner-tooltip').val('');
          }
        });
        input.blur(function() {
          if (input.val().blank()) return input.addClass('inner-tooltip').val(tip);
        });
        return input.closest('form').submit(function() {
          if (input.val() === tip) return input.val('');
        });
      });
    },
    toggle_slide_css3: function() {
      var height;
      if (this.height() === 0 || this.css("display") === "none") {
        this.css({
          display: "none",
          height: "auto"
        });
        height = this.height();
        this.css({
          display: "block",
          height: 0
        });
        return this.css({
          height: height
        });
      } else {
        return this.css({
          height: 0
        });
      }
    }
  });

  Spinner = function() {
    return $("<span>").addClass("spinner").text('загрузка...');
  };

  $(function() {
    var fn, initializers, selector, _ref, _results;
    _ref = $.initializers;
    _results = [];
    for (selector in _ref) {
      initializers = _ref[selector];
      if ($(selector).length) {
        _results.push((function() {
          var _i, _len, _results2;
          _results2 = [];
          for (_i = 0, _len = initializers.length; _i < _len; _i++) {
            fn = initializers[_i];
            _results2.push(fn());
          }
          return _results2;
        })());
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  });

}).call(this);
