wechat  = require "wechat"
request = require "request"
Student = require '../models/Student'
OpenId  = require '../models/OpenId'
iconv = require 'iconv-lite'
cheerio = require 'cheerio'
async = require 'async'
_ = require 'lodash'
errorHandler = require('../errors').errorHandler
moment = require 'moment'
moment.locale("zh-cn")

wechatApi = require('../utils/wechat')

info = require './info'

class ImageText
  constructor: (title, description, url, picurl) ->
    @title = title
    @description = description
    @url = url
    @picurl = picurl

handler = (req, res) ->
  msg = req.weixin
  content = msg.Content ? msg.EventKey
  if msg.Event is "subscribe"
    res.reply('欢迎关注东农助手！')
    return replyUsage msg.FromUserName

  else if !content
    res.end('')
    return replyUsage msg.FromUserName
  else if req.wxsession.status
    dealWithStatus(req, res)

  else if content is "allgrade"
    info.getProfileByOpenid msg.FromUserName, (err, student) ->
      if err
        if err.message is 'openid not found'
          return res.reply "查询成绩需先绑定账户\n   请回复'绑定'"
        else
          err.openid = msg.FromUserName
          errorHandler(err)
          return

      desc = """
            #{student.name}同学

            请点击查看你的成绩单
            """
      url = "http://n.feit.me/info/allgrade/#{msg.FromUserName}"
      imageTextItem = new ImageText("#{student.name}同学的全部成绩", desc, url)
      return res.reply([imageTextItem])

  else if content is "nowgrade"
    getNowGrade(req, res)

  else if content is "bjggrade"
    getBjgGrade(req, res)

  else if content is 'xwdy'
    return res.reply('正在测试')

  else if content is "hi"
    title = "东农助手"
    desc = """
          嗨， 你好
          我的名字叫 费腾
          很高兴和你成为朋友
          安卓手机直接点这条信息就能添加我
          苹果手机或者没反应可以加我微信号
          微信号：q13027722
          """
    url = "weixin://contacts/profile/q13027722"
    imageTextItem = new ImageText(title, desc, url)
    return res.reply([imageTextItem])

  else if content is "剩余时长" or content is "sysc"
    needBindStuid msg.FromUserName, res, (student) ->
      if !student.rjpswd
        return res.reply("你还没有绑定锐捷客户端，请点击第二栏中的“锐捷”按钮绑定")
      info.getRjInfo student.stuid, student.rjpswd, (err, result) ->
        if err
          err.openid = msg.FromUserName
          return errorHandler(err)
        if result and result.errcode is 2
          return res.reply "身份过期，请回复“锐捷”重新认证"
        else if result.errcode is 0
          arr = ["#{student.stuid}", "------------------"]
          if !result.onlineCount
            arr.push("账号当前没有在线")
          else
            arr.push("账号当前在线")
            arr.push("在线IP地址：\n#{result.onlineIp}")
            arr.push("上线时间：\n#{result.onlineTime}")
          arr.push("------------------")
          arr.push("账号状态：#{result.userstate}")
          arr.push("余额：#{result.currentAccountFeeValue}, 待扣款：#{result.currentPrepareFee}")
          arr.push("账号套餐：\n#{result.policydesc}")
          if result.userstate is "正常"
            arr.push("套餐周期：\n#{result.rangeStart}至#{result.rangeEnd}")
            arr.push("已用时长：\n#{result.usedTime}")
          return res.reply arr.join('\n')
        else
          return res.reply "未知错误，请重试"

  else if content.toLowerCase() is "net" or content is "ruijie"
    needBindStuid msg.FromUserName, res, (student) ->
      if !student.rjpswd
        title = "锐捷相关服务"
        desc = "请点击本消息绑定锐捷客户端，绑定后可以使用查询剩余时长功能"
        url = "http://n.feit.me/rj/bind/#{student.stuid}/#{msg.FromUserName}"
        logoUrl = "http://n.feit.me/assets/dnhandlogo.jpg"
        imageTextItem = new ImageText(title, desc, url, logoUrl)
        return res.reply([imageTextItem])
      return res.reply "你已绑定锐捷客户端，可以查询剩余时长，请点击第二排中的按钮"
      ###
      title = "锐捷助手"
      desc = """
            点我进入锐捷服务手机网页
            """
      url = "http://neaucode.sinaapp.com/netcard?openid=#{msg.FromUserName}"
      logoUrl = "http://n.feit.me/assets/dnhandlogo.jpg"
      imageTextItem = new ImageText(title, desc, url, logoUrl)
      return res.reply([imageTextItem])
      ###

  else if  content is "招聘"
    desc = """
          招聘信息
          哈尔滨锐思科技有限公司

          UI设计师
          熟练使用PS，AI等制图软件
          有一定美术功底
          开发过网站页面优先
          有做图相关作品优先

          研发工程师
          有一定编程经验
          开发语言不限
          有Web，Android，IOS开发经验优先

          法律咨询顾问
          法学相关专业
          懂得基本法律常识
          学习能力强

          有意者请加我微信
          微信号：<a href="weixin://contacts/profile/q13027722">q13027722</a>
          """
    return res.reply desc

  else if content is "fankui"
    desc = """
          请回复“客服”
          进入客服系统

          进入客服系统后
          有问题请直接回复
          我会尽量帮助大家解决
          """
    return res.reply(desc)

  else if content is '客服'
    res.transfer2CustomerService()
    return wechatApi.sendText(msg.FromUserName, '已进入客服系统\n不过我有可能不在。。', errorHandler)

  else if content is "todaysyllabus" or content is "今天课表"
    day = moment().day()
    if day is 0
      day = 7
    getSyllabusByDay(req, res, day)

  else if content is "tomorrowsyllabus" or content is "明天课表"
    day = moment().day() + 1
    getSyllabusByDay(req, res, day)

  else if content is "allsyllabus" or content is "课表" or content is "全部课表"
    res.end('');
    getAllSyllabus(msg.FromUserName)

  else if content is "exam"
    return res.reply "请回复 '补考'+'学号' 查询补考信息\n例如查询学号为A19120000的补考信息\n'补考A19120000'"

  else if content.substring(0, 2) is "补考"
    stuid = content.substring(2)
    info.getExamInfo stuid, (err, msgs) ->
      if err
        err.openid = msg.FromUserName
        return errorHandler(err)
      _replyExamInfo(msgs, res)

  else if content is "cet"
    req.wxsession.status = "cet"
    req.wxsession.cetStep = 'replyCetNum'
    return res.reply '请回复你的准考证号，农大的同学如果忘记了准考证号可以先回复“取消”，再回复你的身份证号码查询'

  else if content is "排名"
    info.getProfileByOpenid msg.FromUserName, (err, student) ->
      if err
        if err.message is 'openid not found'
          return res.reply "查询排名需先绑定账户\n   请回复'绑定'"
        else
          err.openid = msg.FromUserName
          return errorHandler(err)
      info.getRank student.stuid, (err, grade) ->
        if err
          err.openid = msg.FromUserName
          return errorHandler(err)
        if grade
          clmpercent = Math.round(( (grade.clmcount - grade.clmrank + 1) / grade.clmcount) * 100)
          mjpercent = Math.round(( (grade.mjcount - grade.mjrank + 1) / grade.mjcount) * 100)

          result = []
          result.push(new ImageText("            #{grade.className}  #{grade.name}"))
          result.push(new ImageText("""
            智育成绩：#{grade.zyGrade}
            总学分绩：#{grade.totleGrade}
            班级排名：#{grade.clmrank}
            班级总人数：#{grade.clmcount}
            专业排名：#{grade.mjrank}
            专业总人数：#{grade.mjcount}
            你击败了班级：#{clmpercent}%的同学
            击败了同专业：#{mjpercent}%的同学
            """))
          return res.reply result
        else
          return res.reply('未找到相关信息')

  else if content.length is 18
    info.getCetNumByIdcard content, (err, result) ->
      if err
        if err.message == 'nothing'
          return res.reply '没有找到准考证信息'
        else
          err.openid = msg.FromUserName
          return errorHandler(err)
      title = "#{result.type}级准考证"
      description = "请点击查看你的#{result.type}级准考证"
      return res.reply([new ImageText(title, description, result.url)])

  else if content is '绑定'
    title = "东农助手"
    desc = """
          请点击本消息绑定学号
          """
    url = "http://n.feit.me/bind/#{msg.FromUserName}"
    logoUrl = "http://n.feit.me/assets/dnhandlogo.jpg"
    imageTextItem = new ImageText(title, desc, url, logoUrl)
    return res.reply([imageTextItem])
  else
    res.end('')
    return replyUsage msg.FromUserName

dealWithStatus = (req, res) ->
  status = req.wxsession.status
  weixin = req.weixin
  if weixin.Content is "取消" or weixin.Content is "退出" or !weixin.Content
    delete req.wxsession.status
    return res.reply "已返回正常模式"
  else if status is 'cet'
    step = req.wxsession.cetStep
    if step is 'replyCetNum'
      if weixin.Content.length is 15
        req.wxsession.cetNum = weixin.Content
        req.wxsession.cetStep = 'replyName'
        return res.reply '请回复你的姓名'
      else
        return res.reply '你回复的准考证号格式不正确'
    else if step is 'replyName'
      cetNum = req.wxsession.cetNum
      name = weixin.Content
      delete req.wxsession.status
      info.getCetGrade cetNum, name, (err, grade) ->
        if err
          if err.message == "nothing"
            return res.reply '未找到相关成绩，请检查你回复的准考证号和姓名并重试'
          else
            err.openid = msg.FromUserName
            return errorHandler(err)

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
          return res.reply result
        else
          return res.reply '未找到相关成绩，请检查你回复的准考证号和姓名并重新回复\'cet\''

needBindStuid = (openid, res, callback) ->
  info.getProfileByOpenid openid, (err, student) ->
    if err or !student
      if err and err.message is 'openid not found'
        return res.reply "使用此功能需先绑定账户\n   请回复'绑定'"
      else
        err.openid = msg.FromUserName
        return errorHandler(err)
    callback(student)

usage = _.template("""
  Hi， <%= somebody %>
  基本功能在下方的按钮中
  除此之外 回复以下关键字
  【net】充值网票和剩余时长
  【cet】查询四六级成绩
  【绑定】更换绑定的学号
  【排名】查看智育成绩排名
  【你的身份证号】四六级准考证

  部分功能正在建设中
  本助手每周更新
  欢迎邀请你身边的同学关注
""")

replyUsage = (openid) ->
  bindUrl = "http://n.feit.me/bind/#{openid}"
  result = [new ImageText('             如何优雅的使用')]
  info.isBind openid, (err, openidIns) ->
    if err
      err.openid = openid
      return errorHandler(err)
    
    if openidIns
      info.getProfileByStuid openidIns.stuid, (err, student) ->
        if err
          err.openid = openid
          return errorHandler(err)
        if student
          name = student.name + '同学'
          desc = usage({somebody: name})
        else
          desc = usage({somebody: '亲爱的农大校友'})
        result.push(new ImageText(desc, '', bindUrl))
        return wechatApi.sendNews(openid, result, errorHandler)
    else
      result = [new ImageText('                    东农助手', '', bindUrl)]
      desc = usage({somebody: '亲爱的农大校友'})
      result.push(new ImageText(desc, '', bindUrl))
      bindInfo = "部分功能需要绑定学号后使用\n点我去绑定"
      result.push(new ImageText(bindInfo, '', bindUrl))
      return wechatApi.sendNews(openid, result, errorHandler)

getAllSyllabus =(openid) ->
  info.getProfileByOpenid openid, (err, student) ->
    if err
      if err.message is 'openid not found'
        return wechatApi.sendText(openid, "查询课表需先绑定账户\n   请回复'绑定'", errorHandler)
      else
        err.openid = openid
        return errorHandler(err)

    if !student || !student.pswd || student.is_pswd_invalid == true
      msg = """
            你未绑定学号或更改了教务系统密码
            请回复'绑定'重新认证身份信息
            """
      return wechatApi.sendText(openid, msg, errorHandler)

    info.getAllSyllabus student.stuid, (err, ins) ->
      if err
        err.openid = openid
        return errorHandler(err)
      if !ins
        info.updateUserData(student.stuid)
        msg = '正在获取你的信息，如果多次查询无结果，请回复"绑定"重新认证身份信息'
        return wechatApi.sendText(openid, msg, errorHandler)
      syllabuses = []
      ['1', '2', '3', '4', '5', '6'].forEach (item) ->
        syllabuses.push syllabusFormatByDay ins[item], item
      interval = 500
      startTime = -500
      syllabuses.forEach (item) ->
        startTime = startTime + interval
        setTimeout(() ->
          wechatApi.sendNews openid, item, errorHandler
        , startTime)

syllabusFormatByDay = (syllabus, day) ->
  weedDayName = switch
    when day is '1' then "星期一"
    when day is '2' then "星期二"
    when day is '3' then "星期三"
    when day is '4' then "星期四"
    when day is '5' then "星期五"
    when day is '6' then "星期六"
    when day is '7' then "星期日"
  result = [new ImageText("                    #{weedDayName}")]
  if syllabus['1']
    str = """
        第一节：#{syllabus['1'].name}
        教室： #{syllabus['1'].room}，    任课教师： #{syllabus['1'].teacher}
        上课周次：  #{syllabus['1'].week}
        """
    result.push(new ImageText(str))
  if syllabus['2']
    str = """
        第二节：#{syllabus['2'].name}
        教室： #{syllabus['2'].room}，    任课教师： #{syllabus['2'].teacher}
        上课周次：  #{syllabus['2'].week}
        """
    result.push(new ImageText(str))
  if syllabus['3']
    str = """
        第三节：#{syllabus['3'].name}
        教室： #{syllabus['3'].room}，    任课教师： #{syllabus['3'].teacher}
        上课周次：  #{syllabus['3'].week}
        """
    result.push(new ImageText(str))
  if syllabus['4']
    str = """
        第四节：#{syllabus['4'].name}
        教室： #{syllabus['4'].room}，    任课教师： #{syllabus['4'].teacher}
        上课周次：  #{syllabus['4'].week}
        """
    result.push(new ImageText(str))
  if syllabus['5']
    str = """
        第五节：#{syllabus['5'].name}
        教室： #{syllabus['5'].room}，    任课教师： #{syllabus['5'].teacher}
        上课周次：  #{syllabus['5'].week}
        """
    result.push(new ImageText(str))
  if syllabus['6']
    str = """
        第六节：#{syllabus['6'].name}
        教室： #{syllabus['6'].room}，    任课教师： #{syllabus['6'].teacher}
        上课周次：  #{syllabus['6'].week}
        """
    result.push(new ImageText(str))
  if result.length is 1
    result.push(new ImageText("今天没课！"))
  result.push(new ImageText("                  本周为第#{moment().week() - 36}周"))
  return result

getSyllabusByDay = (req, res, day) ->
  msg = req.weixin
  info.getProfileByOpenid msg.FromUserName, (err, student) ->
    if err
      if err.message is 'openid not found'
        return res.reply "查询课表需先绑定账户\n   请回复'绑定'"
      else
        err.openid = msg.FromUserName
        return errorHandler(err)

    if day == 7
      return res.reply '星期天休息，亲'
    day = day + ''
    if !student || !student.pswd || student.is_pswd_invalid == true
      return res.reply """
                你未绑定学号或更改了教务系统密码
                请回复'绑定'重新认证身份信息
                """

    info.getSyllabus student.stuid, day, (err, ins) ->
      if err
        err.openid = msg.FromUserName
        return errorHandler(err)
      if !ins or !ins[day]
        info.updateUserData(student.stuid)
        return res.reply('正在获取你的信息，如果多次查询无结果，请回复"绑定"重新认证身份信息')

      result = syllabusFormatByDay ins[day], day
      return res.reply(result)

getNowGrade = (req, res) ->
  msg = req.weixin
  info.getProfileByOpenid msg.FromUserName, (err, student) ->
    if err
      if err.message is 'openid not found'
        return res.reply "查询成绩需先绑定账户\n   请回复'绑定'"
      else
        err.openid = msg.FromUserName
        return errorHandler(err)
    if student && student.pswd && student.is_pswd_invalid != true
      info.getQbGrade student.stuid, (err, grade) ->
        if err
          err.openid = openid
          return errorHandler(err)

        if !grade
          info.updateUserData(student.stuid)
          return res.reply('正在获取你的信息\n     请稍候再试')
        result = grade['qb']['2013-2014学年春(两学期)']
        if !result || result.length is 0
          return res.reply('暂时还没有上学期成绩信息')
        gradeStr = ["姓名：#{student.name}\n"]
        gradeStr.push("学号；#{student.stuid}\n")
        for item in result
          gradeStr.push("#{item.kcm}\n")
          gradeStr.push("成绩：#{item.cj}\n")
          gradeStr.push("------------------\n")
        gradeStr.push("仅显示及格科目成绩！")
        info.updateUserData(student.stuid)
        return res.reply(gradeStr.join(''))
    else
      return res.reply """
                你未绑定学号或更改了教务系统密码
                请回复'绑定'重新认证身份信息
                """

getBjgGrade = (req, res) ->
  msg = req.weixin
  info.getProfileByOpenid msg.FromUserName, (err, student) ->
    if err
      if err.message is 'openid not found'
        return res.reply "查询成绩需先绑定账户\n   请回复'绑定'"
      else
        err.openid = msg.FromUserName
        return errorHandler(err)

    if student && student.pswd && student.is_pswd_invalid != true
      info.getAllGrade student.stuid, (err, grade) ->
        if err
          err.openid = msg.FromUserName
          return errorHandler(err)
        if !grade
          info.updateUserData(student.stuid)
          return res.reply('正在获取你的信息\n     请稍候再试')
        result = _.values(grade['fa'])[0]
        if !result || result.length is 0
          return res.reply('没找到不及格成绩信息')
        gradeStr = ["姓名：#{student.name}\n"]
        gradeStr.push("学号；#{student.stuid}\n")
        for item in result
          if Number(item.cj) < 60 || item.cj is "不及格"
            gradeStr.push("#{item.kcm}\n")
            gradeStr.push("学分：#{item.xf}\n")
            gradeStr.push("成绩：#{item.cj}\n")
            gradeStr.push("------------------\n")
        info.updateUserData(student.stuid)
        return res.reply(gradeStr.join(''))
    else
      return res.reply """
                你未绑定学号或更改了教务系统密码
                请回复'绑定'重新认证身份信息
                """

_replyExamInfo = (msgs, res) ->
  if msgs.length is 0
    return res.reply '暂无考试信息'
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
    return res.reply examInfo.join('')
  else
    result = []
    result.push(new ImageText('                补考查询'))
    nameAndStuidStr = '  姓名:' + msgs[0].stuName + '\n' + '  学号:' + msgs[0].stuid
    result.push(new ImageText(nameAndStuidStr))
    for msg in msgs
      examStr = "#{msg.courseName}\n" + "时间:#{msg.time}\n" + "地点:    #{msg.location}"
      result.push(new ImageText(examStr))
    return res.reply result

module.exports = wechat "feit", handler
