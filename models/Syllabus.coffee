mongoose = require 'mongoose'

SyllabusSchema = new mongoose.Schema
  stuid: { type: String, unique: true }
  length: Number
  0: { type:mongoose.Schema.Types.Mixed, default: [] }
  1: { type:mongoose.Schema.Types.Mixed, default: {} }
  2: { type:mongoose.Schema.Types.Mixed, default: {} }
  3: { type:mongoose.Schema.Types.Mixed, default: {} }
  4: { type:mongoose.Schema.Types.Mixed, default: {} }
  5: { type:mongoose.Schema.Types.Mixed, default: {} }
  6: { type:mongoose.Schema.Types.Mixed, default: {} }

module.exports = SyllabusSchema
