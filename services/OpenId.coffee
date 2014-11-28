Then = require('thenjs')
copy = require('copy-to')
logger = require('winston')

openIdDao = require('../models').OpenId

wxApi = require('../lib/wechatApi')

openIdService =

  # save user info to db
  # if has advance interface then save more info
  # return OpenId instance
  createUser: (openid, callback) ->
    if wxApi.canThis
      Then (cont) ->
        wxApi.getUser openid, cont
      .then (cont, user) ->
        openIdDao.create user, cont
      .fin (cont, error, user) ->
        if error then return cont(error)
        callback(null, user)
      .fail callback
    else
      openIdDao.create openid: openid, callback

  # if has advance interface and user info not enough then fill it
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
          if error then return callback?(error)
          callback?(user)
    else
      callback?()

  # get user info by openid
  # if not find in db then get it by this.createUser
  # return OpenId instance
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
      if error then return cont(error)
      callback(null, result)
    .fail callback

  removeUser: (openid, callback) ->
    openIdDao.findOneAndRemove({openid: openid}, callback)

  bindStuid: (openid, stuid, callback) ->
    openIdDao.findOneAndUpdate({openid: openid}, {$set: {stuid: stuid}}, callback)

  unBindStuid: (openid, callback) ->
    openIdDao.findOneAndUpdate({openid: openid}, {$set: {stuid: ''}}, callback)

module.exports = openIdService
