Then = require 'thenjs'
_ = require 'lodash'
express = require 'express'

{OpenId} = require '../models'
{Student} = require '../models'

log = require '../lib/log'
yzApi = require '../lib/kdt'
wechatApi = require '../lib/wechatApi'
{comMsg} = require '../middleware/wechat'

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
      res.json {errcode: 1, errmsg: 'unbindstuid', openid: openid.openid}
      return

    data.openid = openid.openid
    Student.findOne stuid: openid.stuid, next

  .then (next, student) ->
    unless student and student.rjpswd
      res.json {errcode: 2, errmsg: 'unbindrjid', openid: data.openid}
      return

    user =
      openid: data.openid
      stuid: student.stuid
      pswd: student.rjpswd

    res.json user

  .fail (next, err) ->
    log.error err
    res.json err

router.get '/msg/success', (req, res) ->
  openid = req.query.openid
  stuid = req.query.stuid
  value = req.query.value

  unless openid and stuid and value
    res.json({errcode: 1, errmsg: 'parameter err'})
    return

  templateId = 'N6rDOwzxZSSkf4wCTlke7zARBzoJTEQFX2yua-ZSAwM'
  url = ''
  topColor = '#00FF00'
  data =
    first:
      value: '校园网余额充值成功'
      color: '#173177'
    accountType:
      value: '账号'
      color: '#173177'
    account:
      value: stuid
      color: '#173177'
    amount:
      value: value
      color: '#173177'
    result:
      value: '成功'
      color: '#173177'
    remark:
      value: '感谢你的使用！'
      color: '#173177'
  wechatApi.sendTemplate openid, templateId, url, topColor, data, (err, result) ->
    res.json(result)

# lagecy code
router.post '/msg', (req, res) ->
  openid = req.body.openid
  content = req.body.content
  unless openid and content
    res.json({errcode: 1, errmsg: 'should have openid and content'})
    return
  comMsg.sendText openid, content
  res.json({errcode: 0, errmsg: 'ok'})

router.post '/text', (req, res) ->
  openid = req.body.openid
  content = req.body.content
  unless openid and content
    res.json({errcode: 1, errmsg: 'should have openid and content'})
    return
  wechatApi.sendText openid, content, (err, result) ->
    res.json err or result

router.post '/card', (req, res)->
  openid = req.body.openid
  value = req.body.value
  orderID = req.body.oid
  yzOrderID = req.body.yzoid
  unless openid and value and orderID and yzOrderID
    res.json({errcode: 2, errmsg: 'parameter error'})
    return
  title = "#{value}元校园网充值卡"
  picUrl = switch value
    when '50' then 'http://s.feit.me/card50.jpg'
    when '30' then 'http://s.feit.me/card30.jpg'
    when '20' then 'http://s.feit.me/card20.jpg'
  
  targetUrl = "http://wp.feit.me/ss.html?type=onlineCharge&oid=#{orderID}&yzoid=#{yzOrderID}"
  msg =
    title: title
    description: "面值：#{value}\n编号：#{orderID}\n感谢购买，请尽快点击使用！"
    url: targetUrl
    picurl: picUrl
  wechatApi.sendNews openid, [msg], (err, result) ->
    res.json err or result
