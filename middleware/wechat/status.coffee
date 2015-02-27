Then = require 'thenjs'
com = require './common'
ruijieMsg = require './ruijie'
gradeMsg = require './grade'

ImageText = com.ImageText

module.exports = (info, req, res) ->
  status = req.wxsession.status
  content = info.Content

  delStatus = (flag) ->
    req.wxsession.destroy()
    if flag then com.sendText info.FromUserName, '已返回正常模式' else res.reply '已返回正常模式'

  if /(取消|退出|返回)/.test content
    return delStatus()

  switch status
    when 'bindRuijie'
      res.reply '正在验证你的密码'
      delStatus(true)
      info.pswd = content
      ruijieMsg.bind info

    when 'cet'
      cet = req.wxsession.cet
      unless cet
        return delStatus()

      switch cet.stage
        when 'name'
          cet.name = content
          cet.stage = 'number'
          res.reply '请回复准考证号'

        when 'number'
          info.name = cet.name
          info.cetNum = content
          res.reply '正在查询，查询速度视网络情况而定'
          gradeMsg.replyCet info
          delStatus(true)

        else
          delStatus()



    else
      delStatus()
