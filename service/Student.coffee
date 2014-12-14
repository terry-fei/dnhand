_ = require 'lodash'
cheerio = require 'cheerio'
copy = require 'copy-to'
Then = require 'thenjs'
logger = require 'winston'
{JwcRequest, loginRequest} = require '../lib/request'

syllabusService = require './Syllabus'
gradeService = require './Grade'

studentDao = require('../models').Student

logger = console

class Student
  constructor: (@stuid, @pswd, ticket) ->
    if stuid and pswd and ticket
      @jwcRequest = new JwcRequest(ticket)

  login: (callback) =>
    unless @pswd
      callback new Error('pswd not set')

    loginRequest @stuid, @pswd, (err, data, res) =>
      return callback err if err


      unless res.statusCode is 200
        return callback new Error('request error status code is ' + statusCode)

      unless data.errcode is 0
        if data.errcode is 2 and @hasBind
          @markPswdInvalid()

        err = new Error 'auth failed'
        err.name = 'loginerror'
        copy(data).pick('errcode', 'errmsg').to(err)
        return callback err

      @jwcRequest = new JwcRequest(data.ticket)
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
    studentDao.findOneAndUpdate {stuid: @stuid}, {is_pswd_invalid: true}, () ->

  @get: (stuid, field, callback) ->
    studentDao.findOne {stuid: stuid}, field, callback

  getSyllabusByTicket: (callback) =>
    syllabus = new syllabusService @stuid, @jwcRequest
    syllabus.getSyllabusByTicket callback

  getGradeByTicket: (type, callback) ->
    grade = new gradeService @stuid, @jwcRequest
    grade.getGradeByTicket type, callback

  @updateStudent: (student, callback) =>
    studentDao.findOneAndUpdate {stuid: student.stuid}, student, {upsert: true}, callback

  @updateSyllabus: (syllabus, callback) =>
    syllabusService.updateSyllabus syllabus, callback

  @updateGrade: (grade, callback) =>
    gradeService.updateGrade grade, callback

  getInfoAndSave: (callback) =>
    Then (cont) =>
      @getStudentAndSave cont

    .then (cont, profile) =>
      @getSyllabusAndSave cont

    .then (cont, syllabus) =>
      @getGradeAndSave 'fa', cont

    .then (cont, grade) =>
      @getGradeAndSave 'qb', cont

    .then (cont, grade) =>
      @getGradeAndSave 'bjg', cont

    .then (cont, grade) =>
      callback()

    .fail (cont, err) ->
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
