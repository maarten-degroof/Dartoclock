import 'package:dartoclock/customIcons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bottomNavigation.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _classicTextFieldController = TextEditingController();
  int classicPoints;
  String version;

  Future<void> getSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      classicPoints = prefs.getInt('classicPoints') ?? 360;
      _classicTextFieldController.text = classicPoints.toString();
    });
  }

  Future<void> setSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('classicPoints', classicPoints);
  }

  Future<void> setVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  void initState() {
    super.initState();
    classicPoints = 0;
    getSharedPrefs();
    setVersionNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Color.fromRGBO(77, 85, 225, 1.0),
              Color.fromRGBO(93, 167, 231, 1.0),
            ],
          )),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: Container(
          margin: EdgeInsets.only(top: 10, bottom: 10),
          child: SettingsList(
            //backgroundColor: Colors.transparent,
            sections: [
              SettingsSection(title: 'Classic game', tiles: [
                SettingsTile(
                  title: 'Score to reach',
                  subtitle: 'What is the score you want to start with? '
                      'Changing this value will only affect future games. '
                      'Default: 360. Currently: $classicPoints.',
                  leading: Icon(Icons.score),
                  onTap: () {
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Classic start number'),
                            content: TextField(
                              keyboardType: TextInputType.number,
                              controller: _classicTextFieldController,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly,
                                new LengthLimitingTextInputFormatter(4)
                              ],
                            ),
                            actions: <Widget>[
                              new FlatButton(
                                child: new Text('SAVE'),
                                onPressed: () {
                                  if (_classicTextFieldController.text.length > 0 &&
                                      int.parse(_classicTextFieldController.text) >
                                          0) {
                                    setState(() {
                                      classicPoints = int.parse(
                                          _classicTextFieldController.text);
                                      setSharedPrefs();
                                    });
                                    Navigator.of(context).pop();
                                  } else {
                                    setState(() {
                                      _classicTextFieldController.text =
                                          classicPoints.toString();
                                    });
                                    Navigator.of(context).pop();
                                  }
                                },
                              )
                            ],
                          );
                        });
                  },
                )
              ]),
              SettingsSection(
                title: 'General settings',
                tiles: [
                  SettingsTile(
                    title: 'GitHub',
                    subtitle: 'Go to the GitHub-page to find the latest release.',
                    leading: Icon(CustomIcons.github_mark),
                    onTap: () {
                      _launchGithub();
                    },
                  ),
                  SettingsTile(
                    title: 'Version',
                    subtitle: version,
                    leading: Icon(Icons.info),
                  )
                ],
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigation(index: 2),
      ),
    );
  }

  void _launchGithub() async {
    const url = 'https://github.com/maarten-degroof/Dartoclock';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
