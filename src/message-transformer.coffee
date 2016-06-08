_                     = require 'lodash'
MeshbluHttp           = require 'meshblu-http'
ProtoBuf              = require 'protobufjs'
ByteBuffer            = ProtoBuf.ByteBuffer
path                  = require 'path'
pb2js                 = require 'jsonschema-protobuf'
class MeshbluMessageTransformerProtobuf
  constructor: ->
    protoPath               =   path.join __dirname, 'proto', 'message.proto'
    builder                 = ProtoBuf.loadProtoFile protoPath
    @MeshbluMessageProto    = builder.build 'MeshbluMessage'
    console.log protoPath

  toJSON: ({message, meshbluConfig}, callback) =>
    envelope = @MeshbluMessageProto.decode(message)
    type     = envelope.metadata.messageType
    meshblu  = new MeshbluHttp meshbluConfig

    meshblu.device meshbluConfig.uuid, (error, device) =>
      return callback error if error?

      schema = _.get device, "schemas.message.#{type}"
      return callback new Error "Error, schema not found for message type #{type}" unless schema?

      callback null, @_decodeMessage {envelope, schema, type}

  _decodeMessage: ({envelope, schema, type}) =>
      builder     = ProtoBuf.loadProto pb2js(schema)
      ProtoClass  = builder.build type
      data        = JSON.parse ProtoClass.decode(envelope.data).encodeJSON()
      message =
        data: data
        devices: envelope.metadata.devices
        metadata: messageType: type

module.exports = MeshbluMessageTransformerProtobuf
