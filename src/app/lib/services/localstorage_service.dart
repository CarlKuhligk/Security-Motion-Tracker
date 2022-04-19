//dart packages
import 'dart:convert';
import 'dart:async' show Future;

//additional packages
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late LocalStorageService _instance;
  static late SharedPreferences _preferences;
  static late var deviceSettings;
  static const String deviceIsSetUpKey = 'deviceIsSetUp';
  static const String authenticationValuesKey = 'AuthenticationValues';
  static const String deviceSettingsValuesKey = 'deviceSettingsValues';

  static Future<LocalStorageService> getInstance() async {
    _instance = LocalStorageService();

    _preferences = await SharedPreferences.getInstance();

    return _instance;
  }

  static void writeAuthenticationToMemory(authenticationValues) {
    _preferences.setString(authenticationValuesKey, authenticationValues);
  }

  static void writeDeviceSettingsToMemory(deviceSettings) {
    _preferences.setString(deviceSettingsValuesKey, deviceSettings);
  }

  static getAuthenticationFromMemory() {
    var _authenticationValues = _preferences.getString(authenticationValuesKey);
    if (_authenticationValues != null) {
      return jsonDecode(_authenticationValues);
    } else {
      return "";
    }
  }

  static getDeviceSettingsFromMemory() {
    var _deviceSettingsValues = _preferences.getString(deviceSettingsValuesKey);
    if (_deviceSettingsValues != null) {
      return jsonDecode(_deviceSettingsValues);
    } else {
      return "";
    }
  }

  static void setDeviceIsRegistered(isRegistered) {
    _preferences.setBool(deviceIsSetUpKey, isRegistered);
  }

  static bool getDeviceIsRegistered() {
    bool _isRegistered = ((_preferences.getBool(deviceIsSetUpKey) ?? true));
    return _isRegistered;
  }
}
