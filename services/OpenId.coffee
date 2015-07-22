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
    Then (cont) ->
      wxApi.getUser openid, cont

    .then (cont, user) ->
      openIdDao.create user, cont

    .then (cont, user) ->
      callback(null, user)

    .fail (cont, err) ->
      callback err

  # get user info by openid
  # if not find in db then get it by this.createUser
  # return OpenId instance
  getUser: (openid, field) ->
    return Then (cont) ->
      openIdDao.findOne {openid: openid}, field, cont

    .then (cont, openIdIns) ->
      unless openIdIns
        OpenIdService.createUser openid, cont
        return

      cont null, openIdIns

  remove: (openid, callback) ->
    openIdDao.findOneAndRemove({openid: openid}, callback)

  bindStuid: (openid, stuid, callback) ->
    openIdDao.findOneAndUpdate({openid: openid}, {stuid: stuid}, {upsert: true}, callback)

  unBindStuid: (openid, callback) ->
    openIdDao.findOneAndUpdate({openid: openid}, {stuid: ''}, callback)

module.exports = OpenIdService
