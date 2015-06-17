_ = require('lodash')
meshblu = require('meshblu')
Backoff = require('backo')
meshbluJSON = require('./meshblu.json')
Fiber = require('fibers')

backoff = new Backoff(
  min: 1000
  max: 60 * 60 * 1000)

connectToMeshblu = (x, callback) ->
  console.log "starting #{x}"

  conn = meshblu.createConnection
    uuid: meshbluJSON.uuid
    token: meshbluJSON.token
    server: meshbluJSON.server
    port: meshbluJSON.port
    rememberUpgrade: true

  reconnect = ->
    randomNumber = Math.random() * 5
    timeout = setTimeout((->
      console.log "reconnecting #{x}"
      conn.connect()
    ), backoff.duration() * randomNumber)

  conn.on 'ready', (msg) ->
    console.log "Meshblu ready #{x}", msg
    backoff.reset()
    clearTimeout timeout
    timeout = null
    callback()

  conn.on 'notReady', (msg) ->
    console.log "MESHBLU NOT ready! #{x}", msg
    return if !msg.error
    if parseInt(msg.error.code) == 429
      console.log "rate limted #{x}, reconnecting"
      reconnect()

  return conn

connectToMeshblu process.argv[2], ->
  console.log "done #{process.argv[2]}"
  process.exit 0
