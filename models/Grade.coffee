mongoose = require 'mongoose'

gradeSchema = new mongoose.Schema
  stuid: { type: String, unique: true }
  bxq: { type:mongoose.Schema.Types.Mixed, default: {} }
  qb: { type:mongoose.Schema.Types.Mixed, default: {} }
  bjg: { type:mongoose.Schema.Types.Mixed, default: {} }
  fa: { type:mongoose.Schema.Types.Mixed, default: {} }

module.exports = gradeSchema
