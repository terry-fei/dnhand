wechat  = require "wechat"
request = require "request"
Student = require '../models/Student'
OpenId  = require '../models/OpenId'
iconv = require 'iconv-lite'
cheerio = require 'cheerio'
_ = require 'underscore'
moment = require 'moment'
moment.locale("zh-cn")

info = require './info'

class ImageText
  constructor: (title, description, url, picurl) ->
    @title = title
    @description = description
    @url = url
    @picurl = picurl

handler = (req, res) ->
  msg = req.weixin
  ct = msg.Content ? msg.EventKey
  if msg.Event is "subscribe" or !ct
    return replyNoMatchMsg req, res

  else if req.wxsession.status
    dealWithStatus(req, res)

  else if ct is "allgrade"
    info.getProfileByOpenid msg.FromUserName, (err, student) ->
      if err
        if err.message is 'openid not found'
          return res.reply "查询成绩需先绑定账户\n   请回复'绑定'"
        else
          return res.reply "请稍候再试"

      desc = """
            #{student.name}同学

            请点击查看你的成绩单
            """
      url = "http://n.feit.me/info/allgrade/#{msg.FromUserName}"
      imageTextItem = new ImageText("#{student.name}同学的全部成绩", desc, url)
      return res.reply([imageTextItem])

  else if ct is "nowgrade"
    getNowGrade(req, res)

  else if ct is "bjggrade"
    getBjgGrade(req, res)

  else if ct is "hi"
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

  else if ct is "剩余时长" or ct is "sysc"
    needBindStuid msg.FromUserName, res, (student) ->
      if !student.rjpswd
        return res.reply("你还没有绑定锐捷客户端，请回复“net”进行绑定")

      info.getRjInfo student.stuid, student.rjpswd, (err, result) ->
        if err or !result
          return res.reply "请稍后再试"
        if result.errcode is 2
          return res.reply "身份过期，请回复“锐捷”重新认证"
        if result.errcode is 0
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

  else if ct is "自助暂停"
    return res.reply "目前不能办理自助暂停业务"

  else if ct is "自助恢复"
    return res.reply "目前不能办理自助恢复业务"

  else if ct is "充值网票"
    needBindStuid msg.FromUserName, res, (student) ->
      if !student.rjpswd
        return res.reply("你还没有绑定锐捷客户端，请回复“net”进行绑定")
      title = "充值网票"
      desc = "请点击本消息去充值\n充值中遇到的任何问题请手机与我取得联系\n联系电话：13199561979"
      url = "http://neaucode.sinaapp.com/netcard?id=#{msg.FromUserName}"
      imageTextItem = new ImageText(title, desc, url)
      return res.reply([imageTextItem])

  else if ct is "更改套餐"
    needBindStuid msg.FromUserName, res, (student) ->
      if !student.rjpswd
        return res.reply("你还没有绑定锐捷客户端，请回复“net”进行绑定")

      info.getRjInfo student.stuid, student.rjpswd, (err, result) ->
        if err or !result
          return res.reply "请稍后再试"
        if result.errcode is 2
          return res.reply "身份过期，请回复“锐捷”重新认证"
        if result.errcode is 0
          fee = result.currentAccountFeeValue
          #if fee is '0.00'
            #return res.reply('你当前账户余额为0，不能更改套餐')
          req.wxsession.status = 'changePolicy'
          req.wxsession.netCardStep = 'replyPolicy'
          req.wxsession.stuid = student.stuid
          req.wxsession.rjpswd = student.rjpswd
          return res.reply """
            当前账户余额#{fee}
            请回复相应的套餐序号
            【1】20元包30小时
            【2】30元包60小时
            【3】50元包150小时
          """

  else if ct is "net" or ct is "ruijie" or ct is "锐捷" or ct is "rj"
    needBindStuid msg.FromUserName, res, (student) ->
      if !student.rjpswd
        title = "锐捷相关服务"
        desc = "请点击本消息绑定锐捷客户端，绑定后可以使用查询剩余时长，充值网票等功能"
        url = "http://n.feit.me/rj/bind/#{student.stuid}/#{msg.FromUserName}"
        logoUrl = "http://n.feit.me/assets/dnhandlogo.jpg"
        imageTextItem = new ImageText(title, desc, url, logoUrl)
        return res.reply([imageTextItem])
      title = "锐捷相关服务"
      desc = """
            请回复以下关键字
            【剩余时长】
            【充值网票】【更改套餐】
            【自助暂停】【自助恢复】
            充值网票和更改套餐功能正在测试中，近两天开放！
            """
      url = "http://n.feit.me/rj/bind/#{student.stuid}/#{msg.FromUserName}"
      imageTextItem = new ImageText(title, desc, url)
      return res.reply([imageTextItem])

  else if ct is "fankui"
    title = "东农助手"
    desc = """
          有问题可以加我微信，回复'hi'，查看我的微信号
          回复“绑定”可以更换绑定的学号
          """
    url = "weixin://contacts/profile/q13027722"
    imageTextItem = new ImageText(title, desc, url)
    return res.reply([imageTextItem])

  else if ct is "todaysyllabus"
    day = moment().day()
    if day is 0
      day = 7
    getSyllabus(req, res, day)

  else if ct is "tomorrowsyllabus"
    day = moment().day() + 1
    getSyllabus(req, res, day)

  else if ct.substring(0, 2) is "补考"
    stuid = ct.substring(2)
    if stuid.substring(0, 1) is "A" and stuid.length is 9
      info.getExamInfo stuid, (err, msgs) ->
        if err
          return res.reply '请稍候再试'
        _replyExamInfo(msgs, res)
    else 
      return res.reply '学号格式不正确'

  else if ct is "exam"
    return res.reply "请回复 '补考'+'学号' 查询补考信息\n例如查询学号为A19120000的补考信息\n'补考A19120000'"
    
  else if ct is "cet"
    req.wxsession.status = "cet"
    req.wxsession.cetStep = 'replyCetNum'
    return res.reply '请回复你的准考证号，农大的同学如果忘记了准考证号可以先回复“取消”，再回复你的身份证号码查询'

  else if ct is "排名"
    info.getProfileByOpenid msg.FromUserName, (err, student) ->
      if err
        if err.message is 'openid not found'
          return res.reply "查询排名需先绑定账户\n   请回复'绑定'"
        else
          return res.reply "请稍候再试"
      info.getRank student.stuid, (err, grade) ->
        if err or !grade
          return res.reply "请稍候再试"
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

  else if ct.length is 18
    info.getCetNumByIdcard ct, (err, result) ->
      if err
        if err.message == 'nothing'
          return res.reply '没有找到准考证信息'
        return res.reply '网络错误，请稍候再试'
      title = "#{result.type}级准考证"
      description = "请点击查看你的#{result.type}级准考证"
      return res.reply([new ImageText(title, description, result.url)])

  else if ct is '绑定'
    title = "东农助手"
    desc = """
          请点击本消息绑定学号
          """
    url = "http://n.feit.me/bind/#{msg.FromUserName}"
    logoUrl = "http://n.feit.me/assets/dnhandlogo.jpg"
    imageTextItem = new ImageText(title, desc, url, logoUrl)
    return res.reply([imageTextItem])
  else
    return replyNoMatchMsg req, res

dealWithStatus = (req, res) ->
  status = req.wxsession.status
  weixin = req.weixin
  if weixin.Content is "取消" or weixin.Content is "退出"
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
          return res.reply '发生错误，请稍候再试'

        if grade and grade.name == name
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

  else if status is 'changePolicy'
    step = req.wxsession.netCardStep
    if step is 'replyPolicy'
      stuid = req.wxsession.stuid
      rjpswd = req.wxsession.rjpswd
      if weixin.Content is '1'
        delete req.wxsession.status
        info.rjChangePolicy stuid, rjpswd, '20', (err, ress) ->
          if res.errcode is 0
            return res.reply '套餐变更成功，当前为20元包30小时'
          else
            return res.reply '套餐变更失败，请检查账户余额并重试'
      else if weixin.Content is '2'
        delete req.wxsession.status
        info.rjChangePolicy stuid, rjpswd, '30', (err, ress) ->
          if res.errcode is 0
            return res.reply '套餐变更成功，当前为30元包60小时'
          else
            return res.reply '套餐变更失败，请检查账户余额并重试'
      else if weixin.Content is '3'
        delete req.wxsession.status
        info.rjChangePolicy stuid, rjpswd, '5', (err, ress) ->
          if res.errcode is 0
            return res.reply '套餐变更成功，当前为50元包150小时'
          else
            return res.reply '套餐变更失败，请检查账户余额并重试'
      else
        return res.reply '请回复正确的套餐编号'

  else
    delete req.wxsession.status
    return res.reply "未知状态，已返回正常模式."

needBindStuid = (openid, res, callback) ->
  info.getProfileByOpenid openid, (err, student) ->
    if err or !student
      if err and err.message is 'openid not found'
        return res.reply "使用此功能需先绑定账户\n   请回复'绑定'"
      else
        return res.reply "请稍候再试"
    callback(student)

replyNoMatchMsg = (req, res) ->
  msg = req.weixin
  logoUrl = "http://n.feit.me/assets/dnhandlogo.jpg"
  bindUrl = "http://n.feit.me/bind/#{msg.FromUserName}"
  info.isBind req.weixin.FromUserName, (err, openid) ->
    if err
      return res.reply '请稍候再试'
    if openid
      info.getProfileByStuid openid.stuid, (err, student) ->
        result = [new ImageText('                    东农助手', '', bindUrl)]
        desc = """
          Hi，   #{student.name || ""}同学
          基本功能在下方的按钮中
          除此之外 回复以下关键字
          【net】充值网票和剩余时长
          【cet】查询四六级成绩
          【绑定】更换绑定的学号
          【排名】查看智育成绩排名
          【你的身份证号】四六级准考证
          
          部分功能正在建设中
          本助手每周更新
          欢迎告知你身边还没有关注的同学
          """
        result.push(new ImageText(desc, '', bindUrl))
        return res.reply(result)
    else
      result = [new ImageText('                    东农助手', '', bindUrl)]
      desc = """
        Hi，  亲爱的农大校友
        基本功能在下方的按钮中
        除此之外 回复以下关键字
        【cet】查询四六级成绩
        【绑定】更换绑定的学号
        【排名】查看你上次考试智育成绩排名
        【你的身份证号】查询四六级准考证信息
        
        部分功能正在建设中
        本助手每周更新
        欢迎告知你身边还没有关注的同学
        """
      result.push(new ImageText(desc, '', bindUrl))
      bindInfo = """
        部分功能需要绑定学号后使用
        点我去绑定
        """
      result.push(new ImageText(bindInfo, '', bindUrl))
      return res.reply(result)

getSyllabus = (req, res, day) ->
  msg = req.weixin
  if day == 7
    return res.reply '星期天休息，亲'
  day = day + ''
  info.getProfileByOpenid msg.FromUserName, (err, student) ->
    if err
      if err.message is 'openid not found'
        return res.reply "查询课表需先绑定账户\n   请回复'绑定'"
      else
        return res.reply "请稍候再试"
    if student && student.pswd && student.is_pswd_invalid != true
      info.getSyllabus student.stuid, day, (err, ins) ->
        if err
          return res.reply('请稍候再试')
        if !ins or !ins[day]
          info.updateUserData(student.stuid)
          return res.reply('正在获取你的信息，如果多次查询无结果，请回复"绑定"重新认证身份信息')
        syllabus = ins[day]
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
        result.push(new ImageText("                  本周为第#{moment().week() - 35}周"))
        return res.reply(result)
    else
      return res.reply """
                你未绑定学号或更改了教务系统密码
                请回复'绑定'重新认证身份信息
                """

getNowGrade = (req, res) ->
  msg = req.weixin
  info.getProfileByOpenid msg.FromUserName, (err, student) ->
    if err
      if err.message is 'openid not found'
        return res.reply "查询成绩需先绑定账户\n   请回复'绑定'"
      else
        return res.reply "请稍候再试"
    if student && student.pswd && student.is_pswd_invalid != true
      info.getQbGrade student.stuid, (err, grade) ->
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
        return res.reply "请稍候再试"
    if student && student.pswd && student.is_pswd_invalid != true
      info.getAllGrade student.stuid, (err, grade) ->
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
