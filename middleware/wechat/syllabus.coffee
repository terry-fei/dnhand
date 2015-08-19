Then = require 'thenjs'
moment  = require 'moment'
moment.locale 'zh-cn'

SyllabusService = require '../../services/Syllabus'

com = require './common'
ImageText = com.ImageText

class ImageText
  constructor: (@title, @description = '', @url = '', @picurl = '') ->

module.exports =
  replyAll: (info) ->
    openid = info.FromUserName
    user = info.user

    Then (cont) ->

      SyllabusService.get user.stuid, null, cont

    .then (cont, syllabus) ->

      unless syllabus
        replyMsg "您的信息已过期，请回复“更新”，获取最新信息"
        com.sendText openid, replyMsg
        return

      syllabuses = []
      for i in [0...7]
        syllabuses.push _formatSyllabus(i, syllabus[i])

      interval = 500
      startTime = -500
      syllabuses.forEach (syllabusItem) ->
        startTime += interval
        sendSyllabusItem = -> com.sendNews openid, syllabusItem
        setTimeout(sendSyllabusItem, startTime)

    .fail (cont, err) ->
      # handle err

  replyByDay: (info) ->
    openid = info.FromUserName
    user = info.user

    Then (cont) ->

      info.day = if info.day
        absDay = (moment.utc().add(8, 'hours').day() + info.day) % 7
        absDay = 7 + absDay if absDay < 0
        absDay
      else
        moment.utc().add(8, 'hours').day()

      if info.day is 0
        com.sendText openid, '星期天休息[愉快]' 
        return

      SyllabusService.get user.stuid, "#{info.day}", cont

    .then (cont, syllabus) ->
      unless syllabus
        replyMsg "您的信息已过期，请回复“更新”，获取最新信息"
        com.sendText openid, replyMsg
        return

      syllabus = syllabus[info.day]
      com.sendNews openid, _formatSyllabusOneDay(info.day, syllabus)

    .fail (cont, err) ->
      # handle err

_formatSyllabusOneDay = (day, syllabus) ->
  if day is 0
    weekday = '             未分配时间的课程'
  else
    weekday = "                       星期#{_transferNumDayToChinese(day)}"
  result = [new ImageText weekday]

  for num, courseArray of syllabus
    numStr = num + '.'
    for course in courseArray
      courseStr = """
        #{numStr}#{course.name}
        @#{course.room} -> #{course.week}
        """
      result.push new ImageText courseStr

  if result.length is 1
    result.push(new ImageText("                           没课"))

  result.push(new ImageText("            今天是第#{moment().week() - 36}周"))
  return result

_formatSyllabus = (day, syllabus) ->
  if day is 0
    weekday = '                 未分配时间'
  else
    weekday = "                       星期#{_transferNumDayToChinese(day)}"
  result = [new ImageText weekday]

  for num, courseArray of syllabus
    numStr = "第#{_transferNumDayToChinese(num)}节"
    for course in courseArray
      courseStr = """
        #{numStr}：#{course.name}
        教室： #{course.building}>#{course.room}
        任课教师： #{course.teacher}   学分：#{course.credit}
        上课周次：  #{course.week}
        """
      result.push new ImageText courseStr

  if result.length is 1
    result.push(new ImageText("                             无！"))

  result.push(new ImageText("            今天是第#{moment().week() - 36}周"))
  return result

_transferNumDayToChinese = (day) ->
  switch String(day)
    when '1' then '一'
    when '2' then '二'
    when '3' then '三'
    when '4' then '四'
    when '5' then '五'
    when '6' then '六'
    when '7' then '日'
