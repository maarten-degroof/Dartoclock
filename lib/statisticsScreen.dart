import 'package:charts_flutter/flutter.dart' as charts;
import 'package:countup/countup.dart';
import 'package:dartoclock/BackgroundColorLoader.dart';
import 'package:dartoclock/statistics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pie_chart/pie_chart.dart' as pie;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'bottomNavigation.dart';

const int ANIMATION_DURATION_SECONDS = 3;

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, double> totalGamesMap = Map();
  List<charts.Series> barChartSeriesList;

  String generalBackgroundColor;

  // Vital for identifying our VisibilityDetector when a rebuild occurs.
  final Key visibilityDetectorKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    barChartSeriesList = loadBarChartData();

    generalBackgroundColor = 'Blue';
    loadBackgroundColor(null);
  }

  /// (Re-)Loads the background color
  ///
  /// This method is called by the VisibilityDetector. [info] contains information
  /// regarding the visibility.
  void loadBackgroundColor(VisibilityInfo info) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        generalBackgroundColor =
            prefs.getString('generalBackgroundColor') ?? 'Blue';
      });
    }
  }

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
    return VisibilityDetector(
      key: visibilityDetectorKey,
      onVisibilityChanged: loadBackgroundColor,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: BackgroundColorLoader.getColor(generalBackgroundColor),
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
                    _getGamesStartedAndFinished(),
                    _getGamesBarChart(),
                    _getAllPlayedGamesPieChart(),
                    _getRoundsText(),
                    _getScoreCard(),
                  ],
                ),
              ),
            ),
          ]),
          bottomNavigationBar: BottomNavigation(index: 2),
        ),
      ),
    );
  }

  Widget _getGamesBarChart() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        Container(
          child: Text(
            'Started vs. completed games',
            style: TextStyle(fontSize: 18),
          ),
          padding: EdgeInsets.all(10),
        ),
        Container(
          constraints: BoxConstraints(maxHeight: 200),
          child: Padding(
            padding: EdgeInsets.only(left: 8),
            child: _barChart(),
          ),
        ),
      ]),
    );
  }

  /// Loads the bar chart
  ///
  /// The animation is false now since the bar start position is wrong when
  /// a legend is set.
  Widget _barChart() {
    return charts.BarChart(
      barChartSeriesList,
      animate: false,
      animationDuration: Duration(seconds: ANIMATION_DURATION_SECONDS),
      vertical: true,
      barGroupingType: charts.BarGroupingType.grouped,
      defaultRenderer: charts.BarRendererConfig(
          // symbolRenderer makes sure that the legend has a circle with the color
          symbolRenderer: charts.CircleSymbolRenderer()),
      // This is the legend
      behaviors: [charts.SeriesLegend()],
    );
  }

  static List<charts.Series<Games, String>> loadBarChartData() {
    final startedGameData = [
      new Games('Classic', Statistics.classicGamesStarted.toInt()),
      new Games('Countdown', Statistics.countdownGamesStarted.toInt()),
      new Games('Elimination', Statistics.eliminationGamesStarted.toInt()),
    ];

    final finishedGameData = [
      new Games('Classic', Statistics.classicGamesFinished.toInt()),
      new Games('Countdown', Statistics.countdownGamesFinished.toInt()),
      new Games('Elimination', Statistics.eliminationGamesFinished.toInt()),
    ];

    return [
      new charts.Series<Games, String>(
        id: 'Started games',
        domainFn: (Games games, _) => games.gameMode,
        measureFn: (Games games, _) => games.games,
        data: startedGameData,
      ),
      new charts.Series<Games, String>(
        id: 'Finished games',
        domainFn: (Games games, _) => games.gameMode,
        measureFn: (Games games, _) => games.games,
        data: finishedGameData,
      ),
    ];
  }

  Widget _getGamesStartedAndFinished() {
    return Card(
        elevation: 8,
        margin: EdgeInsets.symmetric(vertical: 10),
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
              duration: Duration(seconds: ANIMATION_DURATION_SECONDS),
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
                duration: Duration(seconds: ANIMATION_DURATION_SECONDS),
                style: TextStyle(fontSize: 26),
                curve: Curves.easeOut,
              ),
            ),
          ],
        ));
  }

  Widget _getAllPlayedGamesPieChart() {
    return Card(
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
          Container(
            constraints: BoxConstraints(maxHeight: 200),
            child: pie.PieChart(
              dataMap: totalGamesMap,
              chartValuesOptions: pie.ChartValuesOptions(
                decimalPlaces: 0,
                showChartValuesInPercentage: false,
                chartValueBackgroundColor: Colors.transparent,
                chartValueStyle: pie.defaultChartValueStyle.copyWith(
                  color: Colors.white60.withOpacity(0.9),
                ),
              ),
              animationDuration: Duration(seconds: ANIMATION_DURATION_SECONDS),
            ),
          ),
        ]));
  }

  Widget _getRoundsText() {
    return SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 8,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Container(
            margin: EdgeInsets.all(10),
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: 'An average game lasts ',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                TextSpan(
                    text: Statistics.getAverageRoundsPlayed().toString(),
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: ' rounds, and in total you\'ve played ',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                TextSpan(
                    text: Statistics.getTotalRoundsPlayed().toInt().toString(),
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
                TextSpan(
                    text: ' rounds.',
                    style: TextStyle(color: Colors.black, fontSize: 18)),
              ]),
            ),
          ),
        ));
  }

  Widget _getScoreCard() {
    return Card(
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
              duration: Duration(seconds: ANIMATION_DURATION_SECONDS),
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
              duration: Duration(seconds: ANIMATION_DURATION_SECONDS),
              style: TextStyle(fontSize: 26),
              curve: Curves.ease,
            ),
          ],
        ));
  }
}

class Games {
  final String gameMode;
  final int games;

  Games(this.gameMode, this.games);
}
