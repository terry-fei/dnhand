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
    weekday = "今天是第#{moment().week() - 36}周"
  result = [new ImageText(weekday, '', '', _getDayPic(day))]

  for num, courseArray of syllabus
    numStr = num + '.'
    for course in courseArray
      courseStr = """
        #{numStr}#{course.name}
        @#{course.room} -> #{course.week}
        """
      result.push new ImageText(courseStr, '', '', _getNumPic(num))

  if result.length is 1
    result.push(new ImageText("                           没课"))

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

_getDayPic = (day) ->
  switch String(day)
    when '1' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVVtMbAALibR0icllx3rhibedGgZJJwqpicbnkbibNoaAbckE50vXA0y5ltQw/0?wx_fmt=jpeg'
    when '2' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVFFqSKyZJpca8OhOVXz1FCjF2leiaKfMFJAoU2CugmjdnaYSCkiagZs5A/0?wx_fmt=jpeg'
    when '3' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVayZ6ntbM7BoLoGj0rD49wsT8QAkF6zbVQGOiaILbd9zO6IsdbpibIU7A/0?wx_fmt=jpeg'
    when '4' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrV3P9ibcUv3zR4iap2E53OXAfpud3wHmYspLcM1ibB8hrpZy4eQl6zGw8gQ/0?wx_fmt=jpeg'
    when '5' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVicGb4Lls4Q709hBtf5HNjRbQ4AiapB9bYU0IF06YvxYiadbPphnrBDemw/0?wx_fmt=jpeg'
    when '6' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVGeZEnrIZ46UabZ1y7BHrblt2aHJfxicPYuQJcdznib7iaShgV7kt5Lqkg/0?wx_fmt=jpeg'
    when '7' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrV16XK64W34cZDfFH9IElbYQV7zuciadW0h0Q8PNaadtJDnYmtNp361gw/0?wx_fmt=jpeg'

_getNumPic = (num) ->
  switch String(day)
    when '1' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVQjTM12lkNMcK6cibaIy9fa7Q5rJzl0S5NXt6atptKuZThBUeu5NwS6Q/0?wx_fmt=png'
    when '2' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVgHjH2ff58K7t3pBmicB9ONSqmcgZTSy7PxrxLKBVenU38knF6O5qsqw/0?wx_fmt=png'
    when '3' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVXp9Kibibjb4MPPgocu8SvQZowbC6W48MmCO52PX7IZH0WicShW8Hv0N1Q/0?wx_fmt=png'
    when '4' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVsbDyAwIbtV7nayF0wSOqibxibBVeSk0lkW0P7f2rFp3qCPBhCicgYCLBQ/0?wx_fmt=png'
    when '5' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVIzlXqNg4fVEuGfDxf0TMp1Dh0mjDHQic7GlfibTc9LibdvXOnZ9wiczpjw/0?wx_fmt=png'
    when '6' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVX0L4Gkg8lnHYVpLb5RgwECtQnfCSRTSCCZZYhkAmibu36jwoCo4o8Ig/0?wx_fmt=png'
    when '7' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrV4dic98XicEAYzibXghiat9P3tKzbiavW5g6LyTBSK1vH6ZXzWZBvQ3QH6NA/0?wx_fmt=png'
    when '8' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVoOLwFKJR5oEbY7RsUxjCWnicoc8JhGpic7MClYJVYic3kBMQo8E7DfiaSg/0?wx_fmt=png'
    when '9' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVHcvyy4zgWsHuNnILmIibmebyUHCstO91mia4cGUWcL0g6qShxYVQV7Ow/0?wx_fmt=png'
    when '0' then ''
