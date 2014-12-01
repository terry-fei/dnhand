_       = require('lodash')
Then    = require('thenjs')
moment  = require('moment')
wechat  = require('wechat')
moment.locale('zh-cn')

Student  = require('../services/Student')
OpenId   = require('../services/OpenId')
Syllabus = require('../services/Syllabus')
Grade    = require('../services/Grade')

cons = require('../lib/constants')
wechatApi = require('../lib/wechatApi')

class ImageText
  constructor: (@title, @description = '', @url = '', @picurl = '') ->

module.exports = wechat.text (req, res) ->

  # 处理存在预先状态的消息
  if req.wxsession and req.wxsession.hasStatus
    dealWithStatus req, res
    return

.event (req, res) ->

  switch req.weixin.Event
    when 'CLICK'
      key = req.weixin.EventKey

    when 'subscribe'
      openid = req.weixin.FromUserName
      Then (cont) ->
        OpenId.getUser openid, cont
      .then (cont, user) ->
        if user.stuid
          Student.get user.stuid, cont
        else
          cont(null, user)
      .fin (cont, error, result) ->
        isBind = !!result.stuid
        name = if isBind then result.name else result.nickname
        name ？= '同学'
        its = [new ImageText('             如何优雅的使用')]
        its.push new ImageText(cons.subscribe(name: name))
        unless isBind
          its.push new ImageText('       点我绑定账户', '', "http://n.feit.me/bind/#{openid}")
        res.reply its

    when 'unsubscribe'
      openid = req.weixin.FromUserName
      #OpenId.unBind openid

    else
      res.reply()
