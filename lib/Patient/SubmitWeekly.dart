import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calibRATE/Patient/Home.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:calibRATE/amplifyconfiguration.dart';
import 'package:amplify_api/amplify_api.dart';
import '../CustomWidgets.dart';
import '../Utilities.dart';

class SubmitWeekly extends StatefulWidget {
  @override
  SubmitWeeklyState createState() => SubmitWeeklyState();
}
class SubmitWeeklyState extends State<SubmitWeekly> {

  int pain;
  String painNote = '';
  final painNoteController = TextEditingController();
  FocusNode painNoteNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Weekly Pain'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: configureAmplify(),
        builder: (context, snapshot) {
          if (Amplify.isConfigured) {
            return Container(
              margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Record Pain',
                        style: TextStyle(fontSize: 36.0),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: 'Date: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black)),
                            TextSpan(text: '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year}', style: TextStyle(fontSize: 20.0, color: Colors.grey)),
                          ],
                        ),
                      ),
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
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    obscureText: false,
                    controller: painNoteController,
                    focusNode: painNoteNode,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3),
                      ),
                      labelText: 'Note for Pain Journal (Optional)',
                      labelStyle: TextStyle(
                        color: painNoteNode.hasFocus ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close, color: Colors.grey),
                        onPressed: () {
                          painNoteController.clear();
                          painNote = '';
                        },
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        FocusScope.of(context).requestFocus(painNoteNode);
                      });
                    },
                    onChanged: (String val) async {
                      painNote = val;
                    },
                  ),
                  SizedBox(height: 20,),
                  MainButton(
                    text: 'Record',
                    onClicked: () {
                      addPainEntry();
                    }
                  ),
                ],
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
  addPainEntry() async {
    final formatter = new DateFormat('yyyy-MM-dd');
    final user = (await Utilities.getUser(await Utilities.getUserEmail()));
    final id = user.id;
    print(id);
    try {
      String graphQLDocument =
      '''mutation CreatePainData(\$painScore: Int!, \$isWeekly: Boolean!, \$date: String!, \$painNote: String!, \$userinfoID: ID!) {
          createPainData(input: {painScore: \$painScore, isWeekly: \$isWeekly, date: \$date, painNote: \$painNote, userinfoID: \$userinfoID}) {
            id
            painScore
            isWeekly
            date
            painNote
            userinfoID
          }
        }''';
      var variables = {
        "painScore": pain,
        "isWeekly": true,
        "date": '${formatter.format(DateTime.now())}',
        "painNote": painNote,
        "userinfoID": id
      };
      var request = GraphQLRequest<String>(document: graphQLDocument, variables: variables);
      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;
      var data = response.data;
      print('Mutation result: ' + data);
    } on ApiException catch (e) {
      Utilities.displayAlert('Error', '$e', context);
      print('Mutation failed: $e');
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home(user: user, isPatient: true)));
  }
  List<Widget> buildPainButtons() {
    List<Widget> buttons = List.generate(11, (i) {
      return ButtonTheme(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: pain == i ? Colors.amber : Colors.grey,
            padding: EdgeInsets.fromLTRB(10, 25, 10, 25),
          ),
          child: Text(
              '$i',
              style: TextStyle(fontSize: 40.0)
          ),
          onPressed: () {
            setState(() {
              pain = i;
            });
          }
        ),
      );
    });
    return buttons;
  }
  Future<void> configureAmplify() async {
    if (!Amplify.isConfigured) {
      try {
        Amplify.addPlugins([
          AmplifyAuthCognito(),
          // AmplifyDataStore(modelProvider: ModelProvider.instance),
          AmplifyAPI()
        ]);
        await Amplify.configure(amplifyconfig);
      }
      catch(e) {
        print(e.toString());
      }
    }
  }
}