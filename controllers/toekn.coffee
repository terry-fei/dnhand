express = require 'express'
wechatApi = require '../lib/wechatApi'

module.exports = router = express.Router()

router.post '/ac', (req, res) ->
  key = req.body.key
  if key isnt 'feitdnhad'
    return res.end 'error'

  wechatApi.getLatestToken (err, token) ->
    if err
      return res.end 'err'

    res.end token
