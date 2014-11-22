express = require("express")
bodyParser = require('body-parser')
session = require('express-session')
require('./models')

wechat = require('wechat')
wechatHanler = require("./controllers/wechatHandler")

app = express()

# session
app.use(session({secret: "feit", cookie: {maxAge: 60*5}}))
# wechat
app.use("/wx/api", wechat('feit', wechatHanler))
# static files
app.use("/assets", express.static(require("path").join(__dirname, '/assets')))
# view engin
app.set('view engine', 'html')
app.engine('html', require('ejs').renderFile)
# body parse
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

app.listen(7080, () ->
  console.log "Server Start at port #{app.get("port")}"
)

require("./controllers/info").route(app)
