import 'package:flutter/material.dart';

class HistoryWindow extends StatelessWidget {
  HistoryWindow(
      this.user, this.historyList, this.currentScore, this.startScore);

  List historyList;
  String user;
  int currentScore;
  int startScore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History of $user'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Text("History of throws",
                  style: Theme.of(context).textTheme.headline5),
            ),
            Text("$user currently has $currentScore points.",
                style: Theme.of(context).textTheme.headline6),
            Expanded(
              child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: historyList.length,
                  separatorBuilder: (context, index) {
                    return Divider(
                      color: Colors.black,
                      indent: 25,
                      endIndent: 25,
                    );
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(15),
                      child: _generateListItem(index),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  /// Builds the string of each throw in the throw history
  Widget _generateListItem(int index) {
    String text = historyList[index].toString() + ' (-';
    if (index == 0) {
      text += (startScore - historyList[index]).toString();
    } else {
      text += (historyList[index - 1] - historyList[index]).toString();
    }
    text += ')';

    return Center(
        child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
      ),
    ));
  }
}
