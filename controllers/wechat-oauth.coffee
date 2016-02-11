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
