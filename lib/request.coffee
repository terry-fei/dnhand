urllib = require 'urllib'

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
      dataType: 'text'
      headers:
        Cookie: "JSESSIONID=#{@ticket}"

    urllib.request url, opts, callback


loginRequest = (stuid, pswd, callback) ->
  url = "http://neaucode.sinaapp.com/auth?stuid=#{stuid}&pswd=#{pswd}"
  opts =
    dataType: 'json'
  urllib.request url, opts, callback

module.exports.JwcRequest = JwcRequest
module.exports.loginRequest = loginRequest
