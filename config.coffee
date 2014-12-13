
env = process.env.NODE_ENV

if env is 'production'
  config =
    wechat:
      # 'wx3ff5c48ba9ac6552', '6e1b422de4b33e385165ab80f73492df'
      appid: "wx3ff5c48ba9ac6552" 
      secret: "6e1b422de4b33e385165ab80f73492df"
      canThis: true
    mongodb:
      user: process.env.MONGO_USER
      pass: process.env.MONGO_PASS
      host: process.env.MONGO_HOST
      port: process.env.MONGO_PORT
      dbname: process.env.MONGO_DBNAME
    email:
      user: process.env.EMALL_USER
      pass: process.env.EMALL_PASS
    session:
      secret: "secret feit"
    port: 7080

else
  config =
    wechat:
      token: 'feit'
      openid: 'oZpuouAIdkHmuba1JFLbb4HUMVu8'
      appid: 'wx15c96420dd54edf9'
      secret: '5bf2a19b70f0aa9b05ea4da757ee3e1a'
      canThis: true
    mongodb:
      user: ''
      pass: ''
      host: 'mongo'
      port: '27017'
      dbname: 'dnhand_dev'
    email:
      user: ''
      pass: ''
    session:
      secret: 'feit'
    port: 7080

module.exports = config
