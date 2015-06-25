urllib  = require 'urllib'

config = require '../config'

class JwcRequest
  constructor: (@ticket, @host) ->

  @PROFILE:    '/xjInfoAction.do?oper=xjxx'
  @HISTORY_SYLLABUS:   '/lnkbcxAction.do?zxjxjhh=2014-2015-2-1'
  @SYLLABUS:   '/xkAction.do?actionType=6'

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

loginRequest = (stuid, pswd, callback) ->
  unless !!~ HOST.indexOf 'http'
    return callback new Error 'AllServerBusy'

  currentHost = HOST
  url = "http://nh.feit.me/jwc?stuid=#{stuid}&pswd=#{pswd}&host=#{currentHost}"
  urllib.request url, {dataType: 'json'}, (err, data, res) ->
    return callback(err) if err

    if res.statusCode isnt 200
      err = new Error('login error, code: ' + res.statusCode)
      return callback err
    data.host = currentHost
    callback(null, data)

module.exports.JwcRequest = JwcRequest
module.exports.loginRequest = loginRequest
