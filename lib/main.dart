import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calibRATE/Doctor/PatientList.dart';
import 'package:calibRATE/Patient/Home.dart';
import 'package:calibRATE/Setup/Login.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:calibRATE/Utilities.dart';
import 'package:calibRATE/amplifyconfiguration.dart';
import 'package:calibRATE/models/ModelProvider.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) async {
    if (!Amplify.isConfigured) {
      await configureAmplify();
    }
    runApp(new calibRATE());
  });
}

Future<void> configureAmplify() async {
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

class calibRATE extends StatelessWidget {
  Widget homePage;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getRootPage(),
      builder: (context, snapshot) {
        if (homePage != null) {
          return new MaterialApp(
            // Read from database if uid in app is doctor or patient and then show either PatientList or Home
            theme: ThemeData(
              // Define the default brightness and colors.
              brightness: Brightness.light,
              primaryColor: Colors.green,

              // Define the default font family.
              fontFamily: 'Raleway',

              // Define the default TextTheme. Use this to specify the default
              // text styling for headlines, titles, bodies of text, and more.
              textTheme: TextTheme(
                headline1: TextStyle(fontSize: 72.0),
                headline6: TextStyle(fontSize: 36.0),
                bodyText2: TextStyle(fontSize: 14.0),
              ),
            ),
            home: homePage,
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
  getRootPage() async {
    Amplify.Auth.signOut();
    // try {
    //   List<UserInfo> user = await Amplify.DataStore.query(UserInfo.classType);
    //   print(user);
    // } catch (e) {
    //   print(e.message);
    // }
    final userEmail = await Utilities.getUserEmail();
    print(userEmail);
    if (userEmail == null)
      homePage = Login();
    else {
    UserInfo user = await Utilities.getUser(userEmail);
    if (user.doctorEmail == 'eshansinghal05@gmail.com')
      homePage = PatientList();
    else
      homePage = Home(user: user, isPatient: true);
    }
    print(homePage);
  }
}
