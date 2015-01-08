http    = require 'http'
iconv   = require 'iconv-lite'
urllib  = require 'urllib'
urlUtil = require 'url'

redis  = require("redis")
client = redis.createClient(6379, 'redis', {})

class JwcRequest
  constructor: (@ticket, @host) ->

  @PROFILE:    '/xjInfoAction.do?oper=xjxx'
  @SYLLABUS:   '/lnkbcxAction.do?zxjxjhh=2014-2015-2-1'
  # @SYLLABUS:   '/xkAction.do?actionType=6'

  @GRADE_URLS:
    # 本学期成绩
    bxq: '/bxqcjcxAction.do'

    # 不及格成绩
    bjg: '/gradeLnAllAction.do?oper=bjg'

    # 方案全部成绩
    fa: '/gradeLnAllAction.do?oper=fainfo'

    # 全部及格成绩
    qb: '/gradeLnAllAction.do?oper=qbinfo'

    # 课程属性成绩
    kcsx: '/gradeLnAllAction.do?oper=sxinfo'

  get: (path, callback) =>
    url = "#{@host}#{path}"
    opts =
      dataType: 'text'
      timeout: 5000
      headers:
        Cookie: "JSESSIONID=#{@ticket}"

    urllib.request url, opts, callback

HOST = 'http://202.118.167.85'
client.subscribe 'bestServer'
client.on 'message', (chan, msg) ->
  HOST = msg

loginRequest = (stuid, pswd, callback) ->
  unless !!~ HOST.indexOf 'http'
    return callback new Error 'AllServerBusy'

  currentHost = HOST
  url = "http://localhost:8888/?stuid=#{stuid}&pswd=#{pswd}&host=#{currentHost}"
  urllib.request url, {dataType: 'json'}, (err, data, res) ->
    return callback(err) if err

    if res.statusCode isnt 200
      err = new Error('login error, code: ' + res.statusCode)
      return callback err
    data.host = currentHost
    callback(null, data)

httpGet = (opts, callback) ->
  url = opts.url
  opts.url = null
  parsedUrl = if typeof url is 'string' then urlUtil.parse url else url
  opts.port = parsedUrl.port ? 80
  opts.host = parsedUrl.hostname ? parsedUrl.host ? 'localhost'
  opts.path = parsedUrl.path ? '/'
  opts.timeout ?= 5000
  timer = null
  req = http.get opts, (res) ->
    chunks = []
    resSize = 0

    res.on 'data', (chunk) ->
      resSize += chunk.length
      chunks.push chunk

    res.on 'end', () ->
      body = Buffer.concat chunks, resSize

      # 清除计时器
      if timer
        clearTimeout(timer)
        timer = null

      # 根据期望的数据类型转换body
      if opts.dataType

        # 根据响应header的charset转码body
        type = res.headers['content-type']
        unless type
          body = body.toString()

        else
          charset = /^.*charset=(.+)/.exec(type)[1]
          charset ?= 'urf-8'

          unless Buffer.isEncoding charset
            body = iconv.decode body, charset
          else
            body = body.toString(charset)

        if opts.dataType is 'json'
          body = JSON.parse body

      console.log body
      callback null, body, res
  .on 'error', callback

# 设定定时器
  timer = setTimeout () ->
    timer = null
    req.abort()
    callback new Error('Request Timeout')
  , opts.timeout

module.exports.JwcRequest = JwcRequest
module.exports.loginRequest = loginRequest
