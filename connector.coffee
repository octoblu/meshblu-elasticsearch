MeshbluWebsocket  = require 'meshblu-websocket'
{EventEmitter} = require 'events'
{Plugin} = require './index'

class Connector extends EventEmitter
  constructor: (@config={}) ->
    process.on 'uncaughtException', @emitError

  createConnection: =>
    @meshblu = new MeshbluWebsocket @config
    @meshblu.connect =>
      @meshblu.subscribe @config.uuid

    @meshblu.on 'notReady', @emitError
    @meshblu.on 'error', @emitError

    @meshblu.on 'ready', @onReady
    @meshblu.on 'message', @onMessage
    @meshblu.on 'config', @onConfig

  onConfig: (device) =>
    @emit 'config', device
    try
      @plugin.onConfig arguments...
    catch error
      @emitError error

  onMessage: (message) =>
    @emit 'message.recieve', message
    try
      @plugin.onMessage arguments...
    catch error
      @emitError error

  onReady: =>
    @meshblu.whoami uuid: @config.uuid, (device) =>
      @plugin.setOptions device.options
      @meshblu.update
        uuid:          @config.uuid,
        token:         @config.token,
        messageSchema: @plugin.messageSchema,
        optionsSchema: @plugin.optionsSchema,
        options:       @plugin.options

  run: =>
    @plugin = new Plugin();
    @createConnection()
    @plugin.on 'data', (data) =>
      @emit 'data.send', data
      @meshblu.data data

    @plugin.on 'error', @emitError

    @plugin.on 'message', (message) =>
      @emit 'message.send', message
      @meshblu.message message

  emitError: (error) =>
    @emit 'error', error

module.exports = Connector;
