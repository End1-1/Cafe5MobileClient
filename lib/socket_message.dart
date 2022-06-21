import 'dart:io';
import 'dart:typed_data';

class SocketMessage {

  static final int c_hello = 1;

  late BytesBuilder buffer;
  int messageId;
  int command;
  int _dataSize = 0;

  static int _packetNumberCounter = 1;
  static int _messageNumberCounter = 1;

  SocketMessage({required this.messageId, required this.command}) {
     buffer = BytesBuilder();
  }

  void addByte(int value) {
    buffer.addByte(value);
    _dataSize++;
  }

  void addShort(int value) {
    buffer.add(Uint8List(2)..buffer.asByteData().setInt16(0, value, Endian.big));
    _dataSize += 2;
  }

  void addInt(int value) {
    buffer.add(Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big));
    _dataSize += 4;
  }

  void addDouble(double value) {
    buffer.add(Uint8List(8)..buffer.asByteData().setFloat64(0, value, Endian.big));
    _dataSize += 8;
  }

  Uint8List data() {
    final BytesBuilder finalBuffer = BytesBuilder();
    //pattern
    finalBuffer.add([0x03, 0x04, 0x15]);
    //packet number
    finalBuffer.add(Uint8List(4)..buffer.asByteData().setInt32(0, packetNumber(), Endian.little));
    //message id
    finalBuffer.add(Uint8List(4)..buffer.asByteData().setInt32(0, messageId, Endian.little));
    //command
    finalBuffer.add(Uint8List(2)..buffer.asByteData().setInt16(0, command, Endian.little));
    //data size
    finalBuffer.add(Uint8List(4)..buffer.asByteData().setInt32(0, _dataSize, Endian.little));
    //data
    finalBuffer.add(buffer.takeBytes());

    return finalBuffer.takeBytes();
  }

  static int messageNumber() {
    return _messageNumberCounter++;
  }

  static int packetNumber() {
    return _packetNumberCounter++;
  }

  static void resetPacketCounter() {
    _packetNumberCounter = 1;
  }
}