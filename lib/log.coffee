log = require 'winston'

config = require '../config'
if config.env is 'production'
  require('winston-mongodb').MongoDB
  mongoOpts =
    db: "mongodb://#{config.mongodb.host}/#{config.mongodb.dbname}"
    level: "info"


  log.add log.transports.MongoDB, mongoOpts
  log.remove log.transports.Console
else
  log.transports.Console.level = 'debug'
  log.transports.Console.colorize = true
  log.transports.Console.prettyPrint = true
module.exports = log
