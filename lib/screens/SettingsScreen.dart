import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class SettingsScreen extends StatefulWidget{

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>{

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        child: ListView(
          children: [
            ListTile(
              title: Text('Offline Log in'),
              leading: Icon(Icons.key),
              trailing: ToggleSwitch(
                labels: ['On, Off'],
                activeBgColor: [Colors.green, Colors.red],
                onToggle: (index){
                  
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}