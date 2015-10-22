wechatApi = require('wechat-api')
OAuth     = require('wechat-oauth')
config    = require '../config'

{WechatToken} = require('../models')

getToken = (callback) ->
  WechatToken.findOne {name: 'dnhand'}, callback

setToken = (token, callback) ->
  WechatToken.findOneAndUpdate {name: 'dnhand'}, token, {upsert: true}, callback

appid = config.wechat.appid
secret = config.wechat.secret
api = new wechatApi(appid, secret, getToken, setToken)
api.canThis = config.wechat.canThis

api.oauthApi = new OAuth(config.wechat.appid, config.wechat.secret)

module.exports = api
