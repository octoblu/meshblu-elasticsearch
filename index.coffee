'use strict';
util           = require 'util'
{EventEmitter} = require 'events'
elasticsearch  = require 'elasticsearch'
_              = require 'lodash'
debug          = require('debug')('meshblu-elasticsearch')
request = require 'request'

MESSAGE_SCHEMA =
  type: 'object'
  properties:
    exampleBoolean:
      type: 'boolean'
      required: true
    exampleString:
      type: 'string'
      required: true

OPTIONS_SCHEMA =
  type: 'object'
  properties:
    firstExampleOption:
      type: 'string'
      required: true

class Plugin extends EventEmitter
  constructor: ->
    @options = {}
    @messageSchema = MESSAGE_SCHEMA
    @optionsSchema = OPTIONS_SCHEMA
    @elasticsearch = new elasticsearch.Client host: 'localhost:9200'

  onMessage: (message) =>
    debug 'onMessage', message
    return if message.topic == 'device-status'

    topic = _.snakeCase message.topic

    @elasticsearch.create
      index: "event_#{topic}"
      type: 'event'
      body: message.payload

  onConfig: (device) =>
    @setOptions device.options

  setOptions: (options={}) =>
    @options = options

module.exports =
  messageSchema: MESSAGE_SCHEMA
  optionsSchema: OPTIONS_SCHEMA
  Plugin: Plugin
