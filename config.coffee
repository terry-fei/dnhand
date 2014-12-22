env = process.env

module.exports =
  wechat:
    token  : env.WECHAT_TOKEN
    appid  : env.WECHAT_APPID
    secret : env.WECHAT_SECRET
    canThis: env.WECHAT_HAS_ADVANCED_INTERFACE
  mongodb:
    user  : env.MONGO_USER
    pass  : env.MONGO_PASS
    host  : env.MONGO_HOST
    port  : env.MONGO_PORT
    dbname: env.MONGO_DBNAME
  email:
    user: env.EMALL_USER
    pass: env.EMALL_PASS
  session:
    secret: env.SESSION_SECRET
  port: env.NODE_LISTEN_PORT
