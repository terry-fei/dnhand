iconv   = require "iconv-lite"
request = require "request"
cheerio = require "cheerio"
async   = require "async"
util    = require "util"
_       = require "underscore"
fs      = require 'fs'

afacjKeys   = ["kch", "kxh", "kcm", "ywkcm", "xf", "cksx", "cj", "wtgyy"]
akcsxcjKeys = ["kch", "kxh", "kcm", "ywkcm", "xf", "cksx", "cj", "wtgyy"]
qbjgcjKeys  = ["kch", "kxh", "kcm", "ywkcm", "xf", "cksx", "cj"]
bxqcjKeys   = ["kch", "kxh", "kcm", "ywkcm", "xf", "cksx", "kczgf", "kczdf", "kxpjf", "cj", "mc", "wtgyy"]

bjgcjGroupNames = ["尚不及格", "曾不及格"]
bjgcjKeys       = ["kch", "kxh", "kcm", "ywkcm", "xf", "cksx", "cj", "kssj", "wtgyy"]

profileKeys = ["xh", "xm", "xmpy", "ywxm", "cym", "sfzh", "xb", "sslb", "tsxslx", "xjzt", "sflb",
   "mz", "jg", "csrq", "zzmm", "kq", "byzx", "gkzf", "lqh", "gkksh", "rxksyz", "txdz", "yb",
   "jzxx", "rxrq", "xs", "zy", "zyfx", "nj", "bj", "sfyxj", "sfygjxj", "xq", "ydf", "wyyz",
   "ssdz", "yxsj", "pycc", "pyfs", "flfx", "sflx", "bz", "bz1", "bz2", "bz3"]

syllabusItemKeys    = ["pyfa", "kch", "kcm", "kxh", "xf", "kcsx", "kslx", "js", "dgrl", "xdfs", "xkzt", "msg"]
syllabusItemSubKeys = ["zc", "xq", "jc", "jieshu", "xiaoqu", "jsl", "js"]

netInfo = {
  checkAccount: (stuid, pswd, callback) ->
    if !stuid or stuid.length != 9 or !pswd
      return callback(new Error('parameter error'))

    url = "http://neaucode.sinaapp.com/auth?stuid=#{stuid}&pswd=#{pswd}"
    request {uri: url, json: true}, (err, res, body) ->
      callback(err, body)

  getRjInfo: (stuid, pswd, callback) ->
    if !stuid or stuid.length != 9 or !pswd
      return callback(new Error('parameter error'))

    url = "http://neaucode.sinaapp.com/rj/login?stuid=#{stuid}&pswd=#{pswd}"
    request {uri: url, json: true}, (err, res, body) ->
      callback(err, body)

  rjChargeSelf: (stuid, pswd, cardNo, secret, callback) ->
    postData = {
      stuid: stuid,
      pswd: pswd,
      cardno: cardNo,
      secret: secret
    }
    options = {
      uri: "http://neaucode.sinaapp.com/rj/chargeself",
      method: 'POST',
      json: true,
      form: postData
    }
    request options, (err, res, body) ->
      callback(err, body)

  checkTicket: (ticket, callback) ->
    url = 'http://202.118.167.86/userInfo.jsp'
    getPageFromSchoolServer ticket, url, (err, ret) ->
      if err then callback false else callback true

  getExamInfo: (stuid, callback) ->
    params = keyword: stuid
    request.post({uri: 'http://202.118.167.91/bm/ksap1/all.asp', encoding: null}, (err, rres, body) ->
      if !err and rres.statusCode == 200
        examResult = iconv.decode(body, 'GBK')
        msgs = parseBuKaoHtml examResult
        callback null, msgs
      else
        callback new Error('school server error')
    ).form(params)

  getCetNumByIdcard: (idcard, callback) ->
    cet4url = "http://202.118.167.91/bm/cetzkz/images/w4/#{idcard}.jpg"
    cet6url = "http://202.118.167.91/bm/cetzkz/images/w6/#{idcard}.jpg"
    request.get cet4url, (err, res) ->
      if err
        return callback(new Error("get cet number error"))
      if res && res.statusCode == 200
        callback(null, {type: '四', url: cet4url})
      else
        request.get cet6url, (err, res1) ->
          if err
            return callback(new Error("get cet number error"))
          if res1 && res1.statusCode == 200
            callback(null, {type: '六', url: cet6url})
          else
            callback(new Error('nothing'))

  getCetGrade: (cetNum, name, callback) ->
    cetGradeUrl = "http://www.chsi.com.cn/cet/query?zkzh=#{cetNum}&xm=#{encodeURIComponent(name)}"
    options = 
      url: cetGradeUrl
      headers:
        'Referer': 'http://www.chsi.com.cn/cet/'

    request options, (err, res, body) ->
      if err
        return callback(err)
      if res && res.statusCode == 200
        cetGrade = parseCetGradeHtml body
        if cetGrade and cetGrade.name and cetGrade.totle
          callback null, cetGrade
        else
          callback new Error('nothing')
      else
        return callback(new Error('unkonw error'))

  getProfile: (ticket, callback) ->
    getPageFromSchoolServer ticket, "http://202.118.167.86/xjInfoAction.do?oper=xjxx", (err, html) ->
      if err or html.indexOf("学籍查询") == -1
        err = new Error("ticketNowInvailed") if !err
        return callback(err)

      $ = cheerio.load(html)
      values = []
      $("#tblView [width=275]").each (i, e) ->
        values.push($(e).text().trim())

      callback(null, _.object(profileKeys, values))

  getSyllabus: (ticket, callback) ->
    if ticket
      getPageFromSchoolServer ticket, "http://202.118.167.86/xkAction.do?actionType=6", (err, html) ->
        if err or html.indexOf("学生选课结果") == -1
          if !err
            err = new Error("ticketNowInvailed")
          return callback(err)
        syllabus = parseSyllabusHtml(html)
        callback(null, syllabus)
    else
      callback(new Error("nothing"))

  getGrade: (ticket, what, callback) ->
    url
    keys
    groupNames
    if what is "bxq"
      url = "http://202.118.167.86/bxqcjcxAction.do"
      keys = bxqcjKeys

    else if what is "bjg"
      url = "http://202.118.167.86/gradeLnAllAction.do?oper=bjg"
      keys = bjgcjKeys
      groupNames = bjgcjGroupNames

    else if what is "fa"
      url = "http://202.118.167.86/gradeLnAllAction.do?oper=fainfo"
      keys = afacjKeys

    else if what is "qb"
      url = "http://202.118.167.86/gradeLnAllAction.do?oper=qbinfo"
      keys = qbjgcjKeys

    else if what is "kcsx"
      url = "http://202.118.167.86/gradeLnAllAction.do?oper=sxinfo"
      keys = akcsxcjKeys
    else
      return callback(new Error("param what set error"))

    getPageFromSchoolServer ticket, url, (err, html) ->
      return callback(err) if err
      if html.indexOf("课程") == -1
        return callback(new Error("error html"))
      grade = parseGradeHtml(html, keys, groupNames)
      callback(null, grade)
}

parseCetGradeHtml = (cetHtml) ->
  if /无法找到对应的分数/gi.test(cetHtml)
    return null

  tdTagReg = /<td.*?>[\s\S]*?<\/td>/gi
  tdTags = []
  while (tdTag = tdTagReg.exec(cetHtml))
    tdTags.push(tdTag[0].replace(/<td>|<\/td>/g, ''))

  name = tdTags[2];
  schoolName = tdTags[3];
  type = tdTags[4];
  cetNumber = tdTags[5];
  examDate = tdTags[6];
  
  gradeItemsStr = tdTags[7]
  gradeReg = /\d{1,3}/gi
  gradeItems = []
  while (gradeItem = gradeReg.exec(gradeItemsStr)) 
    gradeItems.push(gradeItem[0])
    
  totle = gradeItems[0];
  listening = gradeItems[2];
  read = gradeItems[4];
  write = gradeItems[6];

  grade = {
    name: name,
    schoolName: schoolName,
    type: type,
    cetNumber: cetNumber,
    examDate: examDate,
    totle: totle,
    listening: listening,
    read: read,
    write: write
  }

  grade

parseBuKaoHtml = (examHtml) ->
  msgs    = []
  $       = cheerio.load(examHtml)
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
  msgs

parseGradeHtml = (html, keys, groupNames) ->
  $ = cheerio.load(html)

  if !groupNames
    groupNames = []
    title = $("#tblHead")
    title.each ->
      groupNames.push($(@).text().trim().replace('.', ''))

  ret
  table = $("#user")
  group = []
  table.each ->
    items = []
    cheerio(@).find("tr.odd").each ->
      values = []
      cheerio(@).children("td").each ->
        values.push(cheerio(@).text().trim())
      items.push(_.object(keys, values))
    group.push(items)
  ret = _.object(groupNames, group)
  ret

parseSyllabusHtml = (html) ->
  items = []
  $ = cheerio.load(html)
  $("#user .odd").each ->
    temp = $(@).children("td")
    if temp.length is 18
      item = []
      itemSub = []
      temp.each (index, ele) ->
        if index < 11
          item.push($(@).text().trim())
        else
          itemSub.push($(@).text().trim())
      item.push([])
      itemObj = _.object(syllabusItemKeys, item)
      itemObj.msg.push(_.object(syllabusItemSubKeys, itemSub))
      items.push(itemObj)
    else
      itemSub = []
      temp.each ->
        itemSub.push($(@).text().trim())
      items[items.length-1].msg.push(_.object(syllabusItemSubKeys, itemSub))

  fillSyllabusItem = (weekDay, num, item, m) ->
    weekDay[num] = {
        name    :item.kcm
        teacher :item.js
        week    :m.zc
        room    :m.js
      }

  filterClassNum = (item, m, weekDay) ->
    if m.jc is "一大"
      fillSyllabusItem(weekDay, 1, item, m)

    else if m.jc is "二大"
      fillSyllabusItem(weekDay, 2, item, m)

    else if m.jc is "三大"
      fillSyllabusItem(weekDay, 3, item, m)

    else if m.jc is "四大"
      fillSyllabusItem(weekDay, 4, item, m)

    else if m.jc is "五大"
      fillSyllabusItem(weekDay, 5, item, m)

    else if m.jc is "六大"
      fillSyllabusItem(weekDay, 6, item, m)

  convertSyllabus = (old) ->
    mon        = {}
    tues       = {}
    wed        = {}
    thur       = {}
    fri        = {}
    sat        = {}
    unassigned = []

    for item in old
      for m in item.msg
        if m.xq is "1"
          filterClassNum(item, m, mon)

        else if m.xq is "2"
          filterClassNum(item, m, tues)

        else if m.xq is "3"
          filterClassNum(item, m, wed)

        else if m.xq is "4"
          filterClassNum(item, m, thur)

        else if m.xq is "5"
          filterClassNum(item, m, fri)

        else if m.xq is "6"
          filterClassNum(item, m, sat)

        else
          unassigned.push {
            name    :item.kcm
            credit  :item.xf
            teacher :item.js
          }

    return {1: mon, 2: tues, 3: wed, 4: thur, 5: fri, 6: sat, unassigned: unassigned}

  return convertSyllabus(items)

getPageFromSchoolServer = (ticket, infoUrl, callback) ->
  if !ticket
    return callback(new Error("ticket not set"))
  cookieJar = request.jar()
  cookieJar.add(request.cookie("JSESSIONID=#{ticket}"))
  request.get {uri: infoUrl, jar: cookieJar, encoding: null, timeout: 4000}, (err, rres, body)->
    if err or rres.statusCode isnt 200
      err = new Error("connectErr") if !err
      return callback(err)
    responseHtml = iconv.decode(body, "GBK")
    return callback(null, responseHtml)

module.exports = netInfo
