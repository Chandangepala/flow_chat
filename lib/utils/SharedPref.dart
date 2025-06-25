import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  var sharedPref;

  //To set any type of value in shared pref
  Future<void> setSharedPref(String key, dynamic value) async {
    //shared preference instance
    sharedPref ??= await SharedPreferences.getInstance();

    if(value.runtimeType == String) {
      sharedPref.setString(key, value);
    } else if(value.runtimeType == int) {
      sharedPref.setInt(key, value);
    }
    else if(value.runtimeType == bool) {
      sharedPref.setBool(key, value);
    }
    print("setSharedPref::value: $value");
  }

  //To get any type of value from shared pref
  Future<dynamic> getSharedPref(String key) async {
    sharedPref ??= await SharedPreferences.getInstance();
    print("getSharedPref::value: ${sharedPref.get(key)}");
    return sharedPref.get(key);
  }
}