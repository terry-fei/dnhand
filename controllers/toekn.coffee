express = require 'express'
wechatApi = require '../lib/wechatApi'

router = express.Router()

router.post '/actoken', (req, res) ->
  key = req.body.key
  if key isnt 'feitdnhad'
    return res.end 'error'

  wechatApi.getLatestToken (err, token) ->
    if err
      return res.end 'err'

    res.end token
