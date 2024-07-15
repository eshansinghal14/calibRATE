import 'package:flutter/material.dart';
import 'package:calibRATE/CustomWidgets.dart';
import 'package:calibRATE/Patient/Home.dart';
import 'package:calibRATE/Utilities.dart';

class Instructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Instructions'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          children: <Widget>[
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: 'While you are using this app, you will be recording your pain at weekly intervals '
                      'in order to create a graph of your pain progression over time. You can also record '
                      'your pain whenever it is atypical and create a note about why you think this change occurred. '
                      'All of this data will be condensed into a graph which you can use to view your progression over time.',
                      style: TextStyle(fontSize: 18.0, color: Colors.black)),
                ],
              ),
            ),
            SizedBox(height: 20,),
            MainButton(
              text: 'Next',
              onClicked: () async {
                final user = await Utilities.getUser(await Utilities.getUserEmail());
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home(user: user, isPatient: true)));
              }
            ),
          ],
        ),
      ),
    );
  }
}