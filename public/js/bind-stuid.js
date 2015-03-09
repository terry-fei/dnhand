$(function () {
  var stuid,
    pswd;
  $("#commit").on("click", function (e) {
    if(!$("#stuid").val()){
      $.dialog({
        content : '请输入学号！',
        title: "alert",
        time : 2000
      });
      return
    }else if(!$("#pswd").val()) {
      $.dialog({
        content : '请输入密码!',
        title: "alert",
        time : 2000
      });
      return
    } else {
      $.dialog()
      stuid = $("#stuid").val();
      pswd = $("#pswd").val();
      $.post("/bind", {
          'stuid': stuid,
          'pswd': pswd,
          'openid': openid
        }, function (res) {
            $(".rDialog").remove()
            $(".rDialog-mask").remove()
            if(!!res) {
              if(!res.errcode){
                setTimeout(function () {
                  WeixinJSBridge.invoke('closeWindow',{},function(res){});
                }, 3000);
                $.dialog({
                  content : '绑定成功！\n开启查成绩课表模式~',
                  title: "alert",
                  time : 3000
                });
              } else if(res.errcode === 2) {
                $("#pswd").val('');
                $("#pswd").focus();
                $.dialog({
                  content : '学号或密码错误',
                  title: "alert",
                  time : 2000
                });
              } else {
                $.dialog({
                  content : '服务器开小差了，请稍候再试',
                  title: "alert",
                  time : 2000
                });
              }
            } else {
              $.dialog({
                  content : '服务器开小差了，请稍候再试',
                  title: "alert",
                  time : 2000
              });
            }
        }, "json");
    }
  });
});
