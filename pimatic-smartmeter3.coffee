module.exports = (env) ->
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  t = env.require('decl-api').types
  fs = env.require 'fs' 

  SerialPort = require 'serialport'
  Readline = SerialPort.parsers.Readline

  class Smartmeter3Plugin extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      deviceConfigDef = require('./device-config-schema')
      @framework.deviceManager.registerDeviceClass('Smartmeter3Device', {
        configDef: deviceConfigDef.Smartmeter3Device,
        createCallback: (config) => new Smartmeter3Device(config)
      })

  # Basic serial device, all other serial devices are extended from this one.
  # When defining just a SerialDevice in pimatic the only option you have is to send a command using a rule
  # which might be just enough in some cases.
  class Smartmeter3Device extends env.devices.Device
    parser = null
    port = null

    attributes:
      actualusage:
        description: "Actual usage"
        type: "number"
        unit: " Watt"
        acronym: "Actual usage"
      tariff1totalusage:
        description: "Tariff 1 total usage(T1)"
        type: "number"
        unit: " kWh"
        acronym: "T1"
      tariff2totalusage:
        description: "Tariff 2 total usage(T2)"
        type: "number"
        unit: " kWh"
        acronym: "T2"
      gastotalusage:
        description: "Gas total usage"
        type: "number"
        unit: " m3"
        acronym: "Gas"
    actualusage: 0.0
    activetariff: 1
    tariff1totalusage: 0.0
    tariff2totalusage: 0.0
    gastotalusage: 0.0


    constructor: (config, lastState) ->
      @config = config
      @id = @config.id
      @name = @config.name

      @serialPort = if @config.serialPort then @config.serialPort else config.serialPort
      @baudRate = if @config.baudRate then @config.baudRate else config.baudRate
      @dataBits = if @config.dataBits then @config.dataBits else config.dataBits
      @parity = if @config.parity then @config.parity else config.parity
      @stopBits = if @config.stopBits then @config.stopBits else config.stopBits
      @flowControl = if @config.flowControl then @config.flowControl else config.flowControl
      @parserDelimiter = "!"

      @t1TotalUsage = RegExp (if @config.t1TotalUsage then @config.t1TotalUsage else config.t1TotalUsage), "m"
      @t2TotalUsage = RegExp (if @config.t2TotalUsage then @config.t2TotalUsage else config.t2TotalUsage), "m"
      @activeTariff = RegExp (if @config.activeTariff then @config.activeTariff else config.activeTariff), "m"
      @actualUsage = RegExp (if @config.actualUsage then @config.actualUsage else config.actualUsage), "m"
      @gasTotalUsage = RegExp (if @config.gasTotalUsage then @config.gasTotalUsage else config.gasTotalUsage), "m"

      # Create the response parser, if any
      @parser = new SerialPort.parsers.Readline({delimiter: @parserDelimiter})

      @connect();
      
      super()

    connect: (callback = null) ->
      env.logger.debug 'Creating port'
      @port = SerialPort @serialPort, {
        baudRate: @baudRate,
        dataBits: @dataBits,
        parity: @parity,
        stopBits: @stopBits,
        flowControl: @flowControl,
        autoOpen: true
        }, (error) =>
          if error
            env.logger.error 'Error: %s', error.message
          else
            env.logger.debug 'Port created and opened'

      if @responseHandler
        if @parser
          @port.pipe @parser
          @parser.on 'data', (data) =>
            @responseHandler data
        else
          env.logger.info 'No response parser configured'

    disconnect: (callback) ->
      if @port && @port.isOpen
        env.logger.debug 'Closing port'
        @port.close (error) =>
          if error
            env.logger.error error
          else
            env.logger.debug 'Closed port'
            @port = null
            if callback
              env.logger.debug 'Executing callback'
              callback()
      else
        env.logger.debug 'Port is already closed'
        if callback
          env.logger.debug 'Executing callback'
          callback()

    returnRegExResult: (data, regex) ->
      try
        _result = data.match(regex)
        if _result?
          return _result[1]
        else
          return 0
      catch
        env.logger.error 'Invalid Regular Expression in config: ' + regex

    responseHandler: (data) ->
        _tariffOneTotalUsage = @returnRegExResult(data, @t1TotalUsage)
        _tariffTwoTotalUsage = @returnRegExResult(data, @t2TotalUsage)
        _currentTariff = @returnRegExResult(data, @activeTariff)
        _currentUsage = 1000 * @returnRegExResult(data, @actualUsage)
        _gasTotalUsage = @returnRegExResult(data, @gasTotalUsage)

        @actualusage = Number _currentUsage
        @emit "actualusage", Number @actualusage

        @activetariff = Number _currentTariff
        @emit "activetariff", Number @activetariff

        @tariff1totalusage = Number _tariffOneTotalUsage
        @emit "tariff1totalusage", Number @tariff1totalusage

        @tariff2totalusage = Number _tariffTwoTotalUsage
        @emit "tariff2totalusage", Number @tariff2totalusage

        @gastotalusage = Number _gasTotalUsage
        @emit "gastotalusage", Number @gastotalusage

    getActualusage: -> Promise.resolve @actualusage
    getActivetariff: -> Promise.resolve @activetariff
    getTariff1totalusage: -> Promise.resolve @tariff1totalusage
    getTariff2totalusage: -> Promise.resolve @tariff2totalusage
    getGastotalusage: -> Promise.resolve @gastotalusage

    destroy: () ->
      @disconnect()
      super()

  return new Smartmeter3Plugin
