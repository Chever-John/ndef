import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import 'package:ndef/records/well_known/well_known.dart';
import 'package:ndef/utilities.dart';

class DataElement {
  late int type;
  late Uint8List value;
  DataElement(this.type, this.value);
  DataElement.fromString(this.type, String valueString) {
    value = utf8.encode(valueString);
  }

  @override
  String toString() {
    var str = "DataElement: ";
    str += "type=$type ";
    str += "value=$value";
    return str;
  }
}

class DeviceInformationRecord extends WellKnownRecord {
  static const String classType = "Di";

  @override
  String get decodedType {
    return DeviceInformationRecord.classType;
  }

  static const int classMinPayloadLength = 2;

  @override
  int get minPayloadLength {
    return classMinPayloadLength;
  }

  @override
  String toString() {
    var str = "DeviceInformationRecord: ";
    str += "vendorName=$vendorName ";
    str += "modelName=$modelName ";
    str += "uniqueName=$uniqueName ";
    str += "uuid=$uuid ";
    str += "version= $versionString ";
    str += "undefined= $undefinedData";
    return str;
  }

  String? vendorName, modelName, uniqueName, versionString;
  late Uint8List uuidData;
  late List<DataElement> undefinedData;

  DeviceInformationRecord(
      {this.vendorName,
      this.modelName,
      this.uniqueName,
      String? uuid,
      this.versionString,
      List<DataElement>? undefinedData}) {
    if (uuid != null) {
      this.uuid = uuid;
    }
    this.undefinedData = undefinedData ?? [];
  }

  String get uuid {
    return Uuid.unparse(uuidData);
  }

  set uuid(String uuid) {
    uuidData = Uint8List.fromList(Uuid.parse(uuid));
  }

  void _addEncodedData(String? value, int type, List<int?> payload) {
    if (value != null) {
      payload.add(type);
      Uint8List valueBytes = utf8.encode(value);
      payload.add(valueBytes.length);
      payload.addAll(valueBytes);
    }
  }

  @override
  Uint8List? get payload {
    if (!(vendorName != null && modelName != null)) {
      throw ArgumentError(
          "Decoding requires the manufacturer and model name TLVs");
    }
    List<int>? payload = [];

    // known data
    _addEncodedData(vendorName, 0, payload);
    _addEncodedData(modelName, 1, payload);
    _addEncodedData(uniqueName, 2, payload);
    payload.add(3);
    payload.add(uuidData.length);
    payload.addAll(uuidData);
    _addEncodedData(versionString, 4, payload);

    // undefined data
    for (int i = 0; i < undefinedData.length; i++) {
      payload.add(undefinedData[i].type);
      Uint8List valueBytes = undefinedData[i].value;
      payload.add(valueBytes.length);
      payload.addAll(valueBytes);
    }
    return Uint8List.fromList(payload);
  }

  @override
  set payload(Uint8List? payload) {
    ByteStream stream = ByteStream(payload!);
    while (!stream.isEnd()) {
      int type = stream.readByte();
      int length = stream.readByte();
      Uint8List value = stream.readBytes(length);
      switch (type) {
        case 0:
          vendorName = utf8.decode(value);
          break;
        case 1:
          modelName = utf8.decode(value);
          break;
        case 2:
          uniqueName = utf8.decode(value);
          break;
        case 3:
          uuidData = value;
          break;
        case 4:
          versionString = utf8.decode(value);
          break;
        default:
          undefinedData.add(DataElement(type, value));
          break;
      }
    }
    if (!(vendorName != null && modelName != null)) {
      throw ArgumentError(
          "Decoding requires the manufacturer and model name TLVs");
    }
  }
}
