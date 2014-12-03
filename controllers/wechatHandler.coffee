_       = require('lodash')
Then    = require('thenjs')
wechat  = require('wechat')
logger  = require('winston')
moment  = require('moment')
moment.locale('zh-cn')

cons = require('../lib/constants')
wechatApi = require('../lib/wechatApi')

openIdService = require '../services/OpenId'
studentService = require '../services/Student'
syllabusService = require '../services/Syllabus'

class ImageText
  constructor: (@title, @description = '', @url = '', @picurl = '') ->

module.exports = wechat.text((info, req, res) ->
  # 处理存在预先状态的消息
  if req.wxsession and req.wxsession.hasStatus
    dealWithStatus req, res
    return

  res.reply 'haha'

).event((info, req, res) ->
  switch info.Event
    when 'CLICK'

      switch info.EventKey
        when 'todaySyllabus'
          info.day = moment().day()
          info.day = 7 if info.day is 0
          getSyllabusByDay(info, res)

        when 'tomorrowsyllabus'
          day = moment().day() + 1
          getSyllabusByDay(info, res)

        else
          res.reply()

    when 'subscribe'
      openid = info.FromUserName
      Then (cont) ->
        openIdService.getUser openid, cont
      .then (cont, user) ->
        its = [new ImageText('             如何优雅的使用')]
        its.push new ImageText(cons.subscribe(name: user.nickname))
        unless user.stuid
          its.push new ImageText('   欢迎关注，点我绑定账户', '', "http://n.feit.me/bind/openid=#{openid}")
        res.reply its

    when 'unsubscribe'
      res.reply()

    else
      res.reply()

)

getSyllabusByDay = (info, res) ->
  Then (cont) ->
    openIdService.getUser info.FromUserName, 'stuid', cont

  .then (cont, user) ->
    unless user.stuid
      res.reply '查询课表需先绑定账户\n   请回复"绑定"'
    else
      syllabusService.getSyllabus user.stuid, "#{info.day}", cont

  .then (cont, syllabus) ->
    syllabus = syllabus[info.day]
    res.reply syllabus.toString()

  .fail(cont, err) ->
    logger.error err
    res.reply '发生错误，请稍候再试'
