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
  title = "#{value * count}元校园网充值卡"
  picUrl = 'http://s.feit.me/card.jpg'

  msg =
    title: title
    description: "面值：#{value * count}\n编号：#{num}\n感谢购买，此卡仅对付款微信号有效，请尽快点击使用！"
    url: url
    picurl: picUrl
  wechatApi.sendNews openid, [msg], (err, result) ->
    res.json err or result
