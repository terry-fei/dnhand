Then = require 'thenjs'
iconv   = require "iconv-lite"
urllib  = require 'urllib'
cheerio = require 'cheerio'
com = require './common'
ImageText = com.ImageText

module.exports =
  replyTermEnd: (info) ->
    openid = info.FromUserName
    user = info.user
    url = 'http://202.118.167.91/bm/ksap1/all.asp'
    getNeauExamInfo(user.stuid, '期末考试', url, openid)

  replyMarkUp: (info) ->
    openid = info.FromUserName
    user = info.user
    url = 'http://202.118.167.76/ksap/all.asp'
    getNeauExamInfo(user.stuid, '补考查询', url, openid)


getNeauExamInfo = (stuid, title, url, openid) ->
  Then (cont) ->
    opts =
      method: 'POST'
      data:
        keyword: stuid

    urllib.request url, opts, cont

  .then (cont, html, urllibRes) ->
    unless urllibRes.statusCode is 200
      com.sendText openid, "学校服务器累坏了，请稍候再试"
      return

    html = iconv.decode(html, 'GBK')
    msgs    = []
    $       = cheerio.load(html)
    items     = $('font tr')
    items.each (index, elem) ->
      children = $(this).find('font')
      msg       = {}
      msg.location  = children.eq(1).text().trim()
      msg.kch     = children.eq(2).text().trim()
      msg.courseName  = children.eq(3).text().trim()
      msg.stuid     = children.eq(4).text().trim()
      msg.stuName   = children.eq(5).text().trim()
      time      = children.eq(0).text().trim()
      if time.indexOf('请关注') isnt -1
        msg.time = '未安排'
        msg.location = '未安排'
      else if time.indexOf(msg.stuid) isnt -1
        msg.time = time[0..18]
      else
        msg.time = time
      msgs.push msg

    if msgs.length is 0
      com.sendText openid, "未查询到考试信息"

    else if msgs.length > 8
      examInfo = []
      nameAndStuidStr = '姓名:' + msgs[0].stuName + '\n' + '学号:' + msgs[0].stuid + '\n'
      examInfo.push('姓名:' + msgs[0].stuName + '\n')
      examInfo.push('学号:' + msgs[0].stuid + '\n')
      examInfo.push('------------------\n')
      for msg in msgs
        examInfo.push("科目名:#{msg.courseName}\n")
        examInfo.push("时间:#{msg.time}\n")
        examInfo.push("地点:#{msg.location}\n")
        examInfo.push("------------------\n")
      com.sendText openid, examInfo.join('')
    else
      result = []
      result.push(new ImageText("                #{title}"))
      nameAndStuidStr = '  姓名:' + msgs[0].stuName + '\n' + '  学号:' + msgs[0].stuid
      result.push(new ImageText(nameAndStuidStr))
      for msg in msgs
        examStr = """
          #{msg.courseName}
          时间:#{msg.time}
          地点:  #{msg.location}
          """
        result.push(new ImageText(examStr))

      com.sendNews openid, result

  .fail (cont, err) ->
    com.sendText openid, "学校服务器累坏了，请稍候再试"
