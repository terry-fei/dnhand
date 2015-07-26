wechatApi = require('wechat-api')

api = new wechatApi 'wxc49d99a484205dd0', '75676597753ddb51c8d74273650daa76'

openid = 'ofu7Ts4-v3xMIqAXfkEbyuEvb_Uc'
value = 50
count = 2
num = '00ER7Y8I'
url = 'http://wp.feit.me/ss.html'
unless openid and value and count and num and url
  res.json({errcode: 2, errmsg: 'parameter error'})
  return

templateId = 'ZTXmq9Mx1wKtaBGdW2kSsExcecQFVroepWaTC6la83Y'
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
api.sendTemplate openid, templateId, url, topColor, data, (err ,result) ->
  console.log err or result
