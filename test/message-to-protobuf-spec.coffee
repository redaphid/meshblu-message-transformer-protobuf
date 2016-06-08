shmock                = require 'shmock'
enableDestroy         = require 'server-destroy'
TestHelper            = require './helpers'
MessageToProtobuf     = require '..'
spaceshipSchema       = require './data/spaceship-schema.json'

describe 'MessageToProtobuf', ->
  beforeEach 'setup meshblu', (done) ->
    @meshblu = shmock done
    enableDestroy @meshblu
    @devicesRequest = @meshblu.get '/v2/tentacle-uuid'

    @meshbluConfig =
      host: 'localhost'
      port: @meshblu.address().port
      protocol: 'http'
      uuid: 'tentacle-uuid'
      token: 'tentacle-token'

  afterEach 'tear down meshblu', (done) ->
    @meshblu.destroy done

  beforeEach ->
    @sut = new MessageToProtobuf {@meshbluConfig}

  it 'should exist', ->
    expect(@sut).to.exist

  context 'when given a tentacle message', ->
    beforeEach 'meshblu', ->
      device =
        schemas:
          version: "1.0.0"
          message:
            spaceship: spaceshipSchema

      @devicesRequest.reply device

    beforeEach 'setup message', ->
      spaceshipMessage = name: "speedy", size: 5, fast: false

      @protoMsg = TestHelper.messageToProtobuf
        devices: ['t100']
        type: 'spaceship'
        data: TestHelper.encode
          message: spaceshipMessage
          protoPath: './test/data/spaceship.proto'
          type: 'spaceship'


    beforeEach (done) ->
      @sut.toJSON @protoMsg, (error, @response) => done()

    it 'should create a json object', ->
      expect(@response).to.deep.equal(
        devices: ['t100']
        metadata:
          messageType: 'tentacle'
        data:
          name: "speedy", size: 5, fast: false
      )
