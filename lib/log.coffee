winston = require 'winston'
require('winston-mongodb').MongoDB
path = require 'path'

config = require '../config'
log = new winston.Logger

mongoOpts =
  db: "mongodb://#{config.mongodb.host}/#{config.mongodb.dbname}"
  level: "info"

log.add winston.transports.Console
log.add winston.transports.MongoDB, mongoOpts
module.exports = log
