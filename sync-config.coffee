
module.exports =
  localDir: __dirname

  # It decides the root path to upload to.
  remoteDir: '/home/feit/dev/dnhand'

  # It decides the root accessible path.
  rootAllowed: '/home/feit'

  host: 'neau.feit.me'
  port: 8345
  pattern: '**'
  pollingInterval: 500

  # If it is set, transfer data will be encrypted with the algorithm.
  password: null
  algorithm: 'aes128'

  onChange: (type, path, oldPath) ->
    # It can also return a promise.
    console.log('Write your custom code here')
