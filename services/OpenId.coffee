Then = require('thenjs')
copy = require('copy-to')
logger = require('winston')

openIdDao = require('../models').OpenId

wxApi = require('../lib/wechatApi')

openIdService =
  createUser: (openid, callback) ->
    if wxApi.can
      Then (cont) ->
        wxApi.getUser openid, cont
      .then (cont, user) ->
        openIdDao.create user, cont
      .fin (cont, error, user) ->
        callback(error, user)
      .fail callback
    else
      openIdDao.create openid: openid, callback

  fillUserInfo: (user) ->
    if wxApi.can
      process.nextTick () ->
        wxApi.getUser user.openid, (err, result) ->
          copy(result).pick('nickname', 'sex', 'city').to(user)
          user.save (err)->
            if err then logger.error err

  getUser: (openid, callback) ->
    Then (cont) ->
      openIdDao.findOne openid: openid, cont
    .then (cont, openIdIns) ->
      if not openIdIns
        openIdService.createUser openid, cont
      else
        if not openIdIns.nickname
          openIdService.fillUserInfo openIdIns
        cout(null, openIdIns)
    .fin (cont, error, result) ->
      callback(error, result)
    .fail callback

  bindStuid: (openid, stuid, callback) ->
    openIdDao.findOneAndUpdate openid: openid, $set: stuid: stuid, callback

  unBind: (openid, callback) ->
    openIdDao.findOneAndUpdate openid: openid, $set: stuid: '', callback

module.exports = openIdService
