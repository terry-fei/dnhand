Then = require('thenjs')
copy = require('copy-to')
logger = require('winston')

openIdDao = require('../models').OpenId

wxApi = require('../lib/wechatApi')

openIdService =
  createUser: (openid, callback) ->
    if wxApi.canThis
      Then (cont) ->
        wxApi.getUser openid, cont
      .then (cont, user) ->
        openIdDao.create user, cont
      .fin (cont, error, user) ->
        if error then cont(error)
        callback(null, user)
      .fail callback
    else
      openIdDao.create openid: openid, callback

  fillUserInfo: (openid, callback) ->
    if wxApi.canThis
      userTemp = null
      process.nextTick () ->
        Then (cont) ->
          openIdDao.findOne openid: openid, cont
        .then (cont, user) ->
          userTemp = user
          wxApi.getUser user.openid, cont
        .then (cont, wxUser) ->
          copy(wxUser)
          .pick('nickname', 'sex', 'city', 'province', 'headimgurl')
          .override(userTemp)
          userTemp.save cont
        .fin (cont, error, user) ->
          if error then callback?(error)
          callback?(user)
    else
      callback?()

  getUser: (openid, callback) ->
    Then (cont) ->
      openIdDao.findOne openid: openid, cont
    .then (cont, openIdIns) ->
      if not openIdIns
        openIdService.createUser openid, cont
      else
        if not openIdIns.nickname
          openIdService.fillUserInfo openIdIns.openid
        cont(null, openIdIns)
    .fin (cont, error, result) ->
      if error then cont(error)
      callback(null, result)
    .fail callback

  removeUser: (openid, callback) ->
    openIdDao.findOneAndRemove({openid: openid}, callback)

  bindStuid: (openid, stuid, callback) ->
    openIdDao.findOneAndUpdate({openid: openid}, {$set: {stuid: stuid}}, callback)

  unBindStuid: (openid, callback) ->
    openIdDao.findOneAndUpdate({openid: openid}, {$set: {stuid: ''}}, callback)

module.exports = openIdService
