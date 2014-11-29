http = require 'http'
iconv = require 'iconv-lite'
urllib = require 'urllib'
urlUtil = require('url')

class JwcRequest

  PROFILE:    'http://202.118.167.86/xjInfoAction.do?oper=xjxx'
  SYLLABUS:   'http://202.118.167.86/xkAction.do?actionType=6'
  GRADE_BXQ:  'http://202.118.167.86/bxqcjcxAction.do'
  GRADE_BJG:  'http://202.118.167.86/gradeLnAllAction.do?oper=bjg'
  GRADE_FA:   'http://202.118.167.86/gradeLnAllAction.do?oper=fainfo'
  GRADE_QB:   'http://202.118.167.86/gradeLnAllAction.do?oper=qbinfo'
  GRADE_KCSX: 'http://202.118.167.86/gradeLnAllAction.do?oper=sxinfo'

  constructor: (@ticket) ->

  get: (url, callback) ->
    opts =
      timeout: 20000
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
  delete opts.url
  parsedUrl = if typeof url is 'string' then urlUtil.parse url else url
  opts.port = parsedUrl.port or 80
  opts.host = parsedUrl.hostname or parsedUrl.host or 'localhost'
  opts.path = parsedUrl.path or '/'
  if not opts.timeout then opts.timeout = 5000
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

      if opts.dataType
        type = res.headers['content-type']
        if not type
          body = body.toString()

        else
          charset = /^.*charset=(.+)/.exec(type)[1]
          charset = charset or 'urf-8'

          if not Buffer.isEncoding charset
            body = iconv.decode body, charset
          else
            body = body.toString(charset)

        if opts.dataType is 'json'
          body = JSON.parse body 

      console.log body
      callback null, body, res
  .on 'error', callback

  timer = setTimeout () ->
    timer = null
    req.abort()
    callback new Error('Request Timeout')
  , opts.timeout

module.exports.JwcRequest = JwcRequest
module.exports.loginRequest = loginRequest
