chai = require 'chai'
should = chai.should()

studentService = require '../services/Student'
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
