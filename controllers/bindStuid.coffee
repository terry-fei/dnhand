
Then = require 'thenjs'

openIdService = require '../services/OpenId'
studentService = require '../services/Student'

module.exports = (app) ->

  app.get '/bind', (req, res) ->
    res.render 'bind', {openid: req.query.openid}

  app.post '/bind', (req, res) ->
    stuid  = req.body.stuid
    pswd   = req.body.pswd
    openid = req.body.openid

    unless stuid and pswd and openid
      return res.json errcode: -1

    student = new studentService stuid, pswd

    Then (cont) ->
      student.login cont

    .then (cont, result) ->

      openIdService.bindStuid openid, stuid, cont

    .then (cont, openid) ->

      student.getInfoAndSave cont

    .then (cont) ->

      res.json errcode: 0

    .fail (cont, err) ->
      if err.errcode
        res.json errcode: err.errcode
      else
        res.json errcode: -1, errmsg: 'other'
