import 'package:flutter/material.dart';
import 'package:calibRATE/CustomWidgets.dart';
import 'package:calibRATE/Doctor/PatientList.dart';
import 'package:calibRATE/Patient/Home.dart';
import 'package:calibRATE/Setup/ResetPassword.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:calibRATE/Utilities.dart';
import 'package:calibRATE/models/ModelProvider.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  FocusNode emailNode = new FocusNode();
  FocusNode passNode = new FocusNode();
  String email;
  String pass;
  bool passHidden = true;
  bool amplifyConfigured = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              width: 200,
              height: 200,
              image: AssetImage('assets/app_icon.png')
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
                  borderSide: BorderSide(color: Theme
                      .of(context)
                      .primaryColor, width: 3),
                ),
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: emailNode.hasFocus ? Theme
                      .of(context)
                      .primaryColor : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.mail,
                  color: Theme
                      .of(context)
                      .primaryColor,
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
            TextField(
              controller: passController,
              focusNode: passNode,
              obscureText: passHidden,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme
                      .of(context)
                      .primaryColor, width: 3),
                ),
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: passNode.hasFocus ? Theme
                      .of(context)
                      .primaryColor : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme
                      .of(context)
                      .primaryColor,
                ),
                suffixIcon: IconButton(
                    icon: passHidden ? Icon(
                      Icons.visibility, color: Colors.grey,) : Icon(
                      Icons.visibility_off, color: Colors.grey,),
                    onPressed: () {
                      setState(() {
                        passHidden = !passHidden;
                      });
                    }
                ),
              ),
              onTap: () {
                setState(() {
                  FocusScope.of(context).requestFocus(passNode);
                });
              },
              onChanged: (String val) async {
                pass = val;
              },
            ),
            SizedBox(height: 20,),
            MainButton(
              text: 'Login',
              onClicked: () async {
                if (email != null && pass != null) {
                  try {
                    SignInResult res = await Amplify.Auth.signIn(
                      username: email,
                      password: pass,
                    );
                    setState(() async {
                      if (res.isSignedIn) {
                        print('asdfsdf');
                        // UserInfo user = (await Amplify.DataStore.query(
                        //     UserInfo.classType,
                        //     where: UserInfo.EMAIL.eq(email)))[0];
                        UserInfo user = await Utilities.getUser(email);
                        if (user.doctorEmail == 'eshansinghal05@gmail.com')
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PatientList()));
                        else
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Home(user: user, isPatient: true)));
                      }
                    });
                  } on UserNotConfirmedException {
                    confirmUser();
                  } catch (e) {
                    if (e.message == 'User is not confirmed.')
                      confirmUser();
                    else
                      Utilities.displayAlert('Error', e.message, context);
                  }
                }
                else
                  Utilities.displayAlert('All Fields not filled in',
                      'Please ensure both the email and password fields are filled in.',
                      context);
              },
            )
          ],
        ),
      ),
    );
  }

  confirmUser() async {
    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: pass,
      );
      setState(() {
        if (res.isSignUpComplete)
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ResetPassword(email: email)));
      });
    } catch (e) {
      Utilities.displayAlert('Error', e.message, context);
    }
  }
}