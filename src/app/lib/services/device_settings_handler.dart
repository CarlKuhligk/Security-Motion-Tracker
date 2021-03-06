// ignore_for_file: prefer_typing_uninitialized_variables
//dart packages
import 'dart:convert';

//project internal services / dependency injection
import 'package:imu_tracker/services/localstorage_service.dart';

class DeviceSettingsHandler {
  var deviceSettings;

  writeNewDeviceSettingsToInternalStorage(message) {
    var _newDeviceSettings = _decodeSettingsMessage(message);
    deviceSettings = _newDeviceSettings;
    String _newDeviceSettingsString = (jsonEncode(deviceSettings));
    LocalStorageService.writeDeviceSettingsToMemory(_newDeviceSettingsString);
  }

  getDeviceSettingsFromMemory() {
    deviceSettings = LocalStorageService.getDeviceSettingsFromMemory();
  }

  _decodeSettingsMessage(message) {
    message.remove("t");
    var newSettingsMessage = message;
    return newSettingsMessage;
  }
}
