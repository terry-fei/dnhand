Then = require 'thenjs'
_ = require 'lodash'
express = require 'express'

{OpenId} = require '../models'
{Student} = require '../models'

log = require '../lib/log'
yzApi = require '../lib/kdt'

module.exports = router = express.Router()

router.get '/user', (req, res) ->
  youzanId = req.query.id
  unless youzanId
    res.json {errmsg: 'without parameter'}
    return

  youzanId = parseInt(youzanId)

  data = {}
  Then (next) ->
    OpenId.findOne youzanId: youzanId, next

  .then (next, openid) ->
    unless openid
      opts =
        fields: 'weixin_openid'
        user_id: youzanId

      yzApi.get 'kdt.users.weixin.follower.get', opts, (err, result) ->
        if err then return next err

        if result.error_response
          log.error JSON.stringify result
          res.json {errcode: 3, errmsg: 'couldnotfinduserbyid'}
          return

        openid = result.response.user.weixin_openid

        OpenId.findOneAndUpdate {openid: openid}, {youzanId: youzanId}, next

      return

    next null, openid

  .then (next, openid) ->
    unless openid.stuid
      res.json {errcode: 1, errmsg: 'unbindstuid'}
      return

    data.openid = openid.openid
    Student.findOne stuid: openid.stuid, next

  .then (next, student) ->
    unless student and student.rjpswd
      res.json {errcode: 2, errmsg: 'unbindrjid'}
      return

    user =
      openid: data.openid
      stuid: student.stuid
      pswd: student.rjpswd

    res.json user

  .fail (next, err) ->
    log.error err
    res.json err
