wechatApi = require('wechat-api')
OAuth = require('wechat-oauth')
config = require '../config'

api = new wechatApi(config.wechat.appid, config.wechat.secret)
api.canThis = config.wechat.canThis

api.oauthApi = new OAuth(config.wechat.appid, config.wechat.secret)

module.exports = api
