
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

  void updateDevicesFromChangesList(List<DocumentChange> deviceChanges){
      for(DocumentChange change in deviceChanges){
        if(change.type == DocumentChangeType.added){
          setDeviceFromDocumentSnapshot(change.document);
          continue;
        }
        if(change.type == DocumentChangeType.removed){
          deviceMap.remove(change.document.documentID);
          continue;
        }
        if(change.type == DocumentChangeType.modified){
          updateDeviceFromDocumentSnapshot(change.document);
        }
      }
  }

  void updateDeviceFromDocumentSnapshot(DocumentSnapshot deviceChange){
    deviceMap[deviceChange.documentID].setName(deviceChange['name']);
    deviceMap[deviceChange.documentID].setAvailable(deviceChange['available']);
    deviceMap[deviceChange.documentID].setEnabled(deviceChange['enabled']);
    deviceMap[deviceChange.documentID].setEndTime(deviceChange['end_time']);
  }


  void setDeviceFromDocumentSnapshot(DocumentSnapshot newDevice){
    final _timeNow = Timestamp.now().seconds;
    final _deviceEndTime = newDevice['end_time'];
    if(_deviceEndTime == null || _timeNow<_deviceEndTime.seconds){
      deviceMap.putIfAbsent(newDevice.documentID, () => Device(
        newDevice['name'],
        newDevice['enabled'],
        newDevice['available'],
        newDevice['end_time'],
      ));
    } else {
      deviceMap.putIfAbsent(newDevice.documentID, () => Device(
        newDevice['name'],
        newDevice['enabled'],
        true,
        null,
      ));
      updateDeviceInFirestore(
          newDevice.documentID,
          {
            "available" : true,
            "end_time" : null,
          }
      );
    }
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
