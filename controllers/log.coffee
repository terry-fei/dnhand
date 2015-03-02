express = require 'express'

log = require '../lib/log'


module.exports = router = express.Router()

router.get '/log', (req, res) ->
  limit = parseInt(req.query.limit) 
  start = parseInt(req.query.start)

  opts =
    from: new Date() - 24 * 60 * 60 * 1000
    until: new Date()
    limit: limit
    start: start
    order: 'desc'
    fields: ['timestamp', 'message']

  log.query opts, (err, result) ->
    if err
      res.json err
      return

    res.end JSON.stringify result, null, 2
