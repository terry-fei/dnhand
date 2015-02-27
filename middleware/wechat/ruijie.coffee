Then = require 'thenjs'
ruijie = require '../../lib/ruijieHelper'
com = require './common'
ImageText = com.ImageText

StudentService = require '../../services/Student'

module.exports =
  bind: (info) ->
    pswd = info.pswd
    openid = info.FromUserName
    user = info.user

    Then (cont) ->

      user.pswd = pswd
      info.student = user
      ruijie.login user, cont

    .then (cont, loginResult) ->

      if loginResult.errcode isnt 0
        replyText = '你回复的锐捷登录密码不正确，请回复"绑定锐捷"重试'
        com.sendText openid, replyText
      else
        stuid = info.student.stuid
        pswd = info.student.pswd
        StudentService.updateRuijiePswd stuid, pswd, cont
        replyText = '成功绑定锐捷账户，可以使用相关功能了'
        com.sendText openid, replyText

    .fail (cont, err) ->
      console.trace err
      replyText = '未知错误，请回复"绑定锐捷"重试'
      com.sendText openid, replyText

  replyStatus: (info) ->
    openid = info.FromUserName
    user = info.user

    Then (cont) ->
      StudentService.get user.stuid, null, cont

    .then (cont, student) ->
      unless student.rjpswd
        com.sendText openid, '请回复"锐捷绑定"，绑定之后再使用'
        return

      info.stuid = student.stuid
      user =
        stuid: student.stuid
        pswd: student.rjpswd
      ruijie.login user, cont

    .then (cont, loginResult) ->
      if loginResult.errcode isnt 0
        com.sendText openid, '你的锐捷认证失败，请回复"锐捷绑定"重新认证'
        return

      ruijie.currentState loginResult, cont

    .then (cont, state) ->
      arr = ["#{info.stuid}", "------------------"]
      if !state.onlineCount
        arr.push("账号当前没有在线")
      else
        arr.push("账号当前在线")
        arr.push("在线IP地址：\n#{state.onlineIp}")
        arr.push("上线时间：\n#{state.onlineTime}")
      arr.push("------------------")
      arr.push("账号状态：#{state.userstate}")
      arr.push("余额：#{state.currentAccountFeeValue}, 待扣款：#{state.currentPrepareFee}")
      arr.push("账号套餐：\n#{state.policydesc}")
      if state.userstate is "正常"
        arr.push("套餐周期：\n#{state.rangeStart}至#{state.rangeEnd}")
        arr.push("已用时长：\n#{state.usedTime}")
      com.sendText openid, arr.join('\n')

    .fail (cont, err) ->
      logger.trace err
      replyText = '未知错误，请稍候重试'
      com.sendText openid, replyText
