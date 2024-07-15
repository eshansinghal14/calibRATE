import 'package:flutter/material.dart';
import 'package:calibRATE/CustomWidgets.dart';
import 'package:calibRATE/Setup/DetermineAcceptable.dart';

class DetermineGoal extends StatefulWidget {
  @override
  DetermineGoalState createState() => DetermineGoalState();
}

class DetermineGoalState extends State<DetermineGoal> {
  var nextVisible = false;
  var goal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text('Pain Calibration'),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Now, we want to see what the pain scale means to you.',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 20,),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: 'Step 1. ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
                  TextSpan(text: 'What is your goal? Gold is used to represent your goal.', style: TextStyle(fontSize: 20.0, color: Colors.black)),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Row(
              children: <Widget>[
                Text(
                  'No Pain',
                  textAlign: TextAlign.left,
                ),
                Spacer(),
                Text(
                  'Most Severe',
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            FittedBox(
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Wrap(
                  spacing: 10,
                  children: buildPainButtons(),
                ),
              )
            ),
            SizedBox(height: 20,),
            Visibility(
              visible: nextVisible,
              child: MainButton(
                text: 'Next',
                onClicked: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetermineAcceptable(goal: goal)));
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildPainButtons() {
    List<Widget> buttons = List.generate(11, (i) {
      return ButtonTheme(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: goal == i ? Colors.amber : Colors.grey,
            padding: EdgeInsets.fromLTRB(10, 25, 10, 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
            child: Text(
              '$i',
              style: TextStyle(fontSize: 40.0)
            ),
            onPressed: () {
              setState(() {
                goal = i;
                nextVisible = true;
              });
            }
        ),
      );
    });
    return buttons;
  }
}
