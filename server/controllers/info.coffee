netInfo = require './netInfo'
_ = require 'underscore'
async = require 'async'

Student = require("../models").Student
OpenId = require("../models").OpenId
Syllabus = require("../models").Syllabus
Grade = require("../models").Grade

info = {

  isBind: (openid, callback) ->
    OpenId.findOne {'openid': openid}, callback

  checkTicket: netInfo.checkTicket

  getAllGrade: (stuid, callback) ->
    Grade.findOne {'stuid': stuid}, 'fa', callback

  getQbGrade: (stuid, callback) ->
    Grade.findOne {'stuid': stuid}, 'qb', callback

  getNowGrade: (ticket, callback) ->
    netInfo.getGrade ticket, 'bxq', callback

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

  saveProfile: (ticket, stuid, callback) ->
    self = this
    self.getProfileByStuid stuid, (err, student) ->
      if !student || !student.sex || !student.major || student.class
        self.getProfileByTicket ticket, (err, profile) ->
          if profile && profile.xm && profile.xb && profile.zy && profile.bj
            student.name = profile.xm
            student.sex = profile.xb
            student.native = profile.mz
            student.class = profile.bj
            student.major = profile.zy
            student.year = profile.nj
            student.save callback

  saveGrade: (ticket, stuid, callback) ->
    async.parallel [
      (asyncCallback) ->
        netInfo.getGrade ticket, 'fa', asyncCallback
      ,(asyncCallback) ->
        netInfo.getGrade ticket, 'qb', asyncCallback
      ], (err, results) ->
        Grade.findOneAndUpdate {'stuid': stuid}, {$set: {'fa': results[0], 'qb': results[1]}}, {upsert: true}, callback

  saveSyllabus: (ticket, stuid, callback) ->
    netInfo.getSyllabus ticket, (err, syllabus) ->
      if err
        return callback err
      if syllabus
        Syllabus.findOneAndRemove {'stuid': stuid}, (err) ->
          syllabus.stuid = stuid
          new Syllabus(syllabus).save callback
      else
        callback(new Error('school server error'))

  getExamInfo: netInfo.getExamInfo

  updateOpenid: (openid, stuid, callback) ->
    OpenId.findOneAndUpdate {'openid': openid}, {$set: {'stuid': stuid}}, {upsert: true}, callback

  updateStudentPswd: (stuid, pswd, callback) ->
    Student.findOneAndUpdate {'stuid': stuid}, {$set: {'pswd': pswd, 'update_time': new Date()}}, {upsert: true}, callback

  markPswdInvalid: (stuid, callback) ->
    Student.findOneAndUpdate {'stuid': stuid}, {$set: {'is_pswd_invalid': true}}, {upsert: true}, callback

  checkAccount: netInfo.checkAccount

  updateUserData: (student) ->
    self = this
    if (!student.update_time) || (new Date() - student.update_time > 1800000)
      process.nextTick () ->
        self.checkAccount student.stuid, student.pswd, (err, result) ->
          if err or !result
            return
          if result.errcode == 2
            self.markPswdInvalid student.stuid, (err) ->
            return
          if !result.errcode
            self.saveUserData(student.stuid, result.ticket)

  saveUserData: (stuid, ticket) ->
    self = this
    process.nextTick () ->
      self.saveProfile ticket, stuid, (err) ->

      self.saveGrade ticket, stuid, (err) ->

      self.saveSyllabus ticket, stuid, (err) ->

  route: (app) ->
    self = this
    app.get "/bind/:openid", (req, res, next) ->
      res.render 'bind', {'openid': req.params.openid}

    app.post "/bind", (req, res, next) ->
      stuid = req.body.stuid
      pswd = req.body.pswd
      openid = req.body.openid
      self.checkAccount stuid, pswd, (err, result) ->
        if err or !result
          return res.json({errcode: 1})
        if result.errcode
          return res.json(result)
        self.saveUserData(stuid, result.ticket)
        self.updateStudentPswd stuid, pswd, (err, ins) ->
          self.updateOpenid openid, stuid, (err) ->
            return res.json({errcode: 0})

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
              return res.end('正在获取你的信息\n     请稍候访问...')
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

}

module.exports = info