path = require 'path'
urllib = require 'urllib'
cheerio = require 'cheerio'
config = require '../config'

module.exports.login = (user, callback) ->
  if not user.stuid or not user.pswd
    return callback new Error("require stuid and pswd")

  url = "http://localhost:7777/?stuid=#{user.stuid}&pswd=#{user.pswd}"

  urllib.request url, {dataType: 'json'}, (err, data, res) ->
    return callback(err) if err

    if res.statusCode isnt 200
      err = new Error('login error, code: ' + res.statusCode)
      return callback err

    data.stuid = user.stuid
    data.pswd  = user.pswd
    callback(null, data)

_makeHeaders = (cookie) ->
  return {
    Host:    '202.118.166.244:8080'
    Referer: 'http://202.118.166.244:8080/selfservice/module/webcontent/web/index_self.jsf?'
    Cookie:  cookie
  }

baseUrl  =  "http://202.118.166.244:8080/selfservice/"
stateUrl = "#{baseUrl}module/webcontent/web/content_self.jsf"
module.exports.currentState = (user, callback) ->
  if not user.cookie
    return callback new Error("require cookie")

  headers = _makeHeaders(user.cookie)
  options =
    dataType: 'text'
    headers:  headers

  urllib.request stateUrl, options, (err, html, res) ->
    return callback(err) if err

    if res.statusCode isnt 200
      err = new Error('state request status code error, code: ' + res.statusCode)
      return callback err

    spans = html.match /<span id="\S*?">.*?<\/span>/g
    tmpState = {}
    for span in spans
      dom = cheerio(span)
      tmpState[dom.attr('id')] = dom.text()

    state =
      userstate              : tmpState['offileForm:userstate']
      policydesc             : tmpState['offileForm:policydesc']
      currentAccountFeeValue : tmpState['offileForm:currentAccountFeeValue']
      currentPrepareFee      : tmpState['offileForm:currentPrepareFee']

    if (state.userstate is '正常') or (state.userstate.indexOf '暂停')
      timeMatch        = tmpState['offileForm:dateRange'].match /\d{4}-\d{2}-\d{2}/g
      state.rangeStart = timeMatch[0]
      state.rangeEnd   = timeMatch[1]
      freeSessionTime  = tmpState['offileForm:freeSessionTime']
      if freeSessionTime
        state.usedTime = freeSessionTime.split('/')[0]
      else
        state.usedTime = '周期内不限时长'

      state.onlineCount  = Number(/<font color="red">(\d{1})<\/font>/.exec(html)[1])
      if state.onlineCount isnt 0
        state.onlineIp   = /<input type="hidden" value="(.*?)">/.exec(html)[1]
        onlineTime       = /<td bgColor=#e1e8f3 class="f3f6f" width="350px" align="left">(.*?)<\/td>/.exec(html)[1]
        state.onlineTime = onlineTime.substring(5)

    state.errcode = 0
    callback(null, state)

_preRequest = (preUrl, headers, callback) ->
  options =
    dataType: 'text'
    headers:  headers

  urllib.request preUrl, options, (err, html, res) ->
    return callback err if err

    if res.statusCode isnt 200
      err = new Error('get view id error: ' + preUrl)
      return callback err

    callback null, html

checkNetCardStatusUrl = "#{baseUrl}module/chargecardself/web/chargecardself_list.jsf"
module.exports.checkNetCardStatus = (user, callback) ->
  if not user.cookie or not user.cardNo or not user.cardSecret or not user.code
    return callback new Error('require cookie, code, cardNo, cardSecret')

  headers = _makeHeaders(user.cookie)
  _preRequest checkNetCardStatusUrl, headers, (err, preHtml) ->
    return callback err if err

    viewid = /<input.*?name="com.sun.faces.VIEW".*?value="(.*?)".*?\/>/.exec(preHtml)[1]
    postData =
      'ChargeCardListForm:_id8'        : ''
      'ChargeCardListForm:submitcode'  : user.code
      'ChargeCardListForm:cardNo'      : user.cardNo
      'ChargeCardListForm:password'    : user.cardSecret
      'ChargeCardListForm:password_old': ''
      'ChargeCardListForm:_id9'        : '查询'
      'com.sun.faces.VIEW'             : viewid
      'ChargeCardListForm'             : 'ChargeCardListForm'

    options =
      method   : 'POST'
      data     : postData
      dataType : 'text'
      headers  :  headers

    urllib.request checkNetCardStatusUrl, options, (err, html, res) ->
      return callback err if err

      if res.statusCode isnt 200
        err = new Error('check net card status error: ' + postData)
        return callback err

      if !!~ html.indexOf '已作废或密码错误'
        return callback null, {errcode: 1, errmsg: '已作废或密码错误'}

      $ = cheerio.load html
      elems = $('[align=left]')
      state =
        'errcode'   : 0
        'cardNo'    : $(elems[0]).text().trim()
        'value'     : $(elems[1]).text().trim()
        'status'    : $(elems[3]).text().trim()
        'stuid'     : $(elems[5]).text().trim()
        'useDate'   : $(elems[6]).text().trim()
        'expireDate': $(elems[7]).text().trim()

      state.errcode = 0
      callback null, state

chargeUrl = "#{baseUrl}module/chargecardself/web/chargecardself_charge.jsf"
module.exports.charge = (user, callback) ->
  if not user.cookie or not user.cardNo or not user.cardSecret or not user.code
    return callback new Error('require cookie, code, cardNo, cardSecret')

  headers = _makeHeaders(user.cookie)
  _preRequest chargeUrl, headers, (err, preHtml) ->
    return callback err if err

    inpkv = {}
    inps = preHtml.match /<input.*?\/>?/g
    for inp in inps
      elem = cheerio(inp)
      inpkv[elem.attr('name')] = elem.attr('value') or ''

    inpkv['ChargeCardForm:cardNo']   = user.cardNo
    inpkv['ChargeCardForm:password'] = user.cardSecret
    inpkv['ChargeCardForm:verify']   = user.code
    inpkv['act']                     = ''
    inpkv['test']                    = 'on'

    delete inpkv['loginName']
    delete inpkv['userinfoHidden']
    delete inpkv['ChargeCardForm:getSelfChargeInfo']
    delete inpkv['ChargeCardForm:userId']
    delete inpkv['ChargeCardForm:user_password']
    delete inpkv['ChargeCardForm:_id12']
    delete inpkv['ChargeCardForm:canOverdraft']

    options =
      method   : 'POST'
      data     : inpkv
      dataType : 'text'
      headers  :  headers

    urllib.request checkNetCardStatusUrl, options, (err, html, res) ->
      return callback err if err

      if res.statusCode isnt 200
        err = new Error('charge error: ' + inpkv)
        return callback err

      if !!~ html.indexOf '充值卡已被充值'
        return callback null, {errcode: 1, errmsg: '充值卡已被充值'}

      if !!~ html.indexOf '生成时间'
        return callback null, {errcode: 0}

      if !!~ html.indexOf '充值卡不存在或已作废'
        return callback null, {errcode: 4, errmsg: '充值卡不存在或已作废'}

      callback null, {errcode: 5}

policyTable =
  '20A': '4af621d739867d050139aa19c5600f56'
  '20B': '4af621d739867d050139aa1a70460f85'
  '30A': '4af621d739867d050139aa1b78be0fc4'
  '30B': '4af621d739867d050139aa1cbeab0ffd'
  '50A': '4af621d739867d050139aa1da4b6102f'
  '50B': '4af621d739867d050139aa1e4e821050'
  '4af621d739867d050139aa19c5600f56': '20A'
  '4af621d739867d050139aa1a70460f85': '20B'
  '4af621d739867d050139aa1b78be0fc4': '30A'
  '4af621d739867d050139aa1cbeab0ffd': '30B'
  '4af621d739867d050139aa1da4b6102f': '50A'
  '4af621d739867d050139aa1e4e821050': '50B'

changePolicyUrl = "#{baseUrl}module/userself/web/userpolicychangeself_list.jsf"
changePolicyConfirmUrl = "#{baseUrl}module/userself/web/userpolicychangeself_add.jsf"
module.exports.changePolicy = (user, callback) ->
  if not user.cookie or not user.code or not user.policy
    return callback new Error('require cookie, code, policy')

  headers = _makeHeaders(user.cookie)
  _preRequest changePolicyUrl, headers, (err, preHtml) ->
    return callback err if err

    inpkv = {}
    inps = preHtml.match /<input.*?\/>?/g
    for inp in inps
      elem = cheerio(inp)
      inpkv[elem.attr('name')] = elem.attr('value') or ''

    currentPolicy = policyTable[inpkv.oldUserpackageUuid]
    if !!~ currentPolicy.indexOf user.policy
      expectPolicy = if !!~ currentPolicy.indexOf 'A' then "#{user.policy}B" else "#{user.policy}A"
    else
      expectPolicy = "#{user.policy}A"

    policyHash = policyTable[expectPolicy]

    operationTimeType = if user.immediately then '1' else '2'

    postData = {
      'act'                                        : '',
      'userinfoUuid'                               : inpkv['userinfoUuid'],
      'userTemplateUuid'                           : inpkv['userTemplateUuid'],
      'userId'                                     : inpkv['userId'],
      'oldUserpackageUuid'                         : inpkv['oldUserpackageUuid'],
      'oldPolicyInfoUuid'                          : inpkv['oldPolicyInfoUuid'],
      'limit'                                      : inpkv['limit'],
      'count'                                      : inpkv['count'],
      'needConfirm'                                : inpkv['needConfirm'],
      'repeatConfirm'                              : inpkv['repeatConfirm'],
      'isPeriodPolicy'                             : inpkv['isPeriodPolicy'],
      'immediateValue'                             : inpkv['immediateValue'],
      'UserPolicyChangeSelfForm:massge'            : '',
      'UserPolicyChangeSelfForm:_id28'             : '',
      'submitCodeId'                               : inpkv['submitCodeId'],
      'com.sun.faces.VIEW'                         : inpkv['com.sun.faces.VIEW'],
      'UserPolicyChangeSelfForm'                   : inpkv['UserPolicyChangeSelfForm']
      'UserPolicyChangeSelfForm:newUserpackageUuid': policyHash
      'UserPolicyChangeSelfForm:operationTimeType' : operationTimeType
    }

    options =
      method   : 'POST'
      data     : postData
      dataType : 'text'
      headers  :  headers

    urllib.request changePolicyUrl, options, (err, html, res) ->
      return callback err if err

      if res.statusCode isnt 200
        err = new Error('change policy step1 error: ' + inpkv)
        return callback err

      if !!~ html.indexOf '我已仔细阅读'
        inpkv2 = {}
        inps = html.match /<input.*?\/>?/g
        for inp in inps
          elem = cheerio(inp)
          inpkv2[elem.attr('name')] = elem.attr('value')

        inpkv2['UserPolicyChangeSelfForm:verify'] = user.code

        options =
          method   : 'POST'
          data     : inpkv2
          dataType : 'text'
          headers  :  headers

        urllib.request changePolicyConfirmUrl, options, (err, html, res) ->
          return callback err if err

          if res.statusCode isnt 200
            err = new Error('change policy step2 error: ' + inpkv2)
            return callback err

          if !!~ html.indexOf '计费套餐变更成功'
            callback null, {errcode: 0}
          else
            callback null, {errcode: 2}
      else
        callback null, {errcode: 2}
