Then = require 'thenjs'
urllib  = require 'urllib'
StudentService  = require '../../services/Student'
GradeService  = require '../../services/Grade'

com = require './common'
ImageText = com.ImageText

module.exports =
  replyNow: (info, res) ->
    openid = info.FromUserName
    user = info.user

    Then (cont) ->
      info.stuid = user.stuid
      GradeService.get user.stuid, 'qb', cont

    .then (cont, grade) ->
      unless grade
        return res.reply "您的信息已过期，请回复“更新”，获取最新信息"

      result = grade['qb']['2014-2015学年秋(两学期)']
      if not result or result.length is 0
        return res.reply('暂时还没有上学期成绩信息')

      gradeStr = ["学号：#{info.stuid}\n\n"]
      for item in result
        gradeStr.push("#{item.kcm}\n")
        gradeStr.push("成绩：#{item.cj}\n")
        gradeStr.push("------------------\n")
      gradeStr.push("仅显示及格科目成绩！")
      res.reply gradeStr.join('')

    .fail (cont, err) ->
      # handle err

  replyNoPass: (info, res) ->
    openid = info.FromUserName
    user = info.user

    res.reply '正在查询。。。'

    Then (cont) ->

      info.stuid = user.stuid
      GradeService.get user.stuid, 'bjg', cont

    .then (cont, grade) ->
      unless grade
        return res.reply "您的信息已过期，请回复“更新”，获取最新信息"

      nowStr = ["学号：#{info.stuid}\n\n"]
      now = grade['bjg']['尚不及格']
      nowStr.push '--尚不及格--\n'
      if not now or now.length is 0
        nowStr.push '没有尚不及格科目'
      else
        for item in now
          nowStr.push("#{item.kcm}\n")
          nowStr.push("成绩：#{item.cj}\n")
          nowStr.push("学分：#{item.xf}\n")
          nowStr.push("考试时间：#{item.kssj}\n")
          nowStr.push("------------------\n")

      everStr = ["学号：#{info.stuid}\n\n"]
      ever = grade['bjg']['曾不及格']
      everStr.push '\n--曾不及格--\n'
      if not ever or ever.length is 0
        everStr.push '没有曾不及格科目'
      else
        for item in ever
          everStr.push("#{item.kcm}\n")
          everStr.push("成绩：#{item.cj}\n")
          everStr.push("学分：#{item.xf}\n")
          everStr.push("考试时间：#{item.kssj}\n")
          everStr.push("------------------\n")

      com.sendText openid everStr.join('')
      com.sendText openid nowStr.join('')

    .fail (cont, err) ->
      # handle err

  replyAll: (info, res) ->
    title = "东农助手"
    desc = """
          请点击本消息查看全部成绩
          """
    url = "http://n.feit.me/info/allgrade?openid=#{info.FromUserName}"
    logoUrl = "http://n.feit.me/public/dnhandlogo.jpg"
    imageTextItem = new ImageText(title, desc, url, logoUrl)
    res.reply([imageTextItem])

  replyCet: (info) ->
    openid = info.FromUserName
    cetNum = info.cetNum
    name = info.name
    cetGradeUrl = "http://www.chsi.com.cn/cet/query?zkzh=#{cetNum}&xm=#{encodeURIComponent(name)}"
    opts =
      dataType: 'text'
      headers:
        'Referer': 'http://www.chsi.com.cn/cet/'
    Then (cont) ->
      urllib.request cetGradeUrl, opts, cont

    .then (cont, cetHtml, urllibRes) ->
      unless urllibRes.statusCode is 200
        com.sendText openid, '服务器忙，请稍候再试'
        return

      if /无法找到对应的分数/.test(cetHtml)
        com.sendText openid, '未找到相关成绩，请检查你回复的准考证号和姓名并重试'
        return

      cetHtml = cetHtml.replace(/\n/g, '').replace(/\r/g, '').replace(/\t/g, '')
      grade =
        schoolName: /学校：<\/th><td>(.*?)<\/td>/.exec(cetHtml)[1]
        name: /姓名：<\/th><td>(.*?)<\/td>/.exec(cetHtml)[1]
        type: /考试类别：<\/th><td>(.*?)<\/td>/.exec(cetHtml)[1]
        cetNumber: /准考证号：<\/th><td>(.*?)<\/td>/.exec(cetHtml)[1]
        examDate: /考试时间：<\/th><td>(.*?)<\/td>/.exec(cetHtml)[1]
        totle: /<span class=\"colorRed\">(.*?)<\/span>/.exec(cetHtml)[1].trim()
        listening: /听力：<\/span>(.*?)<br \/>/.exec(cetHtml)[1].trim()
        read: /阅读：<\/span>(.*?)<br \/>/.exec(cetHtml)[1].trim()
        write: /写作与翻译：<\/span>(.*?)<\/td>/.exec(cetHtml)[1].trim()

      if grade and grade.name is name
        result = [new ImageText("                #{grade.type}成绩")]
        gradeStr = """
          姓名：#{grade.name}
          学校：#{grade.schoolName}
          考试时间：#{grade.examDate}

          总分：#{grade.totle}
          听力：#{grade.listening}
          阅读：#{grade.read}
          写作和翻译：#{grade.write}
        """
        result.push(new ImageText(gradeStr))

        com.sendNews openid, result
      else
        com.sendText openid, '未找到相关成绩，请检查你回复的准考证号和姓名并重新回复\'cet\''

    .fail (cont, err) ->
      com.sendText openid, '服务器忙，请稍候再试'
      return
