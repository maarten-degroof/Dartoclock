import 'package:dartoclock/gameModesEnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

class AddPointsScreen extends StatefulWidget {
  int startScore;
  final String user;
  final int userId;
  final String previousThrowText;
  final GameModes gameMode;

  AddPointsScreen(this.startScore, this.user, this.userId,
      this.previousThrowText, this.gameMode) {
    // Put the score at a higher count than can possibly be thrown now so it's always good
    if (gameMode == GameModes.Elimination) {
      startScore = 10000;
    }
  }

  @override
  _AddPointsScreenState createState() => _AddPointsScreenState();
}

const MAX_DART_INPUT = 20;

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

  // There's a bool for each input row. True if that row has an invalid input
  final invalidInput = <bool>[false, false, false];

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
  }

  @override
  void dispose() {
    scaleAnimation.dispose();
    _scoreOneController.dispose();
    _scoreTwoController.dispose();
    _scoreThreeController.dispose();
    super.dispose();
  }

  /// Calculates the total thrown value from a given button list and a given text controller
  /// This will check if bull(seye) is thrown. If not it will check if the player
  /// filled in a valid number in the controller (which will be multiplied if one
  /// of those buttons is selected).
  int _calculateRowScore(
      List<bool> buttonList, TextEditingController controller) {
    int scoreThrown = 0;

    // Bullseye
    if (buttonList[3]) {
      scoreThrown = 50;
    }
    // Bull
    else if (buttonList[2]) {
      scoreThrown = 25;
    }
    // Check what the user filled in
    else if (controller.text.isNotEmpty) {
      int score = int.parse(controller.text);
      if (score <= MAX_DART_INPUT) {
        // 2X
        if (buttonList[0]) {
          scoreThrown = (score * 2);
        }
        // 3X
        else if (buttonList[1]) {
          scoreThrown = (score * 3);
        }
        // No button selected
        else {
          scoreThrown = score;
        }
      }
    }
    return scoreThrown;
  }

  void _calculateScoreLeft() {
    int scoreThrown = 0;
    _formKey.currentState.validate();

    scoreThrown += _calculateRowScore(selectedButtonOne, _scoreOneController);
    scoreThrown += _calculateRowScore(selectedButtonTwo, _scoreTwoController);
    scoreThrown +=
        _calculateRowScore(selectedButtonThree, _scoreThreeController);

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
            title: Text(
              'Add throw',
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            leading: Hero(
              tag: widget.userId.toString() + "_backIcon",
              child: Material(
                color: Colors.transparent,
                type: MaterialType.transparency,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.grey,
                  onPressed: () {
                    _returnToPreviousScreen();
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
                      duration: Duration(milliseconds: 10),
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
                                        _getInputRow(1, _scoreOneController,
                                            selectedButtonOne),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        _getInputRow(2, _scoreTwoController,
                                            selectedButtonTwo),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        _getInputRow(3, _scoreThreeController,
                                            selectedButtonThree),
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
                                                            _returnToPreviousScreen();
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
                                                              if (invalidInput
                                                                  .contains(
                                                                      true)) {
                                                                _showInvalidPointsDialog()
                                                                    .then(
                                                                        (value) {
                                                                  if (value) {
                                                                    _returnToPreviousScreen(
                                                                        scoreThrown:
                                                                            currentThrow);
                                                                  }
                                                                });
                                                              } else {
                                                                _returnToPreviousScreen(
                                                                    scoreThrown:
                                                                        currentThrow);
                                                              }
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

  /// Sets the windowShowing to false so the content of this screen is hidden
  /// when the back animation starts.
  /// Pops the window to go back to the game. Gives the current throw with it.
  void _returnToPreviousScreen({int scoreThrown}) {
    setState(() {
      isWindowShowing = false;
    });
    if (scoreThrown == null) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop(scoreThrown);
    }
  }

  /// Loads the input row (the input field + the buttons)
  /// the controller is the TextEditingController which is connected to the
  /// input field of the throw: it is used to calculate the total score
  /// the buttonList is a list of booleans saying which button is selected
  Column _getInputRow(
      int id, TextEditingController controller, List<bool> buttonList) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$id: ', style: TextStyle(fontSize: 18)),
        Container(
          width: 60,
          child: TextFormField(
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isNotEmpty &&
                  (int.parse(value) < 0 || int.parse(value) > MAX_DART_INPUT)) {
                setState(() {
                  invalidInput[id - 1] = true;
                });
              } else {
                setState(() {
                  invalidInput[id - 1] = false;
                });
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                // Unset the bull(seye) buttons when something is typed
                buttonList[2] = false;
                buttonList[3] = false;
              });
              _calculateScoreLeft();
            },
            controller: controller,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              new LengthLimitingTextInputFormatter(2)
            ],
          ),
        ),
        _getScoreButtons(buttonList, controller),
      ]),
      (invalidInput[id - 1])
          ? Padding(
              padding: EdgeInsets.all(5),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.red, fontSize: 12),
                  children: [
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                    TextSpan(text: 'This score is not possible'),
                  ],
                ),
              ),
            )
          : Container()
    ]);
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
          _calculateScoreLeft();
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
    return showAnimatedDialog(
        animationType: DialogTransitionType.size,
        curve: Curves.easeInOut,
        duration: Duration(seconds: 1),
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return ClassicGeneralDialogWidget(
            titleText: 'Bad point count',
            contentText:
                'You threw more points than you needed in total, which is bad. '
                'Please fill in less points or skip this turn.',
            actions: <Widget>[
              new FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text('OK'))
            ],
          );
        });
  }

  /// This shows the dialog that tells you you filled in more points than you had
  Future<dynamic> _showInvalidPointsDialog() {
    return showAnimatedDialog(
        animationType: DialogTransitionType.size,
        curve: Curves.easeInOut,
        duration: Duration(seconds: 1),
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return ClassicGeneralDialogWidget(
            titleText: 'Invalid input',
            contentText:
                'You filled in scores that won\'t be counted. These values won\'t '
                'be used. Are you sure you want to continue?',
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: new Text('Continue')),
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: new Text('Cancel'))
            ],
          );
        });
  }
}
