express = require 'express'
bodyParser = require 'body-parser'
session = require 'express-session'
MongoStore = require('connect-mongo')(session)
logger = require 'winston'
require './models'

wechat = require 'wechat'
wechatHanler = require './controllers/wechatHandler'

app = express()

# session
app.use session
  secret: 'feit'
  store: new MongoStore
    db: 'dnhand'

# wechat
app.use '/wx/api', wechat 'feit', wechatHanler

# static files
app.use '/assets', require('st')(process.cwd())

# view engin
app.set('view engine', 'html')
app.engine('html', require('ejs').renderFile)

# body parse
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

app.listen 7080, () ->
  logger.info 'Server Start at port 7080'

require('./controllers/bindStuid')(app)
