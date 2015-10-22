mongoose  = require 'mongoose'

WechatTokenSchema = new mongoose.Schema
  name: String
  accessToken: String
  expireTime: Number

module.exports = WechatTokenSchema
