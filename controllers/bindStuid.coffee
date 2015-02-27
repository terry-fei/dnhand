_ = require 'lodash'
Then = require 'thenjs'
express = require 'express'

OpenIdService = require '../services/OpenId'
StudentService = require '../services/Student'
GradeService = require '../services/Grade'
{comMsg} = require '../middleware/wechat'

{oauthApi} = require '../lib/wechatApi'

module.exports = router = express.Router()

router.get '/wx/oauth', (req, res) ->
  code = req.query.code
  state = req.query.state
  oauthApi.getAccessToken code, (err, result) ->
    unless result.data
      return res.end('发生错误请重试')
    openid = result.data.openid
    if state is 'bind'
      res.redirect '/bind?openid=' + openid
    else
      res.end('Not Found')

router.get '/bind', (req, res) ->
  return res.end 'Not Found' unless req.query.openid
  res.render 'bind', {openid: req.query.openid}

router.post '/bind', (req, res) ->
  stuid  = req.body.stuid
  pswd   = req.body.pswd
  openid = req.body.openid

  unless stuid and pswd and openid
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
      console.trace err

    if err.errcode
      res.json err
    else
      res.json errcode: -1, errmsg: 'other'

router.get "/info/allgrade", (req, res, next) ->
  openid = req.query.openid
  Then (cont) ->
    OpenIdService.getUser openid, 'stuid', cont

  .then (cont, user) ->
    unless user.stuid
      return res.redirect '/bind?openid=' + openid

    GradeService.get user.stuid, 'fa', cont

  .then (cont, grade) ->
    unless grade
      return res.redirect '/bind?openid=' + openid

    result = _.values(grade['fa'])[0]
    return res.render 'all_grade', {'items': result}

  .fail (cont, error) ->
    console.trace error
    try
      res.set('Content-Type', 'text/plain; charset=utf-8');
      res.end('请稍候访问')
    catch e
      # ...
