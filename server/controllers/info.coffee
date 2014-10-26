netInfo = require './netInfo'
_ = require 'lodash'
async = require 'async'

mysql = require('mysql')
Thenjs = require('thenjs')

errorHandler = require('../errors').errorHandler
wechatApi = require('../utils/wechat')
OAuth = require('wechat').OAuth
oauthApi = new OAuth('wx3ff5c48ba9ac6552', '2715445e17a0640bc4f2a2f884a69124')

Student = require("../models").Student
OpenId = require("../models").OpenId
Syllabus = require("../models").Syllabus
Grade = require("../models").Grade

pool = mysql.createPool({
  connectionLimit: 10,
  host: 'localhost',
  user: 'root',
  password: 'f6788f17',
  database: 'intel_grade'
});

info = {

  isBind: (openid, callback) ->
    OpenId.findOne {'openid': openid}, callback

  checkTicket: netInfo.checkTicket
  
  getCetNumByIdcard: netInfo.getCetNumByIdcard
  
  getCetGrade: netInfo.getCetGrade

  getRjInfo: netInfo.getRjInfo
  rjChargeSelf: netInfo.rjChargeSelf
  rjChangePolicy: netInfo.rjChangePolicy

  getAllGrade: (stuid, callback) ->
    Grade.findOne {'stuid': stuid}, 'fa', callback

  getQbGrade: (stuid, callback) ->
    Grade.findOne {'stuid': stuid}, 'qb', callback

  getNowGrade: (ticket, callback) ->
    netInfo.getGrade ticket, 'bxq', callback

  getSyllabus: (stuid, day, callback) ->
    Syllabus.findOne {'stuid': stuid}, day, callback

  getAllSyllabus: (stuid, callback) ->
    Syllabus.findOne {'stuid': stuid}, callback

  getProfileByTicket: (ticket, callback) ->
    netInfo.getProfile ticket, callback

  getProfileByStuid: (stuid, callback) ->
    Student.findOne {'stuid': stuid}, callback

  getProfileByOpenid: (openid, callback) ->
    self = this
    self.isBind openid, (err, openid) ->
      if err
        return callback err
      if openid
        self.getProfileByStuid openid.stuid, callback
      else
        callback(new Error('openid not found'))

  saveProfile: (ticket, stuid) ->
    self = this
    self.getProfileByStuid stuid, (err, student) ->
      if !student || !student.sex || !student.major || student.class
        self.getProfileByTicket ticket, (err, profile) ->
          if err
              err.name = stuid + '获取个人信息发生错误\n' + err.name
              return errorHandler(err)
          if profile && profile.xm && profile.xb && profile.zy && profile.bj
            student.name = profile.xm
            student.sex = profile.xb
            student.native = profile.mz
            student.class = profile.bj
            student.major = profile.zy
            student.year = profile.nj
            student.save (err, ins) ->
              if err
                err.name = stuid + '存储个人信息发生错误\n' + err.name
                return errorHandler(err)

  saveGrade: (ticket, stuid) ->
    async.parallel [
      (asyncCallback) ->
        netInfo.getGrade ticket, 'fa', asyncCallback
      ,(asyncCallback) ->
        netInfo.getGrade ticket, 'qb', asyncCallback
      ], (err, results) ->
        Grade.findOneAndRemove {'stuid': stuid}, (err) ->
          if err
            err.name = stuid + '获取成绩发生错误\n' + err.name
            return errorHandler(err)
          grade = {
            stuid: stuid,
            fa: results[0],
            qb: results[1]
          }
          gradeIns = new Grade(grade)
          gradeIns.save (err, ins) ->
            if err
              err.name = stuid + '获取成绩发生错误\n' + err.name
              return errorHandler(err)

  saveSyllabus: (ticket, stuid) ->
    netInfo.getSyllabus ticket, (err, syllabus) ->
      if err
        return errorHandler(err)
      if !syllabus
        err = new Error('parse syllabus error')
        return errorHandler(err)

      Syllabus.findOneAndRemove {'stuid': stuid}, (err) ->
        if err
          return errorHandler(err)
        syllabus.stuid = stuid
        new Syllabus(syllabus).save errorHandler

  getExamInfo: netInfo.getExamInfo

  updateOpenid: (openid, stuid, callback) ->
    OpenId.findOneAndUpdate {'openid': openid}, {$set: {'stuid': stuid}}, {upsert: true}, callback

  updateStudentPswd: (stuid, pswd, callback) ->
    Student.findOneAndUpdate {'stuid': stuid}, {$set: {'pswd': pswd, 'update_time': new Date()}}, {upsert: true}, callback

  updateStudentRjPswd: (stuid, pswd, callback) ->
    Student.findOneAndUpdate {'stuid': stuid}, {$set: {'rjpswd': pswd}}, {upsert: true}, callback

  markPswdInvalid: (stuid, callback) ->
    Student.findOneAndUpdate {'stuid': stuid}, {$set: {'is_pswd_invalid': true}}, {upsert: true}, callback

  checkAccount: netInfo.checkAccount

  updateUserData: (student) ->
    self = this
    if (!student.update_time) || (new Date() - student.update_time > 1800000)
      process.nextTick () ->
        self.checkAccount student.stuid, student.pswd, (err, result) ->
          if err
            return errorHandler(err)
          if result and result.errcode == 2
            self.markPswdInvalid student.stuid, (err) ->
            return
          else if !result.errcode
            self.saveUserData(student.stuid, result.ticket)

  saveUserData: (stuid, ticket) ->
    self = this
    process.nextTick () ->
      self.saveProfile ticket, stuid

    process.nextTick () ->
      self.saveGrade ticket, stuid

    process.nextTick () ->
      self.saveSyllabus ticket, stuid

  getRank: (stuid, callback) ->
    student = {}
    Thenjs((cont) ->
      pool.query('SELECT * FROM grade WHERE stuid = ?', [stuid], cont)
    ).
    then((cont, arg) ->
      student = arg[0]
      student.zyGradeV = student.zyGrade + 0.00001
      student['vagueClass'] = student['className'].substring(0, 4) + '__'
      cont()
    ).
    parallel([(cont) ->
      pool.query('SELECT count(className) AS clmcount FROM grade WHERE className=?', [student['className']], cont)
    ,
    (cont) ->
      pool.query('SELECT count(className) AS mjcount FROM grade WHERE className LIKE ?', [student['vagueClass']], cont)
    ,
    (cont) ->
      pool.query('SELECT count(className) AS clmrank FROM grade WHERE className=? AND zyGrade > ?', [student['className'], student['zyGradeV']], cont)
    ,
    (cont) ->
      pool.query('SELECT count(className) AS mjrank FROM grade WHERE className LIKE ? AND zyGrade > ?', [student['vagueClass'], student['zyGradeV']], cont)
    ]).
    then((cont, result) ->
      student['clmcount'] = result[0][0]['clmcount']
      student['mjcount'] = result[1][0]['mjcount']
      student['clmrank'] = result[2][0]['clmrank'] + 1
      student['mjrank'] = result[3][0]['mjrank'] + 1
      callback(null, student)
    ).
    fail((cont, error) ->
      callback(error)
    )

  route: (app) ->
    self = this
    app.get "/bind/:openid", (req, res, next) ->
      res.render 'login_lb', {'openid': req.params.openid}

    app.post "/bind", (req, res, next) ->
      stuid = req.body.stuid
      pswd = req.body.pswd
      openid = req.body.openid
      if !stuid or !pswd or !openid
        return res.json({errcode: 1})
      self.checkAccount stuid, pswd, (err, result) ->
        if err or !result
          return res.json({errcode: 1})
        if result.errcode
          return res.json(result)
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
            value: '查询课表，成绩等'
            color: '#173177'
          remark:
            value: '感谢你的使用！'
            color: '#173177'
        wechatApi.sendTemplate openid, templateId, url, topColor, data, () ->
        self.saveUserData(stuid, result.ticket)
        self.updateStudentPswd stuid, pswd, (err, ins) ->
          self.updateOpenid openid, stuid, (err) ->
            return res.json({errcode: 0})

    app.get "/rj/bind/:stuid/:openid", (req, res, next) ->
      res.render 'login_rj', {'openid': req.params.openid, 'stuid': req.params.stuid}

    app.post "/rj/bind", (req, res, next) ->
      stuid = req.body.stuid
      pswd = req.body.pswd
      openid = req.body.openid
      if !stuid or !pswd or !openid
        return res.json({errcode: 1})
      self.getProfileByOpenid openid, (err, student) ->
        if err
          return res.json({errcode: 4})
        if !student
          return res.json({errcode: 5})
        if student.stuid != stuid
          return res.json({errcode: 6})
        self.getRjInfo stuid, pswd, (err, result) ->
          if err or !result
            return res.json({errcode: 1})
          if result.errcode
            return res.json(result)
          templateId = 'zPBcYZ708hYfPDCg-bGzZG4g_UyxBxGZe_lbHBVGZ9k'
          url = ''
          topColor = ''
          data = 
            first:
              value: '锐捷账号绑定成功'
              color: '#173177'
            keyword1:
              value: 'dnhand'
              color: '#173177'
            keyword2:
              value: stuid
              color: '#173177'
            keyword3:
              value: '查询剩余时长，充值网票，更改套餐等'
              color: '#173177'
            remark:
              value: '感谢你的使用！'
              color: '#173177'
          wechatApi.sendTemplate openid, templateId, url, topColor, data, () ->
          self.updateStudentRjPswd stuid, pswd, (err, ins) ->
            result.errcode = 0
            return res.json(result)

    app.get "/info/profile", (req, res, next) ->
      netInfo.getProfile req.query.ticket, (err, ret)->
        return res.end(err.message) if err
        res.json(ret)

    app.get "/info/syllabus", (req, res, next) ->
      ticket = req.query.ticket
      netInfo.getSyllabus ticket, (err, ret)->
        return res.end(err.message) if err
        res.json(ret)

    app.get "/info/grade", (req, res, next) ->
      netInfo.getGrade req.query.ticket, req.query.query, (err, ret) ->
        return res.end(err.message) if err
        items = _.values(ret)[0]
        res.render 'wx-grade', {'items': items}

    app.get "/info/allgrade/:openid", (req, res, next) ->
      openid = req.params.openid
      self.getProfileByOpenid openid, (err, student) ->
        if err
            return res.render 'notify', {title: "发生错误", content: "请稍候访问"}
        if student && student.pswd && student.is_pswd_invalid != true
          self.getAllGrade student.stuid, (err, grade) ->
            if !grade
              self.updateUserData(student)
              return res.render 'notify', {title: "请稍候", content: "正在获取你的信息\n     请稍候访问..."}
            result = _.values(grade['fa'])[0]
            if !result || result.length is 0
              self.updateUserData(student)
              return res.end('发生错误，请稍候再试')
            self.updateUserData(student)
            return res.render 'wx-grade', {'items': result}
        else
          return res.render 'notify', {title: '账户过期', content: "<a href='http://n.feit.me/bind/#{openid}'>你的账户已失效，请点击本条信息重新绑定"}

    app.get "/info/grade/json", (req, res, next) ->
      netInfo.getGrade req.query.ticket, req.query.query, (err, ret)->
        return res.end(err.message) if err
        res.json {'result': ret}

    app.get "/info/grade/wx/:openid", (req, res, next) ->

    app.get "/info/base/:stuid", (req, res, next) ->
      Student.findOne {stuid: req.params.stuid}, (err, ins) ->
        return res.reply "err" if err
        res.json ins

    app.get '/info/check/:ticket', (req, res) ->
      ticket = req.params.ticket
      netInfo.checkTicket ticket, (result) ->
        if result
          res.send('ticket vailed')
        else
          res.send('ticket expired')

    app.get '/wx/oauth', (req, res) ->
      code = req.query.code
      state = req.query.state
      oauthApi.getAccessToken code, (err, result) ->
        openid = result.data.openid
        if state is 'bind'
          res.redirect '/bind/' + openid

}

module.exports = info
