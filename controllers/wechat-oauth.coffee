qs = require 'querystring'
express = require 'express'

{oauthApi} = require '../lib/wechatApi'
module.exports = router = express.Router()

Jser = require '../models'

router.get '/wechat/oauth', (req, res) ->

  code = req.query.code

  unless code
    res.end 'error request'
    return

  try
    state = JSON.parse req.query.state
  catch error
    res.end 'error request'
    return

  url = state.url

  unless url
    res.end 'error request'
    return

  state.code = code
  delete state.url

  querys = qs.stringify state

  if !!~url.indexOf('?')
    querys = "&#{querys}"

  else
    querys = "?#{querys}"

  res.redirect "#{url + querys}"

router.get '/wechat/oauth/test', (req, res) ->

  code = req.query.code

  unless code
    oauthDispatherUrl = 'http://local.tunnel.mobi/wechat/oauth'
    thisUrl = "#{req.protocol}://#{req.hostname + req.path}"
    state = JSON.stringify {url: thisUrl}
    oauthUrl = oauthApi.getAuthorizeURL oauthDispatherUrl, state
    res.redirect oauthUrl
    return

  res.end code

router.get '/jser/welcome', (req, res) ->
  code = req.query.code
  type = req.query.type

  unless code
    oauthDispatherUrl = 'http://n.feit.me/wechat/oauth'
    thisUrl = "#{req.protocol}://#{req.hostname + req.path}"
    state = JSON.stringify {url: thisUrl}
    oauthUrl = oauthApi.getAuthorizeURL oauthDispatherUrl, state
    res.redirect oauthUrl
    return

  oauthApi.getAccessToken code, (err, result) ->
    if err
      return res.redirect 'http://www.rabbitpre.com/m/qyNmb6ei6'
    unless result.data
      return res.redirect 'http://www.rabbitpre.com/m/qyNmb6ei6'
    openid = result.data.openid

    if type is 'sign'
      Jser.update {openid}, {hasSign: true}, {upsert: true}, ->
      return res.end '<h2 style="text-aligen: center">预约成功，我们的工作人员会尽快与您取得联系</h2>'

    Jser.update {openid}, {hasVisit: true}, {upsert: true}, ->
    res.redirect 'http://www.rabbitpre.com/m/qyNmb6ei6'
