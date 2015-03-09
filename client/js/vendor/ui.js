var UI = {
    toast: function(a, c) {
        if (!a) {
            return ! 1
        }
        var d = $('<div class="ui_toast">' + a + "</div>");
        c = c || 1500;
        $("body").append(d);
        setTimeout(function() {
            d.addClass("ui_toast_show")
        },
        10);
        setTimeout(function() {
            d.removeClass("ui_toast_show");
            d.on("webkitTransitionEnd",
            function() {
                d.remove()
            })
        },
        c)
    },
    popHtml: function(a, c) {
        var d = "",
        e = document.createElement("div"),
        g = "";
        if ("object" == typeof c) {
            for (var f in c) {
                g += '<a href="javascript:;" data-val="' + f + '">' + c[f] + "</a>"
            }
        }
        e.className = "ui_layer";
        d += '<div class="ui_pop"><p>' + a + "</p>" + ("" == g ? '<div class="ui_btns"><a href="javascript:;" data-type="sure">\u786e\u5b9a</a></div>': '<div class="ui_btns">' + g + "</div>") + "</div>";
        e.innerHTML = d;
        document.getElementsByTagName("body")[0].appendChild(e);
        setTimeout(function() {
            $(".ui_pop", e).addClass("ui_pop_show")
        },
        0);
        $(e).on("touchmove",
        function(a) {
            a.preventDefault();
            return ! 1
        });
        return $(e)
    },
    alert: function(a, c) {
        var d = UI.popHtml(a, {
            sure: "\u786e\u5b9a"
        });
        $(".ui_btns a", d).on("click",
        function() {
            d.remove();
            "function" == typeof c && c()
        })
    },
    showLoading: function(a) {
        a = $('<div class="loadingBox"><div class="loading"><i class="icon_loading"></i><span>' + (a ? "&nbsp;&nbsp;" + a: "") + "</span></div></div>");
        $("body").append(a);
        return a
    },
    hideLoading: function(a) {
        a ? a.remove() : $(".loadingBox").remove()
    },
    confirm: function(a, c, d, e) {
        var g = UI.popHtml(a, {
            cancel: "\u53d6\u6d88",
            sure: d || "\u786e\u5b9a"
        });
        $(".ui_btns a", g).on("click",
        function() {
            var a = $(this).attr("data-val");
            g.remove();
            "function" == typeof c && "sure" == a ? c() : "function" == typeof e && "cancel" == a && e()
        })
    },
    showFnPage: function(a) {
        $(".page_show").addClass("show_fn_page");
        a.addClass("show_fn_page")
    },
    hideFnPage: function() {
        $(".show_fn_page").removeClass("show_fn_page")
    }
};

if (module && module.exports){
  module.exports = UI;
}
