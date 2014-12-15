Then = require('thenjs')
copy = require('copy-to')
logger = require('winston')

openIdDao = require('../models').OpenId

wxApi = require('../lib/wechatApi')

OpenIdService =

  # save user info to db
  # if has advance interface then save more info
  # return OpenId instance
  createUser: (openid, callback) ->
    if wxApi.canThis
      Then (cont) ->
        wxApi.getUser openid, cont

      .then (cont, user) ->
        openIdDao.create user, cont

      .then (cont, user) ->
        callback(null, user)

      .fail (cont, err) ->
        callback err
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

        .then (cont, user) ->
          callback?(user)
        .fail (cont, error) ->
          callback?(error)
    else
      callback?()

  # get user info by openid
  # if not find in db then get it by this.createUser
  # return OpenId instance
  getUser: (openid, field, callback) ->
    Then (cont) ->
      openIdDao.findOne {openid: openid}, field, cont

    .then (cont, openIdIns) ->
      unless openIdIns
        OpenIdService.createUser openid, cont
      else
        unless openIdIns.nickname
          OpenIdService.fillUserInfo openIdIns.openid
        cont(null, openIdIns)

    .then (cont, result) ->
      callback(null, result)

    .fail (cont, err) ->
      callback err

  remove: (openid, callback) ->
    openIdDao.findOneAndRemove({openid: openid}, callback)

  bindStuid: (openid, stuid, callback) ->
    openIdDao.findOneAndUpdate({openid: openid}, {$set: {stuid: stuid}}, {upsert: true}, callback)

  unBindStuid: (openid, callback) ->
    openIdDao.findOneAndUpdate({openid: openid}, {$set: {stuid: ''}}, callback)

module.exports = OpenIdService
