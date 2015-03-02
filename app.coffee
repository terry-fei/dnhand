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
bindStuidRouter = require './controllers/bindStuid'
ruijieRouter = require './controllers/ruijie'
youzanRouter = require './controllers/youzan'

app = express()

if config.env is 'production'
  sessionStore = new RedisStore({host: config.redis.host})

app.use '/wx', session
  secret: config.session.secret
  resave: false
  saveUninitialized: true
  store: sessionStore
  cookie:
    maxAge: 1000 * 60 * 5

# wechat
app.use '/wx/api', wechat(config.wechat.token, wechatHanler)

# static files
staticDir = require('path').join(__dirname, 'public')
app.use '/public', express.static(staticDir)

# view engin
app.set('view engine', 'html')
app.engine('html', require('ejs').renderFile)

# body parse
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

app.use bindStuidRouter
app.use '/ruijie', ruijieRouter
app.use '/youzan', youzanRouter

app.listen config.port, () ->
  logger.info "Server Start at port #{config.port}"
