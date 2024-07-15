import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:calibRATE/CustomWidgets.dart';
import 'package:calibRATE/Setup/PickNotificationTime.dart';
import 'package:calibRATE/Utilities.dart';
import 'package:calibRATE/models/UserInfo.dart';
import 'package:calibRATE/models/ModelProvider.dart';
import 'package:amplify_api/amplify_api.dart';

class DetermineAcceptable extends StatefulWidget {
  int goal;
  DetermineAcceptable({this.goal});

  @override
  DetermineAcceptableState createState() => DetermineAcceptableState(goal);
}

class DetermineAcceptableState extends State<DetermineAcceptable> {
  var goal;
  DetermineAcceptableState(this.goal);
  var acceptable = -1;
  var nextVisible = false;

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
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: 'Step 2. ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black
                    )
                  ),
                  TextSpan(
                    text:
                        'Tap your highest acceptable level of pain. Green is your acceptable pain range and red is your unacceptable pain range.',
                    style: TextStyle(fontSize: 20.0, color: Colors.black)
                  ),
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
                margin: EdgeInsets.fromLTRB(10, 10, 10, 30),
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
                  submitPainScale(context);
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
              primary: i <= acceptable && i > goal
                  ? Colors.green
                  : (i == goal
                      ? Colors.amber
                      : (i < goal ? Colors.grey : Colors.redAccent)),
              padding: EdgeInsets.fromLTRB(10, 25, 10, 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            child: Text('$i', style: TextStyle(fontSize: 40.0)),
            onPressed: () {
              setState(() {
                if (i > widget.goal) {
                  acceptable = i;
                  nextVisible = true;
                }
              });
            }),
      );
    });
    return buttons;
  }

  void submitPainScale(BuildContext context) {
    var alertDialog = AlertDialog(
      title: Text('Please Confirm'),
      content: Text(
          'Your goal pain score is $goal, your acceptable pain range is from $goal to $acceptable, and your unacceptable pain range is from $acceptable to 10.'),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Confirm',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          onPressed: () {
            saveAcceptable();
            Navigator.push(context, MaterialPageRoute(builder: (context) => PickNotificationTime()));
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      }
    );
  }
  saveAcceptable() async {
    try {
      UserInfo user = await Utilities.getUser(await Utilities.getUserEmail());
      String graphQLDocument =
      '''mutation UpdateUserInfo(\$id: String!, \$name: String!, \$email: AWSEmail!, \$doctorEmail: AWSEmail!, \$goalPain: Int!, \$acceptablePain: Int!) {
          updateUserInfo(input: {id: \$id, name: \$name, email: \$email, doctorEmail: \$doctorEmail, goalPain: \$goalPain, acceptablePain: \$acceptablePain}) {
            id
            name
            email
            doctorEmail
            goalPain
            acceptablePain
          }
        }''';
      var variables = {
        "id": user.id,
        "name": user.name,
        "email": user.email,
        "doctorEmail": user.doctorEmail,
        "goalPain": goal,
        "acceptablePain": acceptable
      };
      var request = GraphQLRequest<String>(document: graphQLDocument, variables: variables);
      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;
      var data = response.data;
      print('Mutation result: ' + data);
      Navigator.push(context, MaterialPageRoute(builder: (context) => PickNotificationTime()));
    } catch (e) {
      Utilities.displayAlert('Error', e, context);
    }
  }
}
