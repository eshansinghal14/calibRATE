import 'package:flutter/material.dart';
import 'package:calibRATE/CustomWidgets.dart';
import 'package:calibRATE/Doctor/PatientList.dart';
import 'package:calibRATE/Setup/DetermineGoal.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:calibRATE/Utilities.dart';
import 'package:calibRATE/models/UserInfo.dart';
import 'package:calibRATE/models/ModelProvider.dart';

class ResetPassword extends StatefulWidget {
  String email;
  ResetPassword({this.email});
  @override
  ResetPasswordState createState() => ResetPasswordState(email);
}
class ResetPasswordState extends State<ResetPassword> {
  final email;
  ResetPasswordState(this.email);
  final passController = TextEditingController();
  final rePassController = TextEditingController();
  FocusNode passNode = new FocusNode();
  FocusNode rePassNode = new FocusNode();
  String pass;
  String rePass;
  bool passHidden = true;
  bool rePassHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3),
                ),
                labelText: 'Password',
                labelStyle: TextStyle(
                  color: passNode.hasFocus ? Theme.of(context).primaryColor : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).primaryColor,
                ),
                suffixIcon: IconButton(
                    icon: passHidden ? Icon(Icons.visibility, color: Colors.grey,) : Icon(Icons.visibility_off, color: Colors.grey,),
                    onPressed: () {setState(() {passHidden = !passHidden;});}
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
            TextField(
              controller: rePassController,
              focusNode: rePassNode,
              obscureText: rePassHidden,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3),
                ),
                labelText: 'Confirm Password',
                labelStyle: TextStyle(
                  color: rePassNode.hasFocus ? Theme.of(context).primaryColor : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).primaryColor,
                ),
                suffixIcon: IconButton(
                    icon: rePassHidden ? Icon(Icons.visibility, color: Colors.grey,) : Icon(Icons.visibility_off, color: Colors.grey,),
                    onPressed: () {setState(() {rePassHidden = !rePassHidden;});}
                ),
              ),
              onTap: () {
                setState(() {
                  FocusScope.of(context).requestFocus(rePassNode);
                });
              },
              onChanged: (String val) async {
                rePass = val;
              },
            ),
            SizedBox(height: 20,),
            MainButton(
              text: 'Reset Password',
              onClicked: () {
                if (pass == rePass) {
                  if (pass.length > 7)
                    signIn();
                  else
                    Utilities.displayAlert('Password Insecure', 'Please ensure your password has at least 8 characters.', context);
                }
                else
                  Utilities.displayAlert('Passwords are not the same', 'Please ensure both the passwords you typed in are the same.', context);
              }
            )
          ],
        ),
      ),
    );
  }

  signIn() async {
    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: email,
        password: 'llKKJLJKkl34lk4+SA@()*khsbd)(*@&&%lsadfLKHGSFKlaksdjfhasKJJJsk35645328740298745',
      );
      setState(() {
        if (res.isSignedIn) {
          updatePass();
        }
      });
    } catch (e) {
      Utilities.displayAlert('Error', e.message, context);
    }
  }

  updatePass() async {
    try {
      UpdatePasswordResult res = await Amplify.Auth.updatePassword(
        oldPassword: 'llKKJLJKkl34lk4+SA@()*khsbd)(*@&&%lsadfLKHGSFKlaksdjfhasKJJJsk35645328740298745',
        newPassword: pass,
      );
      setState(() async {
        UserInfo user = await Utilities.getUser(email);
        if (user.doctorEmail == 'eshansinghal05@gmail.com')
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => PatientList()));
        else
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetermineGoal()));
      });
    } catch (e) {
      Utilities.displayAlert('Error', e.message, context);
    }
  }
}