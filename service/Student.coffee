_ = require 'lodash'
cheerio = require 'cheerio'
copy = require 'copy-to'
Then = require 'thenjs'
logger = require 'winston'
{JwcRequest, loginRequest} = require '../lib/request'

SyllabusService = require './HistorySyllabus'
GradeService = require './Grade'

StudentDao = require('../models').Student

logger = console

class Student
  constructor: (@stuid, @pswd, ticket, host) ->
    if stuid and pswd and ticket and host
      @jwcRequest = new JwcRequest(ticket, host)

  login: (callback) =>
    unless @pswd
      callback new Error('pswd not set')

    loginRequest @stuid, @pswd, (err, data) =>
      return callback err if err

      unless data.errcode is 0
        if data.errcode is 2 and @hasBind
          @markPswdInvalid()

        err = new Error 'auth failed'
        err.name = 'loginerror'
        copy(data).pick('errcode', 'errmsg').to(err)
        return callback err

      @jwcRequest = new JwcRequest(data.ticket, data.host)
      callback null, data

  @profileKeys: ["stuid", "name", "xmpy", "ywxm", "cym", "id_card", "sex", "sslb", "tsxslx", "xjzt", "sflb",
    "native", "jg", "csrq", "zzmm", "kq", "byzx", "gkzf", "lqh", "gkksh", "rxksyz", "txdz", "yb",
    "jzxx", "rxrq", "xs", "major", "zyfx", "year", "class", "sfyxj", "sfygjxj", "xq", "ydf", "wyyz",
    "ssdz", "yxsj", "pycc", "pyfs", "flfx", "sflx", "bz", "bz1", "bz2", "bz3"]

  getProfileByTicket: (callback) =>
    unless @jwcRequest
      return callback new Error 'please instance this class with ticket or use login before this'

    Then (cont) =>

      @jwcRequest.get JwcRequest.PROFILE, cont

    .then (cont, profileHtml) =>
      $ = cheerio.load(profileHtml)
      values = []
      $("#tblView [width=275]").each (i, e) ->
        values.push(cheerio(e).text().trim())

      profile = _.zipObject Student.profileKeys, values
      student = pswd: @pswd
      if profile.name and profile.major
        copy(profile).pick('stuid', 'name', 'sex', 'native', 'class', 'major', 'year', 'id_card').to(student)

        callback null, student
      else
        callback new Error 'wrongdata'

    .fail (cont, err) ->
      callback err

  markPswdInvalid: () =>
    StudentDao.findOneAndUpdate {stuid: @stuid}, {is_pswd_invalid: true}, () ->

  @get: (stuid, field, callback) ->
    StudentDao.findOne {stuid: stuid}, field, callback

  getSyllabusByTicket: (callback) =>
    syllabus = new SyllabusService @stuid, @jwcRequest
    syllabus.getSyllabusByTicket callback

  getGradeByTicket: (type, callback) ->
    grade = new GradeService @stuid, @jwcRequest
    grade.getGradeByTicket type, callback

  @updateStudent: (student, callback) =>
    StudentDao.findOneAndUpdate {stuid: student.stuid}, student, {upsert: true}, callback

  @updateSyllabus: (syllabus, callback) =>
    SyllabusService.updateSyllabus syllabus, callback

  @updateGrade: (grade, callback) =>
    GradeService.updateGrade grade, callback

  getInfoAndSave: (callback) =>
    self = this
    Then.parallel [
        (cont) ->
          self.getStudentAndSave cont
        (cont) ->
          self.getSyllabusAndSave (err, syllabus) ->
            if err
              logger.trace err
              return cont()
            cont null, syllabus
            
        (cont) ->
          self.getGradeAndSave 'fa', (err, grade) ->
            if err
              logger.trace err
              return cont()
            cont null, grade
        (cont) ->
          self.getGradeAndSave 'qb', (err, grade) ->
            if err
              logger.trace err
              return cont()
            cont null, grade
        (cont) ->
          self.getGradeAndSave 'bjg', (err, grade) ->
            if err
              return cont()
            cont null, grade
      ]
    .then (cont, result) ->
      callback()
    .fail (cont,err) ->
      callback err

  getStudentAndSave: (callback) =>
    Then (cont) =>
      @getProfileByTicket cont

    .then (cont, profile) =>
      Student.updateStudent profile, callback

    .fail (cont, err) ->
      callback err

  getSyllabusAndSave: (callback) =>
    Then (cont) =>
      @getSyllabusByTicket cont

    .then (cont, syllabus) =>
      Student.updateSyllabus syllabus, callback

    .fail (cont, err) ->
      callback err

  getGradeAndSave: (type, callback) =>
    Then (cont) =>
      @getGradeByTicket type, cont

    .then (cont, grade) =>
      gradeIns = stuid: @stuid
      gradeIns[type] = grade

      Student.updateGrade gradeIns, callback

    .fail (cont, err) ->
      callback err

module.exports = Student
