_ = require 'lodash'
cheerio = require 'cheerio'
copy = require 'copy-to'
Then = require 'thenjs'
request = require '../lib/request'
logger = require 'winston'
JwcRequest = request.JwcRequest

studentDao = require('../models').Student

class Student
  constructor: (@stuid, @pswd, ticket) ->
    if stuid and pswd and ticket
      @jwcRequest = new JwcRequest(ticket)

  login: (callback) ->
    self = this
    if not @pswd
      callback new Error('pswd not set')
    request.loginRequest @stuid, @pswd, (err, data, res) ->
      if err then return callback err
      if res.statusCode isnt 200
        return callback new Error('request error status code is ' + statusCode)
      if data.errcode isnt 0
        return callback new Error 'auth failed', data
      self.jwcRequest = new JwcRequest(data.ticket)
      callback null, data

  profileKeys: ["stuid", "name", "xmpy", "ywxm", "cym", "id_card", "sex", "sslb", "tsxslx", "xjzt", "sflb",
    "native", "jg", "csrq", "zzmm", "kq", "byzx", "gkzf", "lqh", "gkksh", "rxksyz", "txdz", "yb",
    "jzxx", "rxrq", "xs", "major", "zyfx", "year", "class", "sfyxj", "sfygjxj", "xq", "ydf", "wyyz",
    "ssdz", "yxsj", "pycc", "pyfs", "flfx", "sflx", "bz", "bz1", "bz2", "bz3"]

  getProfileByTicket: (callback) ->
    self = this
    if not @jwcRequest
      return callback new Error 'please instance this class with ticket or use login before this'

    Then (cont) ->
      
      self.jwcRequest.get JwcRequest::PROFILE, cont

    .then (cont, profileHtml) ->
      $ = cheerio.load(profileHtml)
      values = []
      $("#tblView [width=275]").each (i, e) ->
        values.push(cheerio(e).text().trim())

      profile = _.zipObject Student::profileKeys, values
      student = pswd: self.pswd
      copy(profile).pick('stuid', 'name', 'sex', 'native', 'class', 'major', 'year', 'id_card').to(student)

      studentDao.create student, cont

    .then (cont, student) ->
      logger.debug student
      callback null, student

    .fail callback

module.exports = Student
