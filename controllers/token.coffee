express = require 'express'
wechatApi = require '../lib/wechatApi'

module.exports = router = express.Router()

router.post '/ac', (req, res) ->
  key = req.body.key
  if key isnt 'feit.dnhand'
    return res.json {errcode: 1, errmsg: 'secret not correct'}

  wechatApi.getLatestToken (err, token) ->
    if err
      return res.json err

    res.json token
