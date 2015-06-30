os = require 'os'
path = require 'path'
env = process.env

tmpPath = os.tmpdir()
module.exports =
  env: env.NODE_ENV
  wechat:
    token     : env.WECHAT_TOKEN
    appid     : env.WECHAT_APPID
    secret    : env.WECHAT_SECRET
    testOpenid: env.WECHAT_TEST_OPENID
    canThis   : env.WECHAT_HAS_ADVANCED_INTERFACE
  mongodb:
    user  : env.MONGO_USER
    pass  : env.MONGO_PASS
    host  : env.MONGO_HOST
    port  : env.MONGO_PORT
    dbname: env.MONGO_DBNAME
  session:
    secret: env.SESSION_SECRET
    filesPath: path.join tmpPath, 'dnhand_sessions'
  port: env.NODE_LISTEN_PORT
