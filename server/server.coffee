express  = require "express"
mongoose = require "mongoose"
dnhand   = require "./controllers/dnhand"
path     = require "path"
wechatApi   = require("wechat").API

wxApi = new wechatApi('wx3ff5c48ba9ac6552', '2715445e17a0640bc4f2a2f884a69124')


app = express()
app.use express.cookieParser()
app.use express.session({secret: "feit", cookie: {maxAge: 180000}})
app.use "/wx/api", dnhand
app.use(express.json())
app.use(require('connect-multiparty')())
app.set("view engine","ejs")
app.set('views', __dirname + '/views')
app.use "/assets", express.static(path.join(__dirname, '..', '/assets'))

app.set("port", 7080)

app.listen app.get("port"), () ->
  console.log "Server Start at port #{app.get("port")}"

require("./controllers/info").route(app)
