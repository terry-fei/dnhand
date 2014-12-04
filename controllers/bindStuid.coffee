
Then = require 'thenjs'
logger = require 'winston'

openIdService = require '../services/OpenId'
studentService = require '../services/Student'

module.exports = (app) ->

  app.get '/bind', (req, res) ->
    return res.end 'Not Found' unless req.query.openid
    
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
      templateId = 'zPBcYZ708hYfPDCg-bGzZG4g_UyxBxGZe_lbHBVGZ9k'
      url = ''
      topColor = ''
      data = 
        first:
          value: '教务账号绑定成功'
          color: '#173177'
        keyword1:
          value: 'dnhand'
          color: '#173177'
        keyword2:
          value: stuid
          color: '#173177'
        keyword3:
          value: '查询课表，成绩等'
          color: '#173177'
        remark:
          value: '感谢你的使用！'
          color: '#173177'
      wechatApi.sendTemplate openid, templateId, url, topColor, data, cont

    .fail (cont, err) ->
      logger.error err
      if err.errcode
        res.json errcode: err.errcode
      else
        try
          res.json errcode: -1, errmsg: 'other'
        catch e
