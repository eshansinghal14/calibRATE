import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calibRATE/CustomWidgets.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:calibRATE/Utilities.dart';
import 'package:amplify_api/amplify_api.dart';

class AddPatient extends StatefulWidget {
  @override
  AddPatientState createState() => AddPatientState();
}
class AddPatientState extends State<AddPatient> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  FocusNode emailNode = new FocusNode();
  FocusNode nameNode = new FocusNode();
  String name;
  String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add Patient'),
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
            TextField(
              controller: nameController,
              focusNode: nameNode,
              obscureText: false,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3),
                ),
                labelText: 'Patient\'s Name',
                labelStyle: TextStyle(
                  color: nameNode.hasFocus ? Theme.of(context).primaryColor : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.person_search,
                  color: Theme.of(context).primaryColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () => nameController.clear(),
                ),
              ),
              onTap: () {
                setState(() {
                  FocusScope.of(context).requestFocus(nameNode);
                });
              },
              onChanged: (String val) async {
                name = val;
              },
            ),
            SizedBox(height: 20,),
            TextField(
              controller: emailController,
              focusNode: emailNode,
              obscureText: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3),
                ),
                labelText: 'Patient\'s Email',
                labelStyle: TextStyle(
                  color: emailNode.hasFocus ? Theme.of(context).primaryColor : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.mail,
                  color: Theme.of(context).primaryColor,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey),
                  onPressed: () => emailController.clear(),
                ),
              ),
              onTap: () {
                setState(() {
                  FocusScope.of(context).requestFocus(emailNode);
                });
              },
              onChanged: (String val) async {
                email = val;
              },
            ),
            SizedBox(height: 20,),
            MainButton(
              text: 'Add Patient',
              onClicked: () {
                signUpNewUser();
              }
            ),
          ],
        ),
      ),
    );
  }

  signUpNewUser() async {
    try {
      SignUpResult res = await Amplify.Auth.signUp(
        username: email,
        password: 'llKKJLJKkl34lk4+SA@()*khsbd)(*@&&%lsadfLKHGSFKlaksdjfhasKJJJsk35645328740298745',
        options: CognitoSignUpOptions(
          userAttributes: {'email' : email}
        )
      );

      try {
        String doctorEmail = await Utilities.getUserEmail();
        String graphQLDocument =
        '''mutation CreateUserInfo(\$name: String!, \$email: AWSEmail!, \$doctorEmail: AWSEmail!, \$goalPain: Int!, \$acceptablePain: Int!) {
          createUserInfo(input: {name: \$name, email: \$email, doctorEmail: \$doctorEmail, goalPain: \$goalPain, acceptablePain: \$acceptablePain}) {
            id
            name
            email
            doctorEmail
            goalPain
            acceptablePain
          }
        }''';
        var variables = {
          "name": name,
          "email": email,
          "doctorEmail": doctorEmail,
          "goalPain": -1,
          "acceptablePain": -1
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
      setState(() async {
        // try {
        //   print('starting to add user');
        //   UserInfo newUser = UserInfo(
        //       name: name, email: email, doctorEmail: doctorEmail, goalPain: -1, acceptablePain: -1, userPain: []);
        //   await Amplify.DataStore.save(newUser);
        //   print(newUser.toString());
        //   print('Sign up success');
        //   Navigator.pop(context);
        // } catch (e) {
        //   print(e);
        // }
      });
    } catch (e) {
      print(e.message);
      Utilities.displayAlert('Error', e.message, context);
    }
  }

  // String generateUserPassword() {
  //   String _allowedChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#=+!£\$%&?[](){}';
  //   String _result = "";
  //
  //   for (int i = 0; i < 12; i++) {
  //     int randomInt = Random.secure().nextInt(_allowedChars.length);
  //     _result += _allowedChars[randomInt];
  //   }
  //   return _result;
  // }
}
