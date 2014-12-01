

module.exports = (app) ->

  app.get '/bind', (req, res) ->
    res.render 'bind', {req.query.openid}
