mongoose = require 'mongoose'

OpenIdSchema = new mongoose.Schema
  openid: String
  stuid: String

module.exports = OpenIdSchema
