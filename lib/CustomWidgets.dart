import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const MainButton({
    @required this.text,
    @required this.onClicked,
    Key key,
  }) : super(key: key);

  @override

  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          elevation: 5,
          padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        ),
        onPressed: onClicked
    ),
  );
}

class PainEntry {
  int painScore;
  DateTime date;
  String note;
  bool isWeekly;

  PainEntry(this.painScore, this.date, this.note, this.isWeekly);
}