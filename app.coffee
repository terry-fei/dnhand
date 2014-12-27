express = require 'express'
bodyParser = require 'body-parser'
session = require 'express-session'
MongoStore = require('connect-mongo')(session)
logger = require 'winston'
require './models'
config = require './config'

wechat = require 'wechat'
wechatHanler = require './controllers/wechatHandler'

module.exports = app = express()

# session
app.use session
  secret: config.session.secret
  resave: false
  saveUninitialized: true
  store: new MongoStore
    host: config.mongodb.host
    db: config.mongodb.dbname

# wechat
app.use '/wx/api', wechat(config.wechat.token, wechatHanler)

# static files
staticDir = require('path').join(__dirname, 'public')
app.use('/public', express.static(staticDir))

# view engin
app.set('view engine', 'html')
app.engine('html', require('ejs').renderFile)

# body parse
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

app.listen config.port, () ->
  logger.info "Server Start at port #{config.port}"

require('./controllers/bindStuid')(app)
