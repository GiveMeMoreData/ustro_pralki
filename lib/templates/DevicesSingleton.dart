
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Device{

  @protected
  String name;
  @protected
  bool enabled;
  @protected
  bool available;
  @protected
  Timestamp endTime;



  void setName(String newName) {
    name = newName;
  }
  void setEnabled(bool newEnabled) {
    enabled = newEnabled;
  }
  void setAvailable(bool newAvailable) {
    available = newAvailable;
  }
  void setEndTime(Timestamp newEndTime) {
    endTime = newEndTime;
  }

  Device(this.name, this.enabled, this.available, this.endTime);
}


abstract class DevicesInfoBase{

  @protected
  Map<String,Device> deviceMap;


  @protected
  Map<String,Device> initialDeviceMap;

  void useDevice(String deviceId, Timestamp endTime){
    deviceMap[deviceId].setAvailable(false);
    deviceMap[deviceId].setEndTime(endTime);

    final updateData = {
      "available" : false,
      "end_time" : endTime,
    };
    print("[INFO] Device ${deviceMap[deviceId].name} is now working");

    updateDeviceInFirestore(deviceId, updateData);
  }

  void freeDevice(String deviceId){
    deviceMap[deviceId].setAvailable(true);
    deviceMap[deviceId].setEndTime(null);

    final updateData = {
      "available" : true,
      "end_time" : null,
    };
    print("[INFO] Device ${deviceMap[deviceId].name} freed successfully");

    updateDeviceInFirestore(deviceId, updateData);
  }

  void updateDeviceInFirestore(String deviceId, Map<String, dynamic> updateData){
    Firestore.instance.collection('devices').document(deviceId).setData(updateData, merge: true);
    print("[INFO] Update for $deviceId send");
  }

  void setDeviceListFromDocumentSnapshotList(List<DocumentSnapshot> newDeviceList) {
    final _timeNow = Timestamp.now().seconds;
    for(DocumentSnapshot device in newDeviceList){
      final _deviceEndTime = device['end_time'];
      if(_deviceEndTime == null || _timeNow<_deviceEndTime.seconds){
        deviceMap.putIfAbsent(device.documentID, () => Device(
          device['name'],
          device['enabled'],
          device['available'],
          device['end_time'],
        ));
      } else {
        deviceMap.putIfAbsent(device.documentID, () => Device(
          device['name'],
          device['enabled'],
          true,
          null,
        ));
        updateDeviceInFirestore(
            device.documentID,
            {
              "available" : true,
              "end_time" : null,
            }
        );
      }
    }
  }

  void restart() {
    deviceMap = initialDeviceMap;
  }
}

class DevicesInfoState extends DevicesInfoBase {
  static final DevicesInfoState _instance = DevicesInfoState._internal();

  factory DevicesInfoState() {
    return _instance;
  }

  DevicesInfoState._internal() {
    initialDeviceMap = {};
    deviceMap = initialDeviceMap;
  }
}
