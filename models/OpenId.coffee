mongoose = require 'mongoose'

OpenIdSchema = new mongoose.Schema
  openid: String
  stuid: String
  nickname: String
  sex: String
  city: String

module.exports = OpenIdSchema
