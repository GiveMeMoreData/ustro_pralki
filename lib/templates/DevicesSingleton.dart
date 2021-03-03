
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


  void useDevice(String deviceId, String userId, Timestamp endTime){
    deviceMap[deviceId].setAvailable(false);
    deviceMap[deviceId].setEndTime(endTime);

    final updateData = {
      "available" : false,
      "current_user_id": userId,
      "end_time" : endTime,
    };
    print("[INFO] Device ${deviceMap[deviceId].name} is now working");

    updateDeviceInFirestore(deviceId, updateData);
  }

  void freeDevice(String deviceId, String userId){
    deviceMap[deviceId].setAvailable(true);
    deviceMap[deviceId].setEndTime(null);

    final updateData = {
      "available" : true,
      "end_time" : null,
      "current_user_id": userId
    };
    print("[INFO] Device ${deviceMap[deviceId].name} freed successfully");

    updateDeviceInFirestore(deviceId, updateData);
  }

  void createDevice(String name, String locationId){
    final deviceData = {
      "name" : name,
      "location": locationId,
      "available": true,
      "enabled": true,
      "current_user_id": null,
      "end_time": null,
      "messaging_task_id": null,
    };
    FirebaseFirestore.instance.collection('devices').add(deviceData);
  }

  void updateDeviceInFirestore(String deviceId, Map<String, dynamic> updateData){
    FirebaseFirestore.instance.collection('devices').doc(deviceId).set(updateData,SetOptions(merge: true));
    print("[INFO] Update for $deviceId send");
  }

  void updateDevicesFromChangesList(List<DocumentChange> deviceChanges){
      for(DocumentChange change in deviceChanges){
        if(change.type == DocumentChangeType.added){
          setDeviceFromDocumentSnapshot(change.doc);
          continue;
        }
        if(change.type == DocumentChangeType.removed){
          deviceMap.remove(change.doc.id);
          continue;
        }
        if(change.type == DocumentChangeType.modified){
          updateDeviceFromDocumentSnapshot(change.doc);
        }
      }
  }

  void updateDeviceFromDocumentSnapshot(DocumentSnapshot deviceChange){
    deviceMap[deviceChange.id].setName(deviceChange.get('name'));
    deviceMap[deviceChange.id].setAvailable(deviceChange.get('available'));
    deviceMap[deviceChange.id].setEnabled(deviceChange.get('enabled'));
    deviceMap[deviceChange.id].setEndTime(deviceChange.get('end_time'));
  }


  void setDeviceFromDocumentSnapshot(DocumentSnapshot newDevice){
    final _timeNow = Timestamp.now().seconds;
    final _deviceEndTime = newDevice.get('end_time');
    if(_deviceEndTime == null || _timeNow<_deviceEndTime.seconds){
      deviceMap.putIfAbsent(newDevice.id, () => Device(
        newDevice.get('name'),
        newDevice.get('enabled'),
        newDevice.get('available'),
        newDevice.get('end_time'),
      ));
    } else {
      deviceMap.putIfAbsent(newDevice.id, () => Device(
        newDevice.get('name'),
        newDevice.get('enabled'),
        true,
        null,
      ));
      updateDeviceInFirestore(
          newDevice.id,
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
      final _deviceEndTime = device.get('end_time');
      if(_deviceEndTime == null || _timeNow<_deviceEndTime.seconds){
        deviceMap.putIfAbsent(device.id, () => Device(
          device.get('name'),
          device.get('enabled'),
          device.get('available'),
          device.get('end_time'),
        ));
      } else {
        deviceMap.putIfAbsent(device.id, () => Device(
          device.get('name'),
          device.get('enabled'),
          true,
          null,
        ));
        updateDeviceInFirestore(
            device.id,
            {
              "available" : true,
              "end_time" : null,
            }
        );
      }
    }
  }

  void restart() {
    deviceMap = {};
  }
}

class DevicesInfoState extends DevicesInfoBase {
  static final DevicesInfoState _instance = DevicesInfoState._internal();

  factory DevicesInfoState() {
    return _instance;
  }

  DevicesInfoState._internal() {
    deviceMap = {};
  }
}