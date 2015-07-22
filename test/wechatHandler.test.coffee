should = require 'should'
{tail, template} = require './wechat.support'
request = require 'supertest'

apiUrl = '/wx/api' + tail()
config = require '../config'

app = require '../app'

openid = config.wechat.testOpenid

describe 'wechat handler test', () ->
  it 'subscribe should ok', (done) ->
    info =
      sp: 'dnhand'
      user: openid
      type: 'event'
      event: 'subscribe'

    request(app)
      .post('/wx/api' + tail())
      .send(template(info))
      .expect(200)
      .end (err, res) ->
        return done err if err
        res.text.should.containEql openid
        done()

  it 'get today syllabus should ok', (done) ->
    info =
      sp: 'dnhand'
      user: openid
      type: 'event'
      event: 'CLICK'
      eventKey: 'todaySyllabus'

    request(app)
      .post('/wx/api' + tail())
      .send(template(info))
      .expect(200)
      .end (err, res) ->
        return done err if err
        res.text.should.containEql openid
        done()

  it 'get tomorrow syllabus should ok', (done) ->
    info =
      sp: 'dnhand'
      user: openid
      type: 'event'
      event: 'CLICK'
      eventKey: 'tomorrowSyllabus'

    request(app)
      .post('/wx/api' + tail())
      .send(template(info))
      .expect(200)
      .end (err, res) ->
        return done err if err
        res.text.should.containEql openid
        done()

  it 'get today syllabus by text should ok', (done) ->
    info =
      sp: 'dnhand'
      user: openid
      type: 'text'
      text: '明天课程表'

    request(app)
      .post('/wx/api' + tail())
      .send(template(info))
      .expect(200)
      .end (err, res) ->
        return done err if err
        res.text.should.containEql openid
        done()

  it 'get yesterday syllabus by text should ok', (done) ->
    info =
      sp: 'dnhand'
      user: openid
      type: 'text'
      text: '昨天课表'

    request(app)
      .post('/wx/api' + tail())
      .send(template(info))
      .expect(200)
      .end (err, res) ->
        return done err if err
        res.text.should.containEql openid
        done()


  it 'get all syllabus should ok', (done) ->
    info =
      sp: 'dnhand'
      user: openid
      type: 'event'
      event: 'CLICK'
      eventKey: 'allSyllabus'

    request(app)
      .post('/wx/api' + tail())
      .send(template(info))
      .expect(200)
      .end (err, res) ->
        return done err if err
        res.text.should.containEql openid
        done()

  it 'get now grade should ok', (done) ->
    info =
      sp: 'dnhand'
      user: openid
      type: 'event'
      event: 'CLICK'
      eventKey: 'nowGrade'

    request(app)
      .post('/wx/api' + tail())
      .send(template(info))
      .expect(200)
      .end (err, res) ->
        return done err if err
        res.text.should.containEql openid
        done()

  it 'get not pass grade should ok', (done) ->
    info =
      sp: 'dnhand'
      user: openid
      type: 'event'
      event: 'CLICK'
      eventKey: 'noPassGrade'

    request(app)
      .post('/wx/api' + tail())
      .send(template(info))
      .expect(200)
      .end (err, res) ->
        return done err if err
        res.text.should.containEql openid
        done()

  it 'get make up exam info should ok', (done) ->
    info =
      sp: 'dnhand'
      user: openid
      type: 'text'
      text: '补考A19120626'

    request(app)
      .post('/wx/api' + tail())
      .send(template(info))
      .expect(200)
      .end (err, res) ->
        return done err if err
        res.text.should.containEql openid
        done()

  it 'get term end exam info should ok', (done) ->
    info =
      sp: 'dnhand'
      user: openid
      type: 'text'
      text: '期末A19120626'

    request(app)
      .post('/wx/api' + tail())
      .send(template(info))
      .expect(200)
      .end (err, res) ->
        return done err if err
        res.text.should.containEql openid
        done()
