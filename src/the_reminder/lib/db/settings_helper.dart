import 'package:shared_preferences/shared_preferences.dart';

class SettingsHelper{
  static Future<void> saveData(double fs,bool t) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    await prefs.setDouble('fontSize', fs);
    await prefs.setBool('isContrastEnabled', t);
  }
  static Future<Map> readData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    double? fontSize = prefs.getDouble('fontSize');
    bool? isContrastEnabled = prefs.getBool('isContrastEnabled');
    
    print('fontSize: $fontSize');
    print('isContrastEnabled: $isContrastEnabled');

    if(fontSize==null || isContrastEnabled==null){
      saveData(1, false);
    }
    
    return {
      "fontSize": fontSize ?? 1, 
      "isContrastEnabled": isContrastEnabled ?? false,
    };
  }
}