
class MeshbluMessageTransformerProtobuf
  constructor: ({meshbluConfig}) ->

  toJSON: (protoMsg, callback) =>
    callback null, {}
    
module.exports = MeshbluMessageTransformerProtobuf
