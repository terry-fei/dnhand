mongoose = require 'mongoose'

gradeSchema = new mongoose.Schema
  stuid: { type: String, unique: true }
  bxq: { type:mongoose.Schema.Types.Mixed, default: null }
  qb: { type:mongoose.Schema.Types.Mixed, default: null }
  bjg: { type:mongoose.Schema.Types.Mixed, default: null }
  fa: { type:mongoose.Schema.Types.Mixed, default: null }

module.exports = gradeSchema
