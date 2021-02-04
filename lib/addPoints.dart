import 'package:dartoclock/gameModesEnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPointsScreen extends StatefulWidget {
  int startScore;
  final String user;
  final int userId;
  final String previousThrowText;
  final GameModes gameMode;

  AddPointsScreen(this.startScore, this.user, this.userId,
      this.previousThrowText, this.gameMode) {
    if (gameMode == GameModes.Elimination) {
      startScore = 10000;
    }
  }

  @override
  _AddPointsScreenState createState() => _AddPointsScreenState();
}

class _AddPointsScreenState extends State<AddPointsScreen>
    with TickerProviderStateMixin {
  AnimationController scaleAnimation;
  final _formKey = GlobalKey<FormState>();
  final _scoreOneController = TextEditingController();
  final _scoreTwoController = TextEditingController();
  final _scoreThreeController = TextEditingController();

  final selectedButtonOne = <bool>[false, false, false, false];
  final selectedButtonTwo = <bool>[false, false, false, false];
  final selectedButtonThree = <bool>[false, false, false, false];

  bool isWindowShowing;
  int scoreLeft;
  int currentThrow;

  @override
  void initState() {
    scaleAnimation = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1100),
        lowerBound: 0.0,
        upperBound: 1.0);
    scaleAnimation.forward();
    super.initState();
    isWindowShowing = true;
    scoreLeft = widget.startScore;
    currentThrow = 0;

    // Put the score at a higher count than can possibly be thrown now so it's always good
    if (widget.gameMode == GameModes.Elimination) {
      scoreLeft = 10000;
    }
  }

  @override
  void dispose() {
    scaleAnimation.dispose();
    _scoreOneController.dispose();
    _scoreTwoController.dispose();
    _scoreThreeController.dispose();
    super.dispose();
  }

  void _countToScoreLeft() {
    int scoreThrown = 0;
    _formKey.currentState.validate();

    /// Field 1
    if (selectedButtonOne[3]) {
      scoreThrown += 50;
    } else if (selectedButtonOne[2]) {
      scoreThrown += 25;
    } else if (_scoreOneController.text.isNotEmpty) {
      int score = int.parse(_scoreOneController.text);
      if (score <= 20) {
        if (selectedButtonOne[0]) {
          scoreThrown += (score * 2);
        } else if (selectedButtonOne[1]) {
          scoreThrown += (score * 3);
        } else {
          scoreThrown += score;
        }
      }
    }

    /// Field 2
    if (selectedButtonTwo[3]) {
      scoreThrown += 50;
    } else if (selectedButtonTwo[2]) {
      scoreThrown += 25;
    } else if (_scoreTwoController.text.isNotEmpty) {
      int score = int.parse(_scoreTwoController.text);
      if (score <= 20) {
        if (selectedButtonTwo[0]) {
          scoreThrown += (score * 2);
        } else if (selectedButtonTwo[1]) {
          scoreThrown += (score * 3);
        } else {
          scoreThrown += score;
        }
      }
    }

    /// Field 3
    if (selectedButtonThree[3]) {
      scoreThrown += 50;
    } else if (selectedButtonThree[2]) {
      scoreThrown += 25;
    } else if (_scoreThreeController.text.isNotEmpty) {
      int score = int.parse(_scoreThreeController.text);
      if (score <= 20) {
        if (selectedButtonThree[0]) {
          scoreThrown += (score * 2);
        } else if (selectedButtonThree[1]) {
          scoreThrown += (score * 3);
        } else {
          scoreThrown += score;
        }
      }
    }

    setState(() {
      currentThrow = scoreThrown;
      scoreLeft = widget.startScore - scoreThrown;
    });
  }

  Widget _buildHero() {
    if (widget.gameMode == GameModes.Classic) {
      return Column(
        children: [
          Hero(
            tag: widget.userId.toString() + '_score',
            child: Material(
              color: Colors.transparent,
              child: Text(
                'Score to throw: ' + widget.startScore.toString(),
                style: TextStyle(
                    fontSize: 18, backgroundColor: Colors.transparent),
              ),
            ),
          ),
          Hero(
            tag: widget.userId.toString() + '_previous_throw',
            child: Material(
              color: Colors.transparent,
              child: Text(
                'Previous throw: ' + widget.previousThrowText,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildHeader() {
    if (widget.gameMode == GameModes.Elimination) {
      return Column(
        children: [
          Text(
              'Throw as high as possible since the person with the lowest score is eliminated.'),
        ],
      );
    }
    return Container();
  }

  /// This function is called when the back button is pressed
  /// It makes sure that the showing variable is set to false so that the animation
  /// is shown properly. Otherwise the throwing look will be on the screen
  /// when the card becomes smaller again.
  Future<bool> _onWillPop() async {
    setState(() {
      isWindowShowing = false;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(children: [
        Hero(
          tag: widget.userId.toString() + "_background",
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            leading: Hero(
              tag: widget.userId.toString() + "_backIcon",
              child: Material(
                color: Colors.transparent,
                type: MaterialType.transparency,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.grey,
                  onPressed: () {
                    setState(() {
                      isWindowShowing = false;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
          body: ListView(children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Hero(
                      tag: widget.userId.toString() + '_user',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          widget.user,
                          style: TextStyle(color: Colors.black, fontSize: 22),
                        ),
                      ),
                    ),
                    _buildHero(),
                    AnimatedOpacity(
                      // AnimatedOpacity takes care of hiding the content when
                      // the back button is pressed.
                      opacity: isWindowShowing ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: FadeTransition(
                          opacity: scaleAnimation,
                          child: ScaleTransition(
                            scale: scaleAnimation,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildHeader(),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    child: Column(children: [
                                      Text(
                                        '\nHow much did you throw?',
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ]),
                                  ),
                                  Form(
                                      key: _formKey,
                                      child: Column(children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '1: ',
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              Container(
                                                width: 60,
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  validator: (value) {
                                                    if (value.isNotEmpty &&
                                                        (int.parse(value) <=
                                                                0 ||
                                                            int.parse(value) >
                                                                20)) {
                                                      return 'Please fill in a number between 1 and 20';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    _countToScoreLeft();
                                                  },
                                                  controller:
                                                      _scoreOneController,
                                                  inputFormatters: <
                                                      TextInputFormatter>[
                                                    WhitelistingTextInputFormatter
                                                        .digitsOnly,
                                                    new LengthLimitingTextInputFormatter(
                                                        2)
                                                  ],
                                                ),
                                              ),
                                              _getScoreButtons(
                                                  selectedButtonOne,
                                                  _scoreOneController),
                                            ]),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('2: ',
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                              Container(
                                                width: 60,
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  validator: (value) {
                                                    if (value.isNotEmpty &&
                                                        (int.parse(value) <=
                                                                0 ||
                                                            int.parse(value) >
                                                                20)) {
                                                      return 'Please fill in a number between 1 and 20';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    _countToScoreLeft();
                                                  },
                                                  controller:
                                                      _scoreTwoController,
                                                  inputFormatters: <
                                                      TextInputFormatter>[
                                                    WhitelistingTextInputFormatter
                                                        .digitsOnly,
                                                    new LengthLimitingTextInputFormatter(
                                                        2)
                                                  ],
                                                ),
                                              ),
                                              _getScoreButtons(
                                                  selectedButtonTwo,
                                                  _scoreTwoController),
                                            ]),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('3: ',
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                              Container(
                                                width: 60,
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  validator: (value) {
                                                    if (value.isNotEmpty &&
                                                        (int.parse(value) <=
                                                                0 ||
                                                            int.parse(value) >
                                                                20)) {
                                                      return 'Please fill in a number between 1 and 20';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (value) {
                                                    _countToScoreLeft();
                                                  },
                                                  controller:
                                                      _scoreThreeController,
                                                  inputFormatters: <
                                                      TextInputFormatter>[
                                                    WhitelistingTextInputFormatter
                                                        .digitsOnly,
                                                    new LengthLimitingTextInputFormatter(
                                                        2)
                                                  ],
                                                ),
                                              ),
                                              _getScoreButtons(
                                                  selectedButtonThree,
                                                  _scoreThreeController),
                                            ]),
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              widget.gameMode ==
                                                      GameModes.Classic
                                                  ? Container(
                                                      margin:
                                                          EdgeInsets.all(16),
                                                      child: Text(
                                                        'Score left: ' +
                                                            scoreLeft
                                                                .toString(),
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: scoreLeft >= 0
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                      ),
                                                    )
                                                  : Text(''),
                                              Text(
                                                  'You threw: ' +
                                                      currentThrow.toString(),
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                  '(The heart icon is currently the bull (25 points) and the bell icon is bullseye (50 points). These icons will be changed in the future.)'),
                                              Container(
                                                  margin: EdgeInsets.all(16),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        OutlineButton(
                                                          child: Text('CANCEL'),
                                                          onPressed: () {
                                                            setState(() {
                                                              isWindowShowing =
                                                                  false;
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        RaisedButton(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          textColor:
                                                              Colors.white,
                                                          child:
                                                              Text('CONTINUE'),
                                                          onPressed: () {
                                                            if (scoreLeft >=
                                                                0) {
                                                              setState(() {
                                                                isWindowShowing =
                                                                    false;
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(
                                                                      currentThrow);
                                                            } else {
                                                              _showTooFewPointsDialog();
                                                            }
                                                          },
                                                        )
                                                      ]))
                                            ])
                                      ])),
                                ]),
                          )),
                    ),
                  ]),
            ),
          ]),
        ),
      ]),
    );
  }

  /// Loads the toggle buttons (2X, 3X, bull and bullseye)
  /// the buttonList is a list of bools saying which button is selected
  /// the scoreController is the TextEditingController which is connected to the
  /// input field of the throw: if bull(seye) is pressed, clears the input field.
  ToggleButtons _getScoreButtons(
      List<bool> buttonList, TextEditingController scoreController) {
    return ToggleButtons(
      color: Colors.black.withOpacity(0.60),
      selectedColor: Color(0xFF6200EE),
      selectedBorderColor: Color(0xFF6200EE),
      fillColor: Color(0xFF6200EE).withOpacity(0.08),
      splashColor: Color(0xFF6200EE).withOpacity(0.12),
      hoverColor: Color(0xFF6200EE).withOpacity(0.04),
      borderRadius: BorderRadius.circular(4.0),
      isSelected: buttonList,
      onPressed: (index) {
        // Respond to button selection
        setState(() {
          buttonList[index] = !buttonList[index];
          for (int i = 0; i < buttonList.length; i++) {
            if (i != index) {
              buttonList[i] = false;
            }
          }
          if (buttonList[2] || buttonList[3]) {
            scoreController.clear();
          }
          _countToScoreLeft();
        });
      },
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('2X'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('3X'),
        ),
        Icon(Icons.favorite),
        Icon(Icons.notifications)
      ],
    );
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
