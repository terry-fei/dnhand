_ = require 'lodash'
Then = require 'thenjs'
logger = require 'winston'

OpenIdService = require '../service/OpenId'
StudentService = require '../service/Student'
GradeService = require '../service/Grade'
logger = console
wechatApi = require '../lib/wechatApi'

oauthApi = wechatApi.oauthApi

module.exports = (app) ->

  app.get '/wx/oauth', (req, res) ->
    code = req.query.code
    state = req.query.state
    oauthApi.getAccessToken code, (err, result) ->
      unless result.data
        return res.end('发生错误请重试')
      openid = result.data.openid
      if state is 'bind'
        res.redirect '/bind?openid=' + openid
      else
        res.end('Not Found')

  app.get '/bind', (req, res) ->
    return res.end 'Not Found' unless req.query.openid
    res.render 'bind', {openid: req.query.openid}

  app.post '/bind', (req, res) ->
    stuid  = req.body.stuid
    pswd   = req.body.pswd
    openid = req.body.openid

    unless stuid and pswd and openid
      return res.json errcode: -1

    student = new StudentService stuid, pswd

    Then (cont) ->
      student.login cont

    .then (cont, result) ->
      OpenIdService.bindStuid openid, stuid, cont

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
      if err.name isnt 'loginerror'
        logger.trace err
      if err.errcode
        res.json errcode: err.errcode
      else
        try
          res.json errcode: -1, errmsg: 'other'
        catch e

  app.get "/info/allgrade", (req, res, next) ->
    openid = req.query.openid
    Then (cont) ->
      OpenIdService.getUser openid, 'stuid', cont

    .then (cont, user) ->
      unless user.stuid
        return res.redirect '/bind?openid=' + openid

      GradeService.get user.stuid, 'fa', cont

    .then (cont, grade) ->
      unless grade
        return res.redirect '/bind?openid=' + openid

      result = _.values(grade['fa'])[0]
      return res.render 'all_grade', {'items': result}

    .fail (cont, error) ->
      logger.trace error
      try
        res.end('请稍候访问')
      catch e
        # ...
