express = require 'express'

wechatApi = require '../lib/wechatApi'

module.exports = router = express.Router()

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
  count = req.body.count
  num = req.body.no
  url = req.body.url
  unless openid and value and count and num and url
    res.json({errcode: 2, errmsg: 'parameter error'})
    return

  templateId = 'N6rDOwzxZSSkf4wCTlke7zARBzoJTEQFX2yua-ZSAwM'
  url = url
  topColor = ''
  data =
    first:
      value: "#{value * count}元校园网充值卡"
      color: '#FF0000'
    accountType:
      value: '卡号'
      color: '#000000'
    account:
      value: "#{num}"
      color: '#173177'
    amount:
      value: "#{value * count}"
      color: '#FF0000'
    result:
      value: '未使用'
      color: '#173177'
    remark:
      value: '感谢购买，此卡仅对付款微信号有效\n\n请尽快点击使用！'
      color: '#173177'
  wechatApi.sendTemplate openid, templateId, url, topColor, data, (err ,result) ->
    res.json err or result
