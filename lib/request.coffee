http = require 'http'
iconv = require 'iconv-lite'
urllib = require 'urllib'
urlUtil = require 'url'

class JwcRequest
  constructor: (@ticket) ->

  @PROFILE:    'http://202.118.167.86/xjInfoAction.do?oper=xjxx'
  @SYLLABUS:   'http://202.118.167.86/lnkbcxAction.do?zxjxjhh=2014-2015-2-1'
  # @SYLLABUS:   'http://202.118.167.86/xkAction.do?actionType=6'

  @GRADE_URLS:
    # 本学期成绩
    bxq: 'http://202.118.167.86/bxqcjcxAction.do'

    # 不及格成绩
    bjg: 'http://202.118.167.86/gradeLnAllAction.do?oper=bjg'

    # 方案全部成绩
    fa: 'http://202.118.167.86/gradeLnAllAction.do?oper=fainfo'

    # 全部及格成绩
    qb: 'http://202.118.167.86/gradeLnAllAction.do?oper=qbinfo'

    # 课程属性成绩
    kcsx: 'http://202.118.167.86/gradeLnAllAction.do?oper=sxinfo'

  get: (url, callback) =>
    opts =
      dataType: 'text'
      headers:
        Cookie: "JSESSIONID=#{@ticket}"

    urllib.request url, opts, callback

loginRequest = (stuid, pswd, callback) ->
  url = "http://neaucode.sinaapp.com/auth?stuid=#{stuid}&pswd=#{pswd}"
  opts =
    timeout: 20000
    dataType: 'json'
  urllib.request url, opts, callback

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
