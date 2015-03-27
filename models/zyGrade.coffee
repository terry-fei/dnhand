mongoose = require 'mongoose'

zyGradeSchema = new mongoose.Schema
  stuid:
    type: String
    unique: true
  name: String
  majorName: String
  majorYear: Number
  clsNo: Number
  zyGrade: Number
  clsRank: Number
  majorRank: Number

module.exports = zyGradeSchema
