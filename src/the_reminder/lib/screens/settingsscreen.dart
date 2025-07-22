import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:the_reminder/db/settings_helper.dart';
import 'package:the_reminder/widgets/accessible_font_decorator.dart';
import 'package:the_reminder/services/notification_service.dart';
import 'package:the_reminder/model/task_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO: after pressing back button save setting into cache
    return Scaffold(
      appBar: AppBar(title: Text("Settings"),),
      body: Settings(),
    );
  }
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  //TODO:Get these from cache if it exists
  late bool isContrastEnabled =false;
  late double fontSize =1;
  late List<bool> _isSelectedList = [true,false,false];
  late Map settings;
  @override
  void initState() {
    super.initState();
    getSettings();
  } 
  Future<void> getSettings() async {
    var s = await SettingsHelper.readData();
    var selected;
    switch (s["fontSize"]) {
      case 1:
        selected = [true,false,false];
        break;
      case 2:
        selected = [false,true,false];
        break;  
      default:
        selected = [false,false,true];
    }
    setState(() {
      settings = s;
      fontSize = s["fontSize"];
      isContrastEnabled = s["isContrastEnabled"];
      _isSelectedList = selected;
      log(settings.toString());
    });
  }

  Widget _contrastSettings() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Enable  contrast mode"),
          ),
          Switch(value: isContrastEnabled, 
          onChanged: (value){
            setState(() {
              isContrastEnabled=value;
              log(isContrastEnabled.toString());
            });
          }
        )
        ],
      ),
    );
  }
  Widget _fontSettings() {
    return Container(
      //choose between small, medium, large
      child: Column(
        children: [
          Text("Choose font size"),
          Center(
            child: ToggleButtons(
              direction: Axis.vertical,
              onPressed: (value) {
                setState(() {
                          // The button that is tapped is set to true, and the others to false.
                          for (int i = 0; i < 3; i++) {
                            _isSelectedList[i] = i == value;
                          }
                          switch (value) {
                            case 0:
                              setState(() {
                                {fontSize = 1 ;}
                              });
                              break;
                            case 1:
                              setState(() {
                                {fontSize = 2 ;}
                              });
                              break;
                            case 2:
                              setState(() {
                                {fontSize = 4 ;}
                              });
                              break;
                            default:
                          }
                          log("font size selected:$fontSize");
                        });
              },
              isSelected: _isSelectedList,
              children: [
                FontDecorator(Text("small"),fontSize: 1,),
                FontDecorator(Text("medium"),fontSize: 2,),
                FontDecorator(Text("large"),fontSize: 4,),
              ], 
            ),
          ),
        ],
      ),
    );
  }
//Check for accessibility settings and decorate accordingly


  @override
  Widget build(BuildContext context) {
    return FontDecorator(
      ListView(
        children: [
          _contrastSettings(),
          _fontSettings(),
          ElevatedButton(
            onPressed: ()async{
              SettingsHelper.saveData(fontSize, isContrastEnabled);
              log("Settings Saved");
            }, 
            child: Text("Save Settings")
          )
        ],
      ),
      fontSize: fontSize,
    );
  }
}