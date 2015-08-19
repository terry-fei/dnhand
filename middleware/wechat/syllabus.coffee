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
  weekday = "今天是第#{moment().week() - 36}周"
  result = [new ImageText(weekday, '', '', _getDayPic(day))]

  for num, courseArray of syllabus
    numStr = num + '. '
    for course in courseArray
      courseStr = """
        #{numStr}#{course.name}
        @#{course.room}  -> #{course.week}
        """
      result.push new ImageText(courseStr, '', '', _getNumPic(num))

  if result.length is 1
    result.push(new ImageText('没课', '', '', _getNumPic(0)))

  return result

_formatSyllabus = (day, syllabus) ->
  if day is 0
    weekday = '              未分配时间的课程'
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
    result.push(new ImageText("                             没课"))

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
  switch String(num)
    when '1' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVYe3XZXu3BdjI7eDR52ezTCorhITOjkEkYyoPwTChIPbwQsjxkOmiaKw/0?wx_fmt=png'
    when '2' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrV1Db0MFBdfbic3Mg87zUQjvhjgsyUFbfdPSAuTAYwZHIkvqgcficMoP5Q/0?wx_fmt=png'
    when '3' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVckUJD273n7VEQrhMUNRKYjQncGwrcicQODwUh1TwQ6yZicB6nnenTBTQ/0?wx_fmt=png'
    when '4' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVspHbL7LQ1XrUMoEluufzqqN9qBDh1tm6Ozuo7BzmWoUQYIRNVo92Dg/0?wx_fmt=png'
    when '5' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVFsobs6KpdnpAJs1coXaibq6iatQbbQuGCRO0a0ibs4ZuZRHVWMnQQOqcQ/0?wx_fmt=png'
    when '6' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVZBcxHvMbNwMLW8dvH6ic70p7Gb5G1uCTvtiaN95ic60b6eMEL3xu6lkww/0?wx_fmt=png'
    when '7' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVej3N9ztX9ToyM4KW30O1IxicEA9l2lTEg93IcwVXGeTiaSJ2JVicNmeoA/0?wx_fmt=png'
    when '8' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVUYhNJc7O3Q4oy6sDRMM3RyXW6iayT0aqqvzqRLSD5fqZxMBwXPCWeBw/0?wx_fmt=png'
    when '9' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVJ0Enl7MUZhS1SYC6NRtpc7VIUGPWTib6weXCbh5KRun3C5Fdozb3G0w/0?wx_fmt=png'
    when '0' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVZVWib7h43wThm4d8jBam5DDnMIMB7VkBHGo2LX6tiblrwulicdPnAaK2g/0?wx_fmt=png'
