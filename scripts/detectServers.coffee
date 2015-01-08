Then    = require 'thenjs'
CronJob = require('cron').CronJob
urllib  = require 'urllib'
config  = require '../config'

redis = require 'redis'
client = redis.createClient(config.redis.port, config.redis.host, {})

SERVERS = [
  'http://202.118.167.85'
  'http://202.118.167.85:9001'
  'http://202.118.167.85:9002'
  'http://202.118.167.86'
  'http://202.118.167.86:9001'
  'http://202.118.167.86:9002'
  'http://202.118.167.86:9003'
  'http://202.118.167.86:9004'
]

detectServers = () ->
  Then.each SERVERS, (cont, server) ->
    opts =
      method:  'HEAD'
      timeout: 2000

    startTime = new Date()
    urllib.request server, opts, (err, data, res) ->
      result = {}

      if err or res.statusCode isnt 200
        result[server] = Number.MAX_VALUE
        return cont null, result

      result[server] = new Date() - startTime

      cont null, result

  .then (cont, result) ->
    if result.length is 0
      return cont new Error('AllServerBusy')
    compareResult = {}
    fastest = Number.MAX_VALUE
    for item in result
      for k, v of item
        fastest = v if v < fastest
        compareResult[v] = k

    client.publish 'bestServer', compareResult[fastest]

  .fail (cont, error) ->
    client.publish 'bestServer', err.message

job = new CronJob
  cronTime: '*/30 * * * * *'
  onTick  : detectServers
  start   : true

job.start()
