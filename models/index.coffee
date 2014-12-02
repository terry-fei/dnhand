mongoose = require('mongoose')
logger = require('winston')
config = require('../config')

conn = mongoose.createConnection(config.mongodb.host, config.mongodb.dbname)
conn.on 'error', (err) ->
  logger.error('connect to mongodb:dnhand error: ', err)
  process.exit(1)

GradeSchema = require('./Grade')
OpenIdSchema = require('./OpenId')
StudentSchema = require('./Student')
SyllabusSchema = require('./Syllabus')

models = {
  Grade: conn.model('Grade', GradeSchema),
  OpenId: conn.model('OpenId', OpenIdSchema),
  Student: conn.model('Student', StudentSchema),
  Syllabus: conn.model('Syllabus', SyllabusSchema)
}

module.exports = models
