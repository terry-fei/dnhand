Then = require 'thenjs'
chai = require 'chai'
should = chai.should()
config = require '../config'

openIdService = require '../services/OpenId'
openid = config.wechat.openid

describe 'OpenIdService', () ->
  describe 'getUser', () ->
    it 'get user info without db should ok', (done) ->
      openIdService.removeUser openid, (err, removedUser) ->
        openIdService.getUser openid, (err, user) ->
          should.not.exist err
          user.should.have.property '_id'
          user.should.have.property 'openid'
          user.city.should.equal '哈尔滨'
          user.sex.should.equal '1'
          done()

    it 'get user info from db should ok', (done) ->
      openIdService.getUser openid, (err, user) ->
        should.not.exist err
        user.should.have.property '_id'
        user.should.have.property 'openid'
        user.city.should.equal '哈尔滨'
        user.sex.should.equal '1'
        done()

  describe 'fillUserInfo', () ->
    it 'fill user info should ok', (done) ->
      Then (cont) ->
        openIdService.getUser openid, cont
      .then (cont, user) ->
        user.nickname = ''
        user.city = ''
        user.sex = ''
        user.province = ''
        user.headimgurl = ''
        user.save cont
      .then (cont, user) ->
        openIdService.fillUserInfo user.openid, cont
      .fin (cont, error, user) ->
        should.not.exist error
        user.openid.should.equal user.openid
        user.should.have.property 'nickname'
        user.city.should.equal '哈尔滨'
        user.sex.should.equal '1'
        done()

  describe 'bindStuid', () ->
    it 'bind student id should ok', (done) ->
      openIdService.bindStuid openid, 'A19120626', (err, user) ->
        should.not.exist err
        user.openid.should.equal openid
        user.stuid.should.equal 'A19120626'
        done()

  describe 'unBindStuid', () ->
    it 'unbind student id should ok', (done) ->
      openIdService.unBindStuid openid, (err, user) ->
        should.not.exist err
        user.openid.should.equal openid
        user.stuid.should.equal ''
        done()
