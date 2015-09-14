_ = require 'lodash'
Then = require 'thenjs'
express = require 'express'
debug = require('debug')('dnhand:ctrl:jwc')

log = require 'winston'
OpenIdService = require '../services/OpenId'
StudentService = require '../services/Student'
GradeService = require '../services/Grade'
{comMsg} = require '../middleware/wechat'
{zyGrade, OpenId} = require '../models'

{oauthApi} = require '../lib/wechatApi'
module.exports = router = express.Router()

router.get '/test', (req, res) ->
  res.end "#{req.protocol}://#{req.hostname}/hello"

router.get '/bind', (req, res) ->
  if req.query.dev is 'yes'
    openid = req.query.openid
    req.session.openid = openid
    res.render 'jwc/bind'
    return

  code = req.query.code
  unless code
    oauthUrl = oauthApi
      .getAuthorizeURL "#{req.protocol}://#{req.hostname}/jwc/bind"
    res.redirect oauthUrl
    return

  oauthApi.getAccessToken code, (err, result) ->
    unless result.data
      return res.end '发生错误请稍候再试'
    openid = result.data.openid
    debug "bind openid: #{openid}"
    req.session.openid = openid
    res.render 'jwc/bind'

router.post '/bind', (req, res) ->
  stuid  = req.body.stuid
  pswd   = req.body.pswd
  openid = req.session.openid

  unless stuid and pswd and openid
    log.debug 'wrong parameter from bind'
    return res.json errcode: -1

  student = new StudentService stuid, pswd

  Then (cont) ->
    student.login cont

  .then (cont, result) ->
    OpenIdService.bindStuid openid, stuid, cont

  .then (cont, openid) ->
    student.getInfoAndSave cont

  .then (cont) ->
    res.json errcode: 0
    process.nextTick ->
      comMsg.sendBindSuccessMsg(openid, stuid)

  .fail (cont, err) ->
    if err.name isnt 'loginerror'
      log.error err

    if err.errcode
      res.json err
    else
      res.json {errcode: -1, errmsg: 'other'}

router.get '/grade/all', (req, res) ->
  code = req.query.code
  unless code
    oauthUrl = oauthApi
      .getAuthorizeURL "#{req.protocol}://#{req.hostname}/jwc/grade/all"
    res.redirect oauthUrl
    return

  oauthApi.getAccessToken code, (err, result) ->
    unless result.data
      return res.end '发生错误请稍候再试'
    openid = result.data.openid
    debug "query all grade: #{openid}"
    OpenIdService.getUser(openid, 'stuid').then (cont, user) ->
      GradeService.get user.stuid, 'qb', (err, grade) ->
        if err or not grade
          res.end '查询失败，请稍后再试'
        result = stuid: user.stuid
        result.qb = grade.qb
        res.render('jwc/grade', result)
    .catch (cont, err) ->
      log.error err

router.get '/rank/my', (req, res) ->
  code = req.query.code
  unless code
    oauthUrl = oauthApi
      .getAuthorizeURL "#{req.protocol}://#{req.hostname}/jwc/rank/my"
    res.redirect oauthUrl
    return

  oauthApi.getAccessToken code, (err, result) ->
    unless result.data
      return res.end '发生错误请稍候再试'
    openid = result.data.openid
    res.redirect '/rank.html?openid=' + openid

router.get '/rank', (req, res) ->
  openid = req.query.openid
  stuid = req.query.stuid

  if stuid
    return returnRank stuid, res

  return res.json {errcode: 2} unless openid
  OpenId.findOne {openid}, (cont, user) ->
    return res.json {errcode: 3} unless user
    returnRank user.stuid, res

returnRank = (stuid, res) ->
  zyGrade.findOne {stuid: stuid}, (err, student) ->
    return res.json errcode: 1 if err

    return res.json {errcode: 4} unless student

    if student.majorRank
      return res.json student

    query =
      majorName: student.majorName
      majorYear: student.majorYear

    zyGrade.count(query).gte('zyGrade', student.zyGrade).exec (err, majorRank) ->
      return res.json errcode: 1 if err

      query.clsNo = student.clsNo
      zyGrade.count(query).gte('zyGrade', student.zyGrade).exec (err, clsRank) ->
        return res.json errcode: 1 if err
        student.majorRank = majorRank
        student.clsRank = clsRank
        student.save ->
        res.json student

router.post '/rank/top', (req, res) ->
  student = req.body

  Then.parallel([
    (next) ->
      query =
        majorName: student.majorName
        majorYear: student.majorYear
      zyGrade.count(query, next)
    (next) ->
      query =
        majorName: student.majorName
        majorYear: student.majorYear
        clsNo: student.clsNo
      zyGrade.count(query, next)
    (next) ->
      query =
        majorName: student.majorName
        majorYear: student.majorYear
      zyGrade.find(query).sort('-zyGrade').limit(10).exec next
    (next) ->
      query =
        majorName: student.majorName
        majorYear: student.majorYear
        clsNo: student.clsNo
      zyGrade.find(query).sort('-zyGrade').limit(10).exec next
  ]).then (next, result) ->
    data =
      majorCount: result[0]
      clsCount: result[1]
      majorTop: result[2]
      clsTop: result[3]
    res.json data
