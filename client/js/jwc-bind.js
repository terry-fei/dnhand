$(function () {

  $("#bindBtn").on("click", function (e) {
    var stuid = $("#stuid").val(),
      pswd = $("#pswd").val();

    if(!stuid){
      UI.toast('请输入学号');
      $("#stuid").focus()
      return

    }else if(!pswd) {
      UI.toast('请输入教务处密码');
      $("#pswd").focus();
      return

    } else {
      UI.showLoading('正在绑定...');
      
      $.post("/jwc/bind", {
          'stuid': stuid,
          'pswd': pswd
        }, function (res) {
            UI.hideLoading();
            if(res.errcode === 0){
              UI.alert('绑定成功！<br>解锁高级功能~', function () {
                WeixinJSBridge.invoke('closeWindow',{},function(res){});
              });

            } else if(res.errcode === 2) {
              UI.alert('学号或密码错误', function () {
                $("#pswd").val('');
                $("#pswd").focus();
              });

            } else {
              UI.alert('服务器开小差了<br>请稍候再试！');
            }
        }, "json");
    }
  });
});
