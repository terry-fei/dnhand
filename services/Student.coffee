_ = require 'lodash'
cheerio = require 'cheerio'
copy = require 'copy-to'
Then = require 'thenjs'
logger = require 'winston'
{JwcRequest, loginRequest} = require '../lib/request'

syllabusService = require './Syllabus'
gradeService = require './Grade'

studentDao = require('../models').Student

class Student
  constructor: (@stuid, @pswd, ticket) ->
    if stuid and pswd and ticket
      @jwcRequest = new JwcRequest(ticket)

  login: (callback) =>
    if not @pswd
      callback new Error('pswd not set')
    loginRequest @stuid, @pswd, (err, data, res) =>
      if err then return callback err
      if res.statusCode isnt 200
        return callback new Error('request error status code is ' + statusCode)
      if data.errcode isnt 0
        return callback new Error 'auth failed', data
      @jwcRequest = new JwcRequest(data.ticket)
      callback null, data

  @profileKeys: ["stuid", "name", "xmpy", "ywxm", "cym", "id_card", "sex", "sslb", "tsxslx", "xjzt", "sflb",
    "native", "jg", "csrq", "zzmm", "kq", "byzx", "gkzf", "lqh", "gkksh", "rxksyz", "txdz", "yb",
    "jzxx", "rxrq", "xs", "major", "zyfx", "year", "class", "sfyxj", "sfygjxj", "xq", "ydf", "wyyz",
    "ssdz", "yxsj", "pycc", "pyfs", "flfx", "sflx", "bz", "bz1", "bz2", "bz3"]

  getProfileByTicket: (callback) =>
    if not @jwcRequest
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
      copy(profile).pick('stuid', 'name', 'sex', 'native', 'class', 'major', 'year', 'id_card').to(student)

      callback null, student

    .fail callback

  updateStudent: (student, callback) =>
    studentDao.findOneAndUpdate {stuid: student.stuid}, student, {upsert: true}, callback

  getSyllabusByTicket: (callback) =>
    syllabus = new syllabusService @stuid, @jwcRequest
    syllabus.getSyllabusByTicket callback

  getGradeByTicket: (type, callback) ->
    grade = new gradeService @stuid, @jwcRequest
    grade.getGradeByTicket type, callback

module.exports = Student
