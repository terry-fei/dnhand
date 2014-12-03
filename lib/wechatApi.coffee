wechatApi = require('wechat-api')
config = require '../config'

api = new wechatApi(config.wechat.appid, config.wechat.secret)
api.canThis = config.wechat.canThis

module.exports = api;
