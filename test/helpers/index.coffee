ProtoBuf              = require 'protobufjs'
ByteBuffer            = ProtoBuf.ByteBuffer

class TestHelper
  @messageToProtobuf: ({devices, type, data}) ->
    message =
      metadata:
        devices: devices
        messageType: type
      data: data

    TestHelper.encode
      message: message
      protoPath: './src/proto/message.proto'
      type: 'MeshbluMessage'

  @encode: ({message, protoPath, type}) ->
    builder       = ProtoBuf.loadProtoFile protoPath
    ProtoClass    = builder.build type
    msgProto      = new ProtoClass message
    msgProto.encode().toBuffer()



module.exports = TestHelper
