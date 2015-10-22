mongoose = require('mongoose')
log = require('winston')
config = require('../config')

conn = mongoose.createConnection(config.mongodb.host, config.mongodb.dbname)
conn.on 'error', (err) ->
  log.error('connect to mongodb:dnhand error: ', err)
  process.exit(1)

conn.once 'open', () ->
  log.info 'mongodb connected!'

GradeSchema    = require './Grade'
OpenIdSchema   = require './OpenId'
StudentSchema  = require './Student'
SyllabusSchema = require './Syllabus'
zyGradeSchema  = require './zyGrade'
WechatTokenSchema = require './WechatToken'

models =
  Grade: conn.model('Grade', GradeSchema),
  OpenId: conn.model('OpenId', OpenIdSchema),
  Student: conn.model('Student', StudentSchema),
  Syllabus: conn.model('Syllabus', SyllabusSchema),
  zyGrade: conn.model('zyGrade', zyGradeSchema),
  WechatToken: conn.model('WechatToken',  WechatTokenSchema)

module.exports = models
