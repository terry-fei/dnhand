http = require 'http'
iconv = require 'iconv-lite'
urllib = require 'urllib'
urlUtil = require 'url'
exec = require('child_process').exec

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
      headers:
        Cookie: "JSESSIONID=#{@ticket}"

    urllib.request url, opts, callback

loginRequest = (stuid, pswd, callback) ->
  host = "http://202.118.167.86"
  arg = "#{__dirname}/JwcLoginHelper.py #{stuid} #{pswd} #{host}"
  exec arg, (error, stdout, stderr) ->
    if error
      return callback error

    try
      ret = JSON.parse stdout
    catch e
      return callback e

    ret.host = host
    callback null, ret

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
