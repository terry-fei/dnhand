mongoose = require 'mongoose'

JserSchema = new mongoose.Schema
  openid: String
  hasVisit: Boolean
  hasSign: Boolean

module.exports = JserSchema
