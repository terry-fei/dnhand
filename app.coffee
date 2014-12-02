express = require 'express'
bodyParser = require 'body-parser'
session = require 'express-session'
st = require 'st'
MongoStore = require('connect-mongo')(session)
logger = require 'winston'
require './models'
config = require './config'

wechat = require 'wechat'
wechatHanler = require './controllers/wechatHandler'

app = express()

# session
app.use session
  secret: config.session.secret
  store: new MongoStore
    db: config.mongodb.dbname

# wechat
app.use '/wx/api', wechat 'feit', wechatHanler

# static files
app.use st({path: __dirname + '/public', url: '/public', index: false})

# view engin
app.set('view engine', 'html')
app.engine('html', require('ejs').renderFile)

# body parse
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

app.listen 7080, () ->
  logger.info 'Server Start at port 7080'

require('./controllers/bindStuid')(app)
