$(function () {

  $("#bindBtn").on("click", function (e) {
    var stuid = $("#stuid").val();
    var pswd = $("#pswd").val();

    if(!stuid) {
      $.weui.topTips('请输入学号');
      $("#stuid").focus();
      return;
    }

    if(!pswd) {
      $.weui.topTips('请输入教务处密码');
      $("#pswd").focus();
      return;
    }

    $.weui.loading('正在绑定...');

    $.post("/jwc/bind", {
      'stuid': stuid,
      'pswd': pswd
    }, function (res) {
      $.weui.hideLoading();

      if(res.errcode === 0) {
        $.weui.alert('绑定成功！<br>解锁高级功能~', function () {
          WeixinJSBridge.invoke('closeWindow', {}, function(res){});
        });

      } else if(res.errcode === 2) {
        $.weui.alert('学号或密码错误', function () {
          $("#pswd").val('');
          $("#pswd").focus();
        });

      } else {
        $.weui.alert('服务器开小差了<br>请稍候再试！', function () {});
      }
    }, "json");
  });
});
