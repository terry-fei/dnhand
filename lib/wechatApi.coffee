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

api = new wechatApi('whatever', 'whatever')
api.canThis = config.wechat.canThis
api.prefix = 'https://wechatserver.duapp.com/cgi-bin/'

api.preRequest = (method, args) ->
  this.token = {
    accessToken: "1&appid=#{appid}&username=feit&password=f6788f17"
  }
  method.apply(this, args)

api.oauthApi = new OAuth(config.wechat.appid, config.wechat.secret)

module.exports = api
