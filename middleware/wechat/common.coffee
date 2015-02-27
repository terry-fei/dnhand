Then    = require 'thenjs'

wechatApi = require '../../lib/wechatApi'
OpenIdService   = require '../../services/OpenId'
StudentService = require '../../services/Student'

module.exports =

  replyUsage: (info, res) ->
    openid = info.FromUserName
    user = info.user
    items = [new ImageText('                       使用指北')]
    nickname = user.nickname or '校友'
    subscribeStr = """
        嗨， #{nickname}
      基本功能在下方的按钮中
      除此之外 还有以下指令
      【绑定】  更换绑定的学号
      【期末】  查看期末考试安排
      【补考】  查看补考安排
      【准考证】四六级准考证
      """
    items.push new ImageText(subscribeStr)
    unless user.stuid
      items.push new ImageText('   欢迎关注，点我绑定账户', '', "http://n.feit.me/bind?openid=#{openid}")
    res.reply items

  replyBind: (info, res) ->
    title = "东农助手"
    desc = """
          请点击本消息绑定学号，绑定后可使用查询课表，成绩，考试信息等实用功能
          """
    url = "http://n.feit.me/bind?openid=#{info.FromUserName}"
    logoUrl = "http://n.feit.me/public/dnhandlogo.jpg"
    imageTextItem = new ImageText(title, desc, url, logoUrl)
    res.reply([imageTextItem])

  sendText: (openid, content) ->
    wechatApi.sendText openid, content, wechatApiCallback

  sendNews: (openid, news) ->
    wechatApi.sendNews openid, news, wechatApiCallback

  sendCetGrade: (openid, grade) ->
    templateId = 'aIDqfoquHQ3HGqawH9RY_TuojrMaaSitQKI2m6sqXmk'
    url = ''
    topColor = '#FF0000'
    gradeStr = """
      听力：#{grade.listening}
      阅读：#{grade.read}
      写作翻译：#{grade.write}
      总分：#{grade.totle}
    """
    totleGrade = Number(grade.totle)
    remark = if totleGrade < 425 then '再接再厉！' else "恭喜你通过了#{grade.type}考试！"

    date =
      first:
        value: '全国英语四六级考试成绩单'
        color: '#FF0000'
      keyword1:
        value: grade.name
      keyword2:
        value: grade.schoolName
      keyword3:
        value: grade.cetNumber
      keyword4:
        value: gradeStr
      remark:
        value: remark

    wechatApi.sendTemplate openid, templateId, url, topColor, data, wechatApiCallback

  sendBindSuccessMsg: (openid, stuid) ->
    templateId = 'zPBcYZ708hYfPDCg-bGzZG4g_UyxBxGZe_lbHBVGZ9k'
    url = ''
    topColor = ''
    data =
      first:
        value: '教务账号绑定成功'
        color: '#173177'
      keyword1:
        value: 'dnhand'
        color: '#173177'
      keyword2:
        value: stuid
        color: '#173177'
      keyword3:
        value: '查询课表，成绩，考试等实用功能'
        color: '#173177'
      remark:
        value: '感谢你的关注！'
        color: '#173177'
    wechatApi.sendTemplate openid, templateId, url, topColor, data, wechatApiCallback

  updateUserInfo: (info) ->
    openid = info.FromUserName
    user = info.user

    Then (cont) ->
      StudentService.get user.stuid, null, cont

    .then (cont, studentInfo) ->
      if studentInfo.is_pswd_invalid
        wechatApi.sendText openid, "您的身份信息已过期，请回复'绑定'", wechatApiCallback
        return

      wechatApi.sendText openid, '正在更新信息...', wechatApiCallback
      student = new StudentService(studentInfo.stuid, studentInfo.pswd)
      student.hasBind = true

      user.student = student
      student.login cont

    .then (cont, loginResult) ->
      user.student.getInfoAndSave cont

    .then (cont) ->
      wechatApi.sendText openid, '您的信息更新成功。', wechatApiCallback

    .fail (cont, err) ->
      console.trace err
      wechatApi.sendText openid, "更新失败。\n<a href=\"http://n.feit.me/bind?openid=#{openid}\">点我去网页更新</a>", wechatApiCallback

class ImageText
  constructor: (@title, @description = '', @url = '', @picurl = '') ->

module.exports.ImageText = ImageText

wechatApiCallback = (err, result) ->
  if err
    console.log err
