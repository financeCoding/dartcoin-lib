part of dartcoin;

class ScriptChunk {
  bool _isOpCode;
  Uint8List _data;
  
  ScriptChunk(bool isOpCode, Uint8List data) {
    if(isOpCode && data.length != 1) throw new Exception("OpCode data must be of length 1.");
    if(data.length > Script.MAX_SCRIPT_ELEMENT_SIZE) throw new Exception("ScriptChunk data exceeds max data size.");
    _isOpCode = isOpCode;
    _data = data;
  }
  
  ScriptChunk.fromOpCode(int opCode) {
    _isOpCode = true;
    _data = new Uint8List.fromList([0xff & opCode]);
  }
  
  bool get isOpCode {
    return _isOpCode;
  }
  
  Uint8List get data {
    return _data;
  }
  
  String toString() {
    if(isOpCode) {
      return ScriptOpCodes.getOpCodeName(data[0]);
    }
    else {
      return "[" + Utils.bytesToHex(data) + "]";
    }
  }
  
  bool equalsOpCode(int opCode) {
    return isOpCode && data.length == 1 && _data[0] == opCode;
  }
  
  Uint8List encode() {
    List<int> result = new List();
    if(!isOpCode) {
      if(data.length < ScriptOpCodes.OP_PUSHDATA1) {
        result.add(data.length);
      }
      else if(data.length <= 0xff) {
        result.add(ScriptOpCodes.OP_PUSHDATA1);
        result.add(data.length);
      } else if (data.length <= 0xffff) {
        result.add(ScriptOpCodes.OP_PUSHDATA2);
        result.addAll(Utils.intToBytesLE(data.length, 2));
      } else {
        result.add(ScriptOpCodes.OP_PUSHDATA4);
        result.addAll(Utils.intToBytesLE(data.length, 4));
      }
    }
    result.addAll(data);
    return new Uint8List.fromList(result);
  }
}