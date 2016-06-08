shmock                = require 'shmock'
enableDestroy         = require 'server-destroy'
TestHelper            = require './helpers'
MessageTransformer    = require '..'
spaceshipSchema       = require './data/spaceship-schema.json'

describe 'MessageToProtobuf', ->
  beforeEach 'setup meshblu', (done) ->
    @meshblu = shmock done
    enableDestroy @meshblu

    @meshbluConfig =
      server: 'localhost'
      port: @meshblu.address().port
      protocol: 'http'
      uuid: 'tentacle-uuid'
      token: 'tentacle-token'

  afterEach 'tear down meshblu', (done) ->
    @meshblu.destroy done

  beforeEach ->
    @sut = new MessageTransformer

  context 'when given a tentacle message', ->
    beforeEach 'meshblu', ->
      device =
        schemas:
          version: "1.0.0"
          message:
            spaceship: spaceshipSchema

      @meshblu.get('/v2/devices/tentacle-uuid').reply 200, device

    beforeEach 'setup message', ->
      spaceshipMessage = name: "speedy", size: 5

      @message = TestHelper.messageToProtobuf
        devices: ['t100']
        type: 'spaceship'
        data: TestHelper.encode
          message: spaceshipMessage
          protoPath: './test/data/spaceship.proto'
          type: 'spaceship'


    beforeEach (done) ->
      @sut.toJSON {@message, @meshbluConfig}, (error, @response) => done()

    it 'should create a json object', ->
      message =
        data: name: "speedy", size: 5
        devices: ['t100']
        metadata: messageType: 'spaceship'
              
      expect(@response).to.deep.equal(message)
