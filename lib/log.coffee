winston = require 'winston'
require('winston-mongodb').MongoDB
path = require 'path'

config = require '../config'
logPath = path.join __dirname, '..', 'log'
log = new (winston.Logger)(
  transports: [
    new (winston.transports.Console)()
  ]
)

mongoOpts =
  db: "mongodb://#{config.mongodb.host}/#{config.mongodb.dbname}"
  level: "info"

log.add winston.transports.MongoDB, mongoOpts
module.exports = log
