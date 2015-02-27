express  = require 'express'
validate = require 'parameter'

ruijie = require '../lib/ruijieHelper'

module.exports = router = express.Router()

errorHandle = (err) ->
  console.trace err

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
