var _prefix = '[CORE.WT]';
WT = window.WT || {};
WT.Class = {
    create: function() {
        return function() {
            this._init.apply(this, arguments);
        };
    }
};
console.log(_prefix + 'START');
M = window.M || WT.Main || {};
M.loadScript = function(src, cb) {
    var j = document.createElement("script");
    j.setAttribute("type", "text/javascript");
    j.setAttribute("src", src);
    if ( !! window.attachEvent) {
        j.onreadystatechange = function() {
            if (j.readyState == "loaded" || j.readyState == "complete") {
                if (typeof(cb) == 'function') {
                    cb();
                }
            }
        };
    } else {
        if (typeof(cb) == 'function') {
            j.onload = cb;
        }
    }
    document.getElementsByTagName("head")[0].appendChild(j);
};
M.mask = WT.Class.create();
M.mask.prototype = {
    _z: 100,
    mask: null,
    float: null,
    _init: function() {
        var _obj = this,
        _arg = arguments;
        _obj._z = ($('.greyLayer').length + 2) * 10;
        if (_arg.length == 0) {
            this._showMask();
        } else {
            var _ar = _arg[0];
            if (typeof _ar == 'object') {
                var _c = (typeof _ar.close == 'undefined') ? false: !!_ar.close;
                if (!_ar.id) _ar.id = '#maskBox';
                _obj.float = $(_ar.id);
                if (_obj.float.css('display') == 'none') {
                    if (_ar.title || _ar.content) {
                        _obj._showCustom(_ar.title, _ar.content, _ar.time);
                    }
                    _obj.float.css('z-index', _obj._z + 1).show();
                    _obj._showMask(_c);
                }
            } else if (typeof _ar == 'string') {
                _obj.float = $(_ar);
                if (_obj.float.css('display') == 'none') {
                    _obj.float.css('z-index', _obj._z + 1).show();
                    _obj._showMask();
                }
            }
        }
        $(document).bind('DOMNodeInserted',
        function(e) {
            if ($(e.target).html() != '') {
                var _bh = Math.max(document.body.scrollHeight, document.documentElement.scrollHeight),
                _gh = $('.greyLayer').height();
                if (_bh != _gh) {
                    $('.greyLayer').height(_bh);
                }
            }
        });
    },
    hide: function() {
        var _obj = this;
        _obj.float && _obj.float.hide();
        _obj.mask && _obj.mask.hide();
    },
    show: function() {
        var _obj = this;
        _obj.float && _obj.float.show();
        _obj.mask && _obj.mask.show();
    },
    _showMask: function() {
        var _obj = this,
        _arg = arguments,
        _mask = _obj._greyLayer(null, _obj._z);
        _obj.mask = $(_mask);
        _obj.mask.show();
        _arg.length == 0 ? false: _arg[0] && _obj.mask.click(function() {
            _obj.hide();
        });
    },
    _showCustom: function() {
        var _obj = this,
        _arg = arguments;
        var _t = _arg[0] || '',
        _c = _arg[1] || '',
        _s = !isNaN(_arg[2]) ? parseInt(_arg[2]) : 2;
        var _tip = $('#maskBox');
        _tip.find('h1').html(_t);
        _tip.find('p').html(_c);
        if (_s == 0) return;
        setTimeout(function() {
            _obj.hide();
        },
        _s * 1000);
    },
    _greyLayer: function() {
        var _id = arguments[0] || (new Date()).getTime(),
        _zIndex = arguments[1] || this._z,
        _mask = document.createElement("div");
        _mask.id = 'greyLayer_' + _id;
        _mask.className = 'greyLayer';
        _mask.style.position = "fixed";
        _mask.style.zIndex = _zIndex;
        _scrollWidth = Math.max(document.body.scrollWidth, document.documentElement.scrollWidth);
        _scrollHeight = Math.max(document.body.scrollHeight, document.documentElement.scrollHeight);
        _mask.style.width = _scrollWidth + "px";
        _mask.style.height = _scrollHeight + "px";
        _mask.style.top = "0px";
        _mask.style.left = "0px";
        _mask.style.display = "none";
        _mask.style.background = "#33393C";
        _mask.style.filter = "alpha(opacity=60)";
        _mask.style.opacity = "0.60";
        document.body.appendChild(_mask);
        this._z = _zIndex;
        return _mask;
    }
};