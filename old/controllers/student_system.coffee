request = require 'request'
_ = require 'underscore'

info = require './info'

exports.route = (app) ->
  app.get '/', (req, res) ->
    res.render 'index'

  app.get '/login', (req, res) ->
    res.render 'login'

  app.post '/login', (req, res) ->
    stuid = req.body.stuid
    pswd = req.body.pswd
    url = "http://neaucode.sinaapp.com/auth?stuid=#{stuid}&pswd=#{pswd}"
    request {uri: url, json: true}, (err, rres, body) ->
      if(!body)
        return res.json({errcode: 1})
      if body.errcode is 2
        return res.json({errcode: 2})
      req.session.ticket = body.ticket
      info.getProfileByStuid stuid, (err, stu) ->
        if(!stu)
          return res.json({errcode: 0})
        else
          req.session.stu = stu
          res.json({errcode: 0, name: stu.name})

  app.get '/allgrade', (req, res) ->
    if !req.session.ticket
      return res.redirect('/login')
    info.checkTicket req.session.ticket, (result) ->
      if result
        info.getAllGrade req.session.ticket, (err, grade) ->
          items = _.values(grade)[0]
          res.render 'wx-grade', {'items': items}
      else
        return res.redirect('/login')

  app.get '/nowgrade', (req, res) ->
    if !req.session.ticket
      return res.redirect('/login')
    info.checkTicket req.session.ticket, (result) ->
      if result
        info.getNowGrade req.session.ticket, (err, grade) ->
          items = _.values(grade)[0]
          if items
            res.render 'wx-grade', {'items': items}
          else
            res.send('没有本学期成绩信息')
      else
        return res.redirect('/login')
