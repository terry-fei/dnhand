should = require 'should'
require('nodedump')

studentService = require '../service/Student'
stuid = 'A19120626'
pswd = '1230.0'
student = new studentService stuid, pswd

describe 'StudentService', () ->
  before (done) ->
    student.login (err, result) ->
      done(err)

  describe 'getProfileByTicket', () ->
    it 'get student by net should ok', (done) ->
      student.getProfileByTicket (err, profile) ->
        if err then return done(err)

        profile.stuid.should.equal stuid
        profile.pswd.should.equal pswd
        profile.name.should.exist
        profile.id_card.should.exist
        done()

  describe 'getSyllabusByTicket', () ->
    it 'get syllabus by net should ok', (done) ->
      student.getSyllabusByTicket (err, syllabus) ->
        if err then return done(err)
        syllabus.should.be.exist
        done()

  describe 'getGradeByTicket', () ->
    it 'get qb grade by net should ok', (done) ->
      student.getGradeByTicket 'qb', (err, grade) ->
        if err then return done(err)
        grade.should.be.exist
        done()

  describe 'getGradeByTicket', () ->
    it 'get bjg grade by net should ok', (done) ->
      student.getGradeByTicket 'bjg', (err, grade) ->
        if err then return done(err)
        grade.should.be.exist
        done()

  describe 'getGradeByTicket', () ->
    it 'get fa grade by net should ok', (done) ->
      student.getGradeByTicket 'fa', (err, grade) ->
        if err then return done(err)
        grade.should.be.exist
        done()

  describe 'getGradeByTicket', () ->
    it 'get kcsx grade by net should ok', (done) ->
      student.getGradeByTicket 'kcsx', (err, grade) ->
        if err then return done(err)
        grade.should.be.exist
        done()

###
  describe 'getGradeByTicket', () ->
    it 'get bxq grade by net should ok', (done) ->
      student.getGradeByTicket 'bxq', (err, grade) ->
        if err then return done(err)
        grade.should.be.exist
        done()
###
