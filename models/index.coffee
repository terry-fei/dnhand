mongoose = require('mongoose')

conn = mongoose.createConnection('mongodb://localhost/dnhand')

conn.on 'error', (err) ->
  console.error('connect to dnhand error: ')
  process.exit(1)

conn.once 'open', () ->
  console.log('connect to dnhand success!')

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