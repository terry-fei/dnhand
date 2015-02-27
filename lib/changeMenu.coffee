wechatApi = require('wechat-api')
config = require '../config'
api = new wechatApi('wx3ff5c48ba9ac6552', '6e1b422de4b33e385165ab80f73492df')

menu = require('fs').readFileSync(__dirname + '/menu.json', {encoding: 'utf-8'})

api.createMenu menu, (err, ret) ->
  console.log  err || ret
