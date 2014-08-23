express  = require "express"
mongoose = require "mongoose"
dnhand   = require "./controllers/dnhand"
path     = require "path"

app = exports.app = express()

app.use express.cookieParser()
app.use express.session({secret: "feit", cookie: {maxAge: 180000}})
app.use "/wx/api", dnhand
app.use(express.urlencoded())
app.use(express.json())
app.use(require('connect-multiparty')())
app.set("view engine","ejs")
app.set('views', __dirname + '/views');
app.use "/assets", express.static(path.join(__dirname, '..', '/assets'))

app.set("port", 7080)

app.listen app.get("port"), () ->
  console.log "Server Start at port #{app.get("port")}"

require("./controllers/info").route(app)
require('./controllers/student_system').route(app)