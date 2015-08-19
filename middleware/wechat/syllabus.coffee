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
    for course in courseArray
      courseStr = "#{course.name}\n@#{course.room}  & #{course.week}"
      result.push new ImageText(courseStr, '', '', _getNumPic(num))

  if result.length is 1
    result.push(new ImageText('没课', '', '', _getNumPic(0)))

  return result

_formatSyllabus = (day, syllabus) ->
  if day is 0
    weekday = '              未分配时间的课程'
    result = [new ImageText weekday]
  else
    weekday = "今天是第#{moment().week() - 36}周"
    result = [new ImageText(weekday, '', '', _getDayPic(day))]

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
    when '1' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVkT0icVKl14Nx4WezJv2BsQ17xDkKlzRUAs2CubEOjhaSfoV0HxdcAmQ/0?wx_fmt=jpeg'
    when '2' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrV11zf8Og8bzQ8BebyZGGHDGicuoClNqJa63QMC8nWuAodE7l6A49YRYg/0?wx_fmt=jpeg'
    when '3' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVqFlLYQu5snW2MIoM3W1z4NM5P4aFV8NwFXG8oJ01yfy5yPNIJ0kia0w/0?wx_fmt=jpeg'
    when '4' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrViaIXicEah9fNIBiahvkawRTibwH27JzVKJmYMhD9PJgiaCbULI39XY8pnVg/0?wx_fmt=jpeg'
    when '5' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVXkJNaJ4oZSCBfylYJIic2gGrqf0MwmQIQMick7qItZkBrYX5h5ECicxDg/0?wx_fmt=jpeg'
    when '6' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVc1EKTyaLSp5LGtBka7nYUL3oKicqcZEF9kgphZa5dZCuibf5GRpG0dBA/0?wx_fmt=jpeg'
    when '7' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVrxCic0V6X5JUqXvsMicq7hpFVXYW1YF1sWhJ72Xuwy9fGK9T6WAMRVGA/0?wx_fmt=jpeg'
    when '8' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVQIdKjMSKsjFIS3nQmdJbnI0CYK5SDBDWqgAmoY5oEr1p489nPJJcjw/0?wx_fmt=jpeg'
    when '9' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVLWzjjOEsbf0ZywHN4akwORicXuT1toBkO2cKDJvJJjCib7jSibcyCeMew/0?wx_fmt=jpeg'
    when '0' then 'https://mmbiz.qlogo.cn/mmbiz/Um1Q0fUx415uYcic7VHib7tSaI0eYoFOrVBGRuibDzBmsKiaYlmoAVdwJDowfrsicMW9qM7s1COE45LEicuZhbQyjWQA/0?wx_fmt=jpeg'
