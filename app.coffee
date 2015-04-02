require 'localenv'
express    = require 'express'
bodyParser = require 'body-parser'
session    = require 'express-session'
RedisStore = require('connect-redis')(session)
logger     = require 'winston'
require './models'

config     = require './config'

wechat       = require 'wechat'
wechatHanler = require './middleware/wechat'
jwcRouter = require './controllers/jwc'
ruijieRouter = require './controllers/ruijie'
youzanRouter = require './controllers/youzan'

app = express()

if config.env is 'production'
  sessionStore = new RedisStore({host: config.redis.host})

app.use session
  secret: config.session.secret
  resave: false
  saveUninitialized: true
  store: sessionStore
  cookie:
    maxAge: 1000 * 60 * 5

# wechat
app.use '/wx/api', wechat(config.wechat.token, wechatHanler)

# body parse
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

# youzan user interface
app.use '/youzan', youzanRouter

# static files
staticDir = require('path').join(__dirname, 'public')
app.use '/public', express.static(staticDir)

# client res
clientDir = require('path').join __dirname, 'client'
app.use express.static clientDir

# view engin
app.set('view engine', 'html')
app.engine('html', require('ejs').renderFile)

app.use require './controllers/wechat-oauth'
app.use '/jwc', jwcRouter
app.use '/ruijie', ruijieRouter
app.use '/log', require './controllers/log'

app.listen config.port, () ->
  logger.info "Server Start at port #{config.port}"
