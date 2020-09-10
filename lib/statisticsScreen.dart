import 'package:countup/countup.dart';
import 'package:dartoclock/gameModesEnum.dart';
import 'package:dartoclock/statistics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bottomNavigation.dart';
import 'package:pie_chart/pie_chart.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

/// Sample linear data type.
class TotalGamesPlayedDataType {
  final GameModes gameMode;
  final int games;

  TotalGamesPlayedDataType(this.gameMode, this.games);
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, double> totalGamesMap = Map();

  void _createMap() {
    totalGamesMap.putIfAbsent('Classic', () => Statistics.classicGamesStarted);
    totalGamesMap.putIfAbsent(
        'Countdown', () => Statistics.countdownGamesStarted);
    totalGamesMap.putIfAbsent(
        'Elimination', () => Statistics.eliminationGamesStarted);
  }

  @override
  Widget build(BuildContext context) {
    _createMap();
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
          title: Text('Statistics'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: ListView(children: [
          Center(
            child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                      elevation: 8,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Row(children: [
                            Expanded(
                              child: Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 5),
                                  child: Text(
                                    'Games started',
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                          ]),
                          Countup(
                            begin: 0,
                            end: Statistics.totalStartedGames(),
                            duration: Duration(seconds: 3),
                            style: TextStyle(fontSize: 26),
                            curve: Curves.ease,
                          ),
                          Row(children: [
                            Expanded(
                              child: Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 5),
                                  child: Text(
                                    'Games finished',
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  )),
                            ),
                          ]),
                          Container(
                            margin: EdgeInsets.only(bottom: 5),
                            child: Countup(
                              begin: 0,
                              end: Statistics.totalFinishedGames(),
                              duration: Duration(seconds: 3),
                              style: TextStyle(fontSize: 26),
                              curve: Curves.easeOut,
                            ),
                          ),
                        ],
                      )),
                  Card(
                      elevation: 8,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Column(children: [
                        Container(
                          child: Text(
                            'All your played games',
                            style: TextStyle(fontSize: 18),
                          ),
                          padding: EdgeInsets.all(10),
                        ),
                        PieChart(
                          dataMap: totalGamesMap,
                          chartValuesOptions: ChartValuesOptions(
                            decimalPlaces: 0,
                            showChartValuesInPercentage: false,
                            chartValueBackgroundColor: Colors.transparent,
                            chartValueStyle: defaultChartValueStyle.copyWith(
                              color: Colors.white60.withOpacity(0.9),
                            ),
                          ),
                          animationDuration: Duration(seconds: 3),
                        ),
                      ])),
                  Card(
                      elevation: 8,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: 'An average game lasts ',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18)),
                            TextSpan(
                                text: Statistics.getAverageRoundsPlayed()
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: ' rounds, and in total you\'ve played ',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18)),
                            TextSpan(
                                text: Statistics.getTotalRoundsPlayed()
                                    .toInt()
                                    .toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20)),
                            TextSpan(
                                text: ' rounds.',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18)),
                          ]),
                        ),
                      )),
                  Card(
                      elevation: 8,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                    margin: EdgeInsets.only(top: 10, bottom: 5),
                                    child: Text(
                                      'Total score thrown by you and your friends',
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    )),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.center,
                          ),
                          Countup(
                            begin: 0,
                            end: Statistics.getTotalScoreThrown(),
                            duration: Duration(seconds: 3),
                            style: TextStyle(fontSize: 26),
                            curve: Curves.ease,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                    margin: EdgeInsets.only(top: 10, bottom: 5),
                                    child: Text(
                                      'Players eliminated',
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    )),
                              ),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.center,
                          ),
                          Countup(
                            begin: 0,
                            end: Statistics.getPlayersEliminatedCount(),
                            duration: Duration(seconds: 3),
                            style: TextStyle(fontSize: 26),
                            curve: Curves.ease,
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ]),
        bottomNavigationBar: BottomNavigation(index: 2),
      ),
    );
  }
}
