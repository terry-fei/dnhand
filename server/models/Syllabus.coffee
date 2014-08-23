mongoose = require 'mongoose'

SyllabusSchema = new mongoose.Schema
  stuid: { type: String, unique: true }
  1: { type:mongoose.Schema.Types.Mixed, default: null }
  2: { type:mongoose.Schema.Types.Mixed, default: null }
  3: { type:mongoose.Schema.Types.Mixed, default: null }
  4: { type:mongoose.Schema.Types.Mixed, default: null }
  5: { type:mongoose.Schema.Types.Mixed, default: null }
  6: { type:mongoose.Schema.Types.Mixed, default: null }
  unassigned: { type:mongoose.Schema.Types.Mixed, default: null }

module.exports = SyllabusSchema