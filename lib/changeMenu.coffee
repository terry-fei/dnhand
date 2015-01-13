wechatApi = require('wechat-api')
config = require '../config'
api = new wechatApi(config.wechat.appid, config.wechat.secret)

menu = require('fs').readFileSync(__dirname + '/menu.json', {encoding: 'utf-8'})

api.createMenu menu, (err, ret) ->
  console.log  err || ret
