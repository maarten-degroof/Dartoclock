import 'package:dartoclock/BackgroundColorLoader.dart';
import 'package:dartoclock/customIcons.dart';
import 'package:dartoclock/statistics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  bool shouldThrowBullseyeCountdown;
  String version;

  String generalBackgroundColor;
  String gameBackgroundColor;

  // the DropdownColor variables are the actual variables in the dropdown buttons
  String generalDropdownColor;
  String gameDropdownColor;

  Future<void> getSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      classicPoints = prefs.getInt('classicPoints') ?? 360;
      _classicTextFieldController.text = classicPoints.toString();

      shouldThrowBullseyeCountdown =
          prefs.getBool('shouldThrowBullseyeCountdown') ?? false;

      generalBackgroundColor =
          prefs.getString('generalBackgroundColor') ?? 'Blue';
      generalDropdownColor = generalBackgroundColor;
      gameBackgroundColor = prefs.getString('gameBackgroundColor') ?? 'Red';
      gameDropdownColor = gameBackgroundColor;
    });
  }

  Future<void> setSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('classicPoints', classicPoints);
    prefs.setBool('shouldThrowBullseyeCountdown', shouldThrowBullseyeCountdown);

    prefs.setString('generalBackgroundColor', generalBackgroundColor);
    prefs.setString('gameBackgroundColor', gameBackgroundColor);
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
    shouldThrowBullseyeCountdown = false;

    generalBackgroundColor = 'Blue';
    generalDropdownColor = generalBackgroundColor;
    gameBackgroundColor = 'Red';
    gameDropdownColor = gameBackgroundColor;

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
              colors: BackgroundColorLoader.getColor(generalBackgroundColor))),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: SettingsList(
          contentPadding: EdgeInsets.only(top: 10),
          sections: [
            SettingsSection(title: 'Classic game', tiles: [
              SettingsTile(
                title: 'Score to reach',
                subtitleMaxLines: 10,
                subtitle: 'What is the score you want to start with? '
                    'Changing this value will only affect future games. '
                    'Default: 360. Currently: $classicPoints.',
                leading: Icon(Icons.score),
                onPressed: (context) {
                  setState(() {
                    _classicTextFieldController.text = classicPoints.toString();
                  });
                  return showAnimatedDialog(
                      animationType: DialogTransitionType.size,
                      curve: Curves.easeInOut,
                      duration: Duration(seconds: 1),
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return CustomDialogWidget(
                          title: Text('Classic start number'),
                          content: TextField(
                            keyboardType: TextInputType.number,
                            controller: _classicTextFieldController,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4)
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('CANCEL'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('SAVE'),
                              onPressed: () {
                                if (_classicTextFieldController.text.length >
                                        0 &&
                                    int.parse(
                                            _classicTextFieldController.text) >
                                        0) {
                                  setState(() {
                                    classicPoints = int.parse(
                                        _classicTextFieldController.text);
                                    setSharedPrefs();
                                  });
                                }
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      });
                },
              )
            ]),
            SettingsSection(
              title: 'Countdown game',
              tiles: [
                SettingsTile.switchTile(
                    title: 'End with a bang',
                    subtitleMaxLines: 5,
                    subtitle:
                        'Extra difficulty: after throwing the 1 you win by throwing bullseye.',
                    leading: Icon(Icons.notifications),
                    onToggle: (value) {
                      setState(() {
                        shouldThrowBullseyeCountdown = value;
                      });
                      setSharedPrefs();
                    },
                    switchValue: shouldThrowBullseyeCountdown)
              ],
            ),
            SettingsSection(
              title: 'Colors',
              tiles: [
                SettingsTile(
                  title: 'General color',
                  subtitleMaxLines: 5,
                  subtitle:
                      'Change the general color scheme. Default: Blue. Currently: $generalBackgroundColor.',
                  leading: Icon(Icons.color_lens_rounded),
                  onPressed: (context) {
                    setState(() {
                      generalDropdownColor = generalBackgroundColor;
                    });
                    return showAnimatedDialog(
                        animationType: DialogTransitionType.size,
                        curve: Curves.easeInOut,
                        duration: Duration(seconds: 1),
                        barrierDismissible: true,
                        context: context,
                        builder: (context) {
                          return CustomDialogWidget(
                            title: Text('General color'),
                            content: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Wrap(children: [
                                Text(
                                    'Change the color of the start screen, rules, '
                                    'statistics and settings screens.'),
                                Center(
                                  child: DropdownButton<String>(
                                      value: generalDropdownColor,
                                      onChanged: (newValue) {
                                        setState(() {
                                          generalDropdownColor = newValue;
                                        });
                                      },
                                      items: BackgroundColorLoader
                                              .getColorNamesList()
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList()),
                                ),
                              ]);
                            }),
                            actions: <Widget>[
                              TextButton(
                                child: Text('CANCEL'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('SAVE'),
                                onPressed: () {
                                  setState(() {
                                    generalBackgroundColor =
                                        generalDropdownColor;
                                    setSharedPrefs();
                                  });
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
                SettingsTile(
                  title: 'Game color',
                  subtitleMaxLines: 5,
                  subtitle:
                      'Change the game color scheme. Default: Red. Currently: $gameBackgroundColor.',
                  leading: Icon(Icons.color_lens_rounded),
                  onPressed: (context) {
                    setState(() {
                      gameDropdownColor = gameBackgroundColor;
                    });
                    return showAnimatedDialog(
                        animationType: DialogTransitionType.size,
                        curve: Curves.easeInOut,
                        duration: Duration(seconds: 1),
                        barrierDismissible: true,
                        context: context,
                        builder: (context) {
                          return CustomDialogWidget(
                            title: Text('Game color'),
                            content: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Wrap(children: [
                                Text('Change the color of the game screen.'),
                                Center(
                                  child: DropdownButton<String>(
                                      value: gameDropdownColor,
                                      onChanged: (newValue) {
                                        setState(() {
                                          gameDropdownColor = newValue;
                                        });
                                      },
                                      items: BackgroundColorLoader
                                              .getColorNamesList()
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList()),
                                ),
                              ]);
                            }),
                            actions: <Widget>[
                              TextButton(
                                child: Text('CANCEL'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('SAVE'),
                                onPressed: () {
                                  setState(() {
                                    gameBackgroundColor = gameDropdownColor;
                                    setSharedPrefs();
                                  });
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'General settings',
              tiles: [
                SettingsTile(
                  title: 'GitHub',
                  subtitleMaxLines: 5,
                  subtitle: 'Go to the GitHub-page to find the latest release.',
                  leading: Icon(CustomIcons.github_mark),
                  onPressed: (context) {
                    _launchGithub();
                  },
                ),
                SettingsTile(
                  title: 'Version',
                  subtitle: version,
                  leading: Icon(Icons.info),
                ),
                SettingsTile(
                  title: 'Reset statistics',
                  subtitleMaxLines: 5,
                  subtitle:
                      'This resets all the statistics back to zero so you can start over.',
                  leading: Icon(Icons.undo),
                  onPressed: (context) {
                    return showAnimatedDialog(
                        animationType: DialogTransitionType.size,
                        curve: Curves.easeInOut,
                        duration: Duration(seconds: 1),
                        barrierDismissible: true,
                        context: context,
                        builder: (context) {
                          return ClassicGeneralDialogWidget(
                            titleText: 'Reset statistics',
                            contentText:
                                'Are you sure you want to reset all your statistics back to zero?',
                            actions: <Widget>[
                              TextButton(
                                child: Text('CANCEL'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('RESET'),
                                onPressed: () {
                                  Statistics.resetStatistics();
                                  Fluttertoast.showToast(
                                    msg: 'Statistics are reset',
                                    toastLength: Toast.LENGTH_SHORT,
                                  );
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  },
                ),
              ],
            )
          ],
        ),
        bottomNavigationBar: BottomNavigation(index: 3),
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
