isProduction = process.env.NODE_ENV is 'production'
if isProduction
  require 'oneapm'
else
  require('dotenv').load()

express    = require 'express'
bodyParser = require 'body-parser'
session    = require 'express-session'
MongoStore = require('connect-mongo')(session)
mongoose   = require 'mongoose'
log        = require 'winston'
require './models'

config     = require './config'

wechat       = require 'wechat'
wechatHanler = require './middleware/wechat'
jwcRouter = require './controllers/jwc'
oauthRouter = require './controllers/wechat-oauth'

app = express()

app.set 'trust proxy', true

conn = mongoose.createConnection(config.mongodb.host, config.mongodb.dbname)
app.use session({
  secret: config.session.secret
  resave: false
  saveUninitialized: true
  store: new MongoStore({mongooseConnection: conn})
})

# wechat
app.use '/wx/api', wechat(config.wechat.token, wechatHanler)

# body parse
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

# static files
publicDir = require('path').join(__dirname, 'public')
app.use express.static(publicDir)

# view engin
app.set 'views', './views'
app.set('view engine', 'html')
app.engine('html', require('ejs').renderFile)

app.use oauthRouter
app.use '/jwc', jwcRouter

app.listen config.port, () ->
  log.info "Server Start at port #{config.port}"
