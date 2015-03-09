Then = require 'thenjs'
express  = require 'express'
validate = require 'parameter'
{oauthApi} = require '../lib/wechatApi'
log = require '../lib/log'

{OpenId} = require '../models'
{Student} = require '../models'

ruijie = require 'ruijie'

module.exports = router = express.Router()

errorHandle = (err) ->
  console.trace err

router.get '/check', (req, res) ->
  code = req.query.code
  unless code
    oauthUrl = oauthApi.getAuthorizeURL 'http://n.feit.me/ruijie/check'
    res.redirect oauthUrl
    return

  Then (next) ->
    oauthApi.getAccessToken code, next

  .then (next, result) ->
    unless result.data
      return res.end '发生错误请稍候再试'
    openid = result.data.openid

    OpenId.findOne openid: openid, next

  .then (next, openid) ->
    unless openid
      res.end '请关注“东农助手”并完成绑定再来充值'
      return

    unless openid.stuid
      res.end '请在“东农助手”内完成绑定操作后，再来充值'
      return

    Student.findOne {stuid: openid.stuid}, next

  .then (next, student) ->
    unless student.rjpswd
      res.end '请在“东农助手”内回复“绑定锐捷”，完成绑定后再来充值'
      return

    res.render 'ruijie/check', student

  .fail (next, error) ->
    log.error error
    res.end '发生错误，请稍候再试'

# 登录入口， 如果有state参数则返回的信息中有用户状态
router.all '/login', (req, res) ->
  query = if req.query.stuid then req.query else req.body

  rule =
    stuid: 'string'
    pswd : 'string'

  validateErrors = validate rule, query

  if validateErrors
    return res.json validateErrors

  ruijie.login query, (err, result) ->
    if err
      errorHandle err
      return res.json {errmsg: 'query error', errcode: 3}

    if result.errcode isnt 0
      return res.json result

    ruijie.currentState result, (err, stateRet) ->
      if err
        errorHandle err
        return res.json {errmsg: 'query error', errcode: 3}

      result.state = stateRet
      res.json result

router.post '/changepolicy', (req, res) ->
  rule =
    stuid : 'string'
    pswd  : 'string'
    cookie: 'string'
    code  : 'string'
    policy: 'string'
    immediately: 'string'

  validateErrors = validate rule, req.body

  if validateErrors
    return res.json validateErrors

  immediately = if req.body.immediately is 'yes' then true else false

  user = req.body

  ruijie.changePolicy user, (err, result) ->
    return errorHandle err if err
    res.json result

router.post '/charge', (req, res) ->
  rule =
    stuid : 'string'
    pswd  : 'string'
    cookie: 'string'
    code  : 'string'
    cardNo: 'string'
    cardSecret: 'string'

  validateErrors = validate rule, req.body

  if validateErrors
    return res.json validateErrors

  user = req.body

  ruijie.charge user, (err, result) ->
    return errorHandle err if err
    res.json result
