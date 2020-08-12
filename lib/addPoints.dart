import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPointsScreen extends StatefulWidget {
  final int startScore;
  final String user;
  AddPointsScreen({Key key, this.startScore, this.user}) : super(key: key);

  @override
  _AddPointsScreenState createState() => _AddPointsScreenState(startScore);
}

class _AddPointsScreenState extends State<AddPointsScreen> {
  _AddPointsScreenState(startScore) {
    scoreLeft = startScore;
  }

  final _formKey = GlobalKey<FormState>();
  final _scoreOneController = TextEditingController();
  final _scoreTwoController = TextEditingController();
  final _scoreThreeController = TextEditingController();

  int scoreLeft;

  void countToScoreLeft() {
    int currentScoreLeft = widget.startScore;
    _formKey.currentState.validate();

    /// Field 1
    if (selectedButtonOne[3]) {
      currentScoreLeft -= 50;
    } else if (selectedButtonOne[2]) {
      currentScoreLeft -= 25;
    } else if (_scoreOneController.text.isNotEmpty) {
      int score = int.parse(_scoreOneController.text);
      if (score <= 20) {
        if (selectedButtonOne[0]) {
          currentScoreLeft -= (score * 2);
        } else if (selectedButtonOne[1]) {
          currentScoreLeft -= (score * 3);
        } else {
          currentScoreLeft -= score;
        }
      }
    }

    /// Field 2
    if (selectedButtonTwo[3]) {
      currentScoreLeft -= 50;
    } else if (selectedButtonTwo[2]) {
      currentScoreLeft -= 25;
    } else if (_scoreTwoController.text.isNotEmpty) {
      int score = int.parse(_scoreTwoController.text);
      if (score <= 20) {
        if (selectedButtonTwo[0]) {
          currentScoreLeft -= (score * 2);
        } else if (selectedButtonTwo[1]) {
          currentScoreLeft -= (score * 3);
        } else {
          currentScoreLeft -= score;
        }
      }
    }

    /// Field 3
    if (selectedButtonThree[3]) {
      currentScoreLeft -= 50;
    } else if (selectedButtonThree[2]) {
      currentScoreLeft -= 25;
    } else if (_scoreThreeController.text.isNotEmpty) {
      int score = int.parse(_scoreThreeController.text);
      if (score <= 20) {
        if (selectedButtonThree[0]) {
          currentScoreLeft -= (score * 2);
        } else if (selectedButtonThree[1]) {
          currentScoreLeft -= (score * 3);
        } else {
          currentScoreLeft -= score;
        }
      }
    }

    setState(() {
      scoreLeft = currentScoreLeft;
    });
  }

  final selectedButtonOne = <bool>[false, false, false, false];
  final selectedButtonTwo = <bool>[false, false, false, false];
  final selectedButtonThree = <bool>[false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add points: ' + widget.user),
        ),
        body: ListView(children: [
          Container(
            margin: EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      'Player: ' +
                          widget.user +
                          '\nPoints: ' +
                          widget.startScore.toString() +
                          '\n\nHow much did you throw?',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Form(
                      key: _formKey,
                      child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '1: ',
                                style: TextStyle(fontSize: 18),
                              ),
                              Container(
                                width: 60,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value.isNotEmpty &&
                                        (int.parse(value) <= 0 ||
                                            int.parse(value) > 20)) {
                                      return 'Please fill in a number between 1 and 20';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    countToScoreLeft();
                                  },
                                  controller: _scoreOneController,
                                  inputFormatters: <TextInputFormatter>[
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    new LengthLimitingTextInputFormatter(2)
                                  ],
                                ),
                              ),
                              ToggleButtons(
                                color: Colors.black.withOpacity(0.60),
                                selectedColor: Color(0xFF6200EE),
                                selectedBorderColor: Color(0xFF6200EE),
                                fillColor: Color(0xFF6200EE).withOpacity(0.08),
                                splashColor:
                                    Color(0xFF6200EE).withOpacity(0.12),
                                hoverColor: Color(0xFF6200EE).withOpacity(0.04),
                                borderRadius: BorderRadius.circular(4.0),
                                isSelected: selectedButtonOne,
                                onPressed: (index) {
                                  // Respond to button selection
                                  setState(() {
                                    selectedButtonOne[index] =
                                        !selectedButtonOne[index];
                                    for (int i = 0;
                                        i < selectedButtonOne.length;
                                        i++) {
                                      if (i != index) {
                                        selectedButtonOne[i] = false;
                                      }
                                    }
                                    if (selectedButtonOne[2] ||
                                        selectedButtonOne[3]) {
                                      _scoreOneController.clear();
                                    }
                                    countToScoreLeft();
                                  });
                                },
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('2X'),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('3X'),
                                  ),
                                  Icon(Icons.favorite),
                                  Icon(Icons.notifications)
                                ],
                              )
                            ]),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('2: ', style: TextStyle(fontSize: 18)),
                              Container(
                                width: 60,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value.isNotEmpty &&
                                        (int.parse(value) <= 0 ||
                                            int.parse(value) > 20)) {
                                      return 'Please fill in a number between 1 and 20';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    countToScoreLeft();
                                  },
                                  controller: _scoreTwoController,
                                  inputFormatters: <TextInputFormatter>[
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    new LengthLimitingTextInputFormatter(2)
                                  ],
                                ),
                              ),
                              ToggleButtons(
                                color: Colors.black.withOpacity(0.60),
                                selectedColor: Color(0xFF6200EE),
                                selectedBorderColor: Color(0xFF6200EE),
                                fillColor: Color(0xFF6200EE).withOpacity(0.08),
                                splashColor:
                                    Color(0xFF6200EE).withOpacity(0.12),
                                hoverColor: Color(0xFF6200EE).withOpacity(0.04),
                                borderRadius: BorderRadius.circular(4.0),
                                isSelected: selectedButtonTwo,
                                onPressed: (index) {
                                  // Respond to button selection
                                  setState(() {
                                    selectedButtonTwo[index] =
                                        !selectedButtonTwo[index];
                                    for (int i = 0;
                                        i < selectedButtonTwo.length;
                                        i++) {
                                      if (i != index) {
                                        selectedButtonTwo[i] = false;
                                      }
                                    }
                                    if (selectedButtonTwo[2] ||
                                        selectedButtonTwo[3]) {
                                      _scoreTwoController.clear();
                                    }
                                    countToScoreLeft();
                                  });
                                },
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('2X'),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('3X'),
                                  ),
                                  Icon(Icons.favorite),
                                  Icon(Icons.notifications)
                                ],
                              )
                            ]),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('3: ', style: TextStyle(fontSize: 18)),
                              Container(
                                width: 60,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value.isNotEmpty &&
                                        (int.parse(value) <= 0 ||
                                            int.parse(value) > 20)) {
                                      return 'Please fill in a number between 1 and 20';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    countToScoreLeft();
                                  },
                                  controller: _scoreThreeController,
                                  inputFormatters: <TextInputFormatter>[
                                    WhitelistingTextInputFormatter.digitsOnly,
                                    new LengthLimitingTextInputFormatter(2)
                                  ],
                                ),
                              ),
                              ToggleButtons(
                                color: Colors.black.withOpacity(0.60),
                                selectedColor: Color(0xFF6200EE),
                                selectedBorderColor: Color(0xFF6200EE),
                                fillColor: Color(0xFF6200EE).withOpacity(0.08),
                                splashColor:
                                    Color(0xFF6200EE).withOpacity(0.12),
                                hoverColor: Color(0xFF6200EE).withOpacity(0.04),
                                borderRadius: BorderRadius.circular(4.0),
                                isSelected: selectedButtonThree,
                                onPressed: (index) {
                                  // Respond to button selection
                                  setState(() {
                                    selectedButtonThree[index] =
                                        !selectedButtonThree[index];
                                    for (int i = 0;
                                        i < selectedButtonThree.length;
                                        i++) {
                                      if (i != index) {
                                        selectedButtonThree[i] = false;
                                      }
                                    }
                                    if (selectedButtonThree[2] ||
                                        selectedButtonThree[3]) {
                                      _scoreThreeController.clear();
                                    }
                                    countToScoreLeft();
                                  });
                                },
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('2X'),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text('3X'),
                                  ),
                                  Icon(Icons.favorite),
                                  Icon(Icons.notifications)
                                ],
                              )
                            ]),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                margin: EdgeInsets.all(16),
                                child: Text(
                                  'Score left: ' + scoreLeft.toString(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: scoreLeft >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.all(16),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        OutlineButton(
                                          child: Text('CANCEL'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                        RaisedButton(
                                          color: Theme.of(context).primaryColor,
                                          textColor: Colors.white,
                                          child: Text('CONTINUE'),
                                          onPressed: () {
                                            if (scoreLeft >= 0) {
                                              Navigator.of(context)
                                                  .pop(scoreLeft);
                                            } else {
                                              _showTooFewPointsDialog();
                                            }
                                          },
                                        )
                                      ]))
                            ])
                      ])),
                ]),
          ),
        ]));
  }

  /// This shows the dialog that tells you you filled in more points than you had
  Future<dynamic> _showTooFewPointsDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Bad point count'),
            content: Text(
                'You threw more points than you needed in total, which is not good. Please fill in less points or skip this turn.'),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text('OK'))
            ],
          );
        });
  }
}
