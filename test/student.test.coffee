chai = require 'chai'
should = chai.should()

studentService = require '../services/Student'
ticket

describe 'StudentService', () ->
  before () ->
    studentService.login 'A19120626', '1230.0', (err, result) ->
      ticket = result.ticket
  describe 'getStudentByTicket', () ->
    it 'get student by net should ok', (done) ->
      studentService.getStudentByTicket
      done()
