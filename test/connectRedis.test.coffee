redis = require("redis")

client = redis.createClient(6379, 'redis', {})

client.set('name', 'feit')

client.get 'name', (err, reply) ->
  console.log reply
