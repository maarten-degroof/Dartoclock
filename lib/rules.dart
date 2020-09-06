import 'package:dartoclock/bottomNavigation.dart';
import 'package:flutter/material.dart';

class Item {
  Item({
    this.id,
    this.expandedValue,
    this.headerValue,
  });

  int id;
  String expandedValue;
  String headerValue;
}

class Rules extends StatefulWidget {
  @override
  _RulesState createState() => _RulesState();
}

class _RulesState extends State<Rules> {
  List<Item> itemList;

  @override
  void initState() {
    super.initState();
    itemList = _generateListItems();
  }

  List<Item> _generateListItems() {
    List<Item> rulesList = List();

    rulesList.add(Item(
        id: 0,
        headerValue: 'Classic game',
        expandedValue:
            'This is a classic game. The goal is to end up with a score of 0 left as fast as possible. '
            'You start at a given number which can be edited in the settings,'
            'and each turn you throw three darts. The total thrown score will '
            'be subtracted from the score you still need to throw. \n\nIf you threw '
            'more than you needed, the round is invalid since you need to end '
            'with a score of exactly 0.'));

    rulesList.add(Item(
        id: 1,
        headerValue: 'Countdown game',
        expandedValue:
            'In this game mode the goal is to throw all 20 numbers once. '
            'You start the first round at 20. Once you throw the number 20, '
            'you need to throw 19, going down until they reach 1. '
            '\n\nThe first person to throw 1 and thus the first person to throw '
            'all 20 numbers in order wins the game.\n\nAs an added difficulty you '
            'can choose to end with a bang, where you have to throw the bullseye after you\'ve thrown the 1,'
            ' this makes the finale more difficult.'));

    rulesList.add(Item(
        id: 2,
        headerValue: 'Elimination game',
        expandedValue:
            'In this game mode the goal is to be the last man standing. '
            'Every player gets three darts to get a score as high as possible. '
            'The player that has the lowest score is eliminated. If there are multiple players '
            'with the lowest score, a random player from that group is chosen.\n\n'
            'Continue each round until only one person is left, this is the winner.'));

    return rulesList;
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
          title: Text('Rules'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    'Here you can find all the different game modes and read a bit about them.'
                    ' Tap a game mode to get started.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildPanel(),
                SizedBox(height: 30)
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigation(index: 1),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList.radio(
      animationDuration: Duration(seconds: 1),
      children: itemList.map<ExpansionPanelRadio>((Item item) {
        return ExpansionPanelRadio(
            value: item.id,
            canTapOnHeader: true,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return Container(
                margin: EdgeInsets.only(left: 5, top: 2, bottom: 2),
                child: ListTile(
                  title: Text(item.headerValue),
                ),
              );
            },
            body: Container(
              margin: EdgeInsets.only(left: 5, bottom: 10, right: 5),
              child: ListTile(
                title: Text(item.expandedValue),
              ),
            ));
      }).toList(),
    );
  }
}
