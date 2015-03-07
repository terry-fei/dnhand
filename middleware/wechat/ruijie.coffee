Then = require 'thenjs'
ruijie = require '../../lib/ruijieHelper'
com = require './common'
ImageText = com.ImageText
log = require '../../lib/log'

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

  charge: (info, req, res) ->
    openid = info.FromUserName
    user = info.user

    Then (cont) ->
      StudentService.get user.stuid, null, cont

    .then (cont, student) ->
      unless student.rjpswd
        req.wxsession.status = 'bindRuijie'
        res.reply '请回复锐捷登录密码'
        return

      info.stuid = student.stuid
      user =
        stuid: student.stuid
        pswd: student.rjpswd
      ruijie.login user, cont

    .then (cont, loginResult) ->
      if loginResult.errcode isnt 0
        req.wxsession.status = 'bindRuijie'
        res.reply '请回复锐捷登录密码'
        return

      req.wxsession.status = 'charge'
      req.wxsession.ruijie =
        loginResult: loginResult
        stage: 'value'

      res.reply """
        请回复你要充值面额的编号
        【1】20元
        【2】30元
        【3】50元
      """

    .fail (cont, err) ->
      log.error err
      replyText = '发生错误，请稍候重试'
      try
        res.reply replyText
      catch e
        com.sendText openid, replyText


  replyStatus: (info, req, res) ->
    openid = info.FromUserName
    user = info.user

    Then (cont) ->
      StudentService.get user.stuid, null, cont

    .then (cont, student) ->
      unless student.rjpswd
        req.wxsession.status = 'bindRuijie'
        res.reply '请回复锐捷登录密码'
        return

      info.stuid = student.stuid
      user =
        stuid: student.stuid
        pswd: student.rjpswd
      ruijie.login user, cont

    .then (cont, loginResult) ->
      if loginResult.errcode isnt 0
        req.wxsession.status = 'bindRuijie'
        res.reply '请回复锐捷登录密码'
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
      res.reply arr.join('\n')

    .fail (cont, err) ->
      log.error err
      replyText = '发生错误，请稍候重试'
      try
        res.reply replyText
      catch e
        com.sendText openid, replyText

  changePolicy: (info, req, res) ->
    openid = info.FromUserName
    user = info.user

    Then (cont) ->
      StudentService.get user.stuid, null, cont

    .then (cont, student) ->
      unless student.rjpswd
        req.wxsession.status = 'bindRuijie'
        res.reply '请回复锐捷登录密码'
        return

      info.stuid = student.stuid
      user =
        stuid: student.stuid
        pswd: student.rjpswd
      ruijie.login user, cont

    .then (cont, loginResult) ->
      if loginResult.errcode isnt 0
        req.wxsession.status = 'bindRuijie'
        res.reply '请回复锐捷登录密码'
        return

      req.wxsession.status = 'changePolicy'
      req.wxsession.ruijie =
        loginResult: loginResult
        stage: 'policy'

      res.reply """
        请回复你要变更套餐的编号
        【1】20元30小时套餐
        【2】30元60小时套餐
        【3】50元150小时套餐
      """

    .fail (cont, err) ->
      log.error err
      replyText = '发生错误，请稍候重试'
      try
        res.reply replyText
      catch e
        com.sendText openid, replyText
