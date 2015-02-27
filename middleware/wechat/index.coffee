wechat = require 'wechat'

syllabusMsg = require './syllabus'
gradeMsg = require './grade'
examMsg = require './exam'
ruijieMsg = require './ruijie'
comMsg = require './common'
statusMsg = require './status'
ImageText = comMsg.ImageText

OpenIdService = require '../../services/OpenId'

textHandler = (info, req, res) ->

  key = info.Content
  user = info.user

  switch
    when key is '绑定'
      comMsg.replyBind info, res

    when /.*(课|课程)表/.test key
      return comMsg.replyBind(info, res) unless user.stuid

      res.reply ''
      info.day = switch
        when !!~ key.indexOf '今'   then 0
        when !!~ key.indexOf '明'   then 1
        when !!~ key.indexOf '大后'  then 3
        when !!~ key.indexOf '后'   then 2
        when !!~ key.indexOf '昨'   then -1
        when !!~ key.indexOf '大前'  then -3
        when !!~ key.indexOf '前'   then -2

      if info.day? then syllabusMsg.replyByDay info else syllabusMsg.replyAll info

    when /.*(成绩|分数)/.test key
      switch
        when !!~ key.indexOf '本学期'
          return comMsg.replyBind(info, res) unless user.stuid
          gradeMsg.replyNow info, res

        when !!~ key.indexOf '不及格'
          return comMsg.replyBind(info, res) unless user.stuid
          gradeMsg.replyNoPass info, res

        when /.*(四|六|四六)级/.test key
          req.wxsession.status = 'cet'
          cet =
            stage: 'name'
          req.wxsession.cet = cet
          res.reply '请回复考生姓名'
        else
          return comMsg.replyBind(info, res) unless user.stuid
          gradeMsg.replyAll info, res

    when key is '补考'
      return comMsg.replyBind(info, res) unless user.stuid

      res.reply '正在查询补考信息...'
      examMsg.replyMarkUp info

    when key is '期末'
      return comMsg.replyBind(info, res) unless user.stuid

      res.reply '正在查询期末考试信息...'
      examMsg.replyTermEnd info

    when key is '准考证'
      res.reply """
        请回复身份证号查询四六级准考证
        仅限农大同学
        """

    when key is '绑定锐捷'
      return comMsg.replyBind(info, res) unless user.stuid
      req.wxsession.status = 'bindRuijie'
      res.reply '请回复锐捷登录密码'

    when key is '网络状态'
      return comMsg.replyBind(info, res) unless user.stuid
      res.reply '正在查询...'
      ruijieMsg.replyStatus info

    when key.length is 18
      url = "http://202.118.167.91/bm/cetzkz/images/#{key}.jpg"
      title = "四六级准考证"
      description = """
        请点击查看你的准考证
        如果没有看到准考证图片
        请检查并重新回复身份证号
        """
      return res.reply([new ImageText(title, description, url, url)])

    when key is '更新'
      return comMsg.replyBind(info, res) unless user.stuid
      res.reply ''
      comMsg.updateUserInfo(info)

    else
      comMsg.replyUsage info, res

eventHandler = (info, req, res) ->

  user = info.user
  switch info.Event
    when 'CLICK'

      switch info.EventKey
        when 'todaysyllabus'
          return comMsg.replyBind(info, res) unless user.stuid

          res.reply ''
          syllabusMsg.replyByDay info

        when 'tomorrowsyllabus'
          return comMsg.replyBind(info, res) unless user.stuid

          res.reply ''
          info.day = 1
          syllabusMsg.replyByDay info

        when 'allsyllabus'
          return comMsg.replyBind(info, res) unless user.stuid

          res.reply ''
          syllabusMsg.replyAll info

        when 'nowgrade'
          return comMsg.replyBind(info, res) unless user.stuid
          gradeMsg.replyNow info, res

        when 'bjggrade'
          return comMsg.replyBind(info, res) unless user.stuid
          gradeMsg.replyNoPass info, res

        when 'allgrade'
          return comMsg.replyBind(info, res) unless user.stuid
          gradeMsg.replyAll info, res

        when 'cetgrade'
          req.wxsession.status = 'cet'
          cet =
            stage: 'name'
          req.wxsession.cet = cet
          res.reply '请回复考生姓名'

        when 'exam'
          res.reply """
          查询期末考试安排
          请回复"期末"

          查询补考信息
          请回复"补考"

          查询四六级准考证
          请回复身份证号查询四六级准考证
          仅限农大同学
          """

        when 'updateinfo'
          return comMsg.replyBind(info, res) unless user.stuid
          res.reply ''
          comMsg.updateUserInfo(info)

        when 'ruijiestatus'
          return comMsg.replyBind(info, res) unless user.stuid
          res.reply '正在查询...'
          ruijieMsg.replyStatus info

        else
          comMsg.replyUsage info, res

    when 'subscribe'
      comMsg.replyUsage info, res

    when 'unsubscribe'
      res.reply ''

    else
      comMsg.replyUsage info, res

module.exports = (req, res) ->
  info = req.weixin

  OpenIdService.getUser(info.FromUserName, 'stuid nickname sex').then (cont, user) ->
    info.user = user

    # 处理存在预先状态的消息
    if req.wxsession and req.wxsession.status
      statusMsg info, req, res
      return

    switch info.MsgType
      when 'text'
        textHandler info, req, res

      when 'event'
        eventHandler info, req, res

      else
        res.reply '暂不支持该消息类型'

  .fail (cont, err) ->
    console.trace err
    # ERROR handler
    try
      res.reply '公众号暂时无法提供服务'
    catch e
      comMsg.sendText info.FromUserName, '公众号暂时无法提供服务'

module.exports.comMsg = comMsg
