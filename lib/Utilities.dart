import 'dart:convert';
import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'models/UserInfo.dart';

class Utilities {
  static void displayAlert(String title, String message, BuildContext context) {
    var alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
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

  static Future<String> getUserEmail() async {
    try {
      await Amplify.Auth.getCurrentUser();
      final userAttributes = (await Amplify.Auth.fetchUserAttributes()).toList();
      for (int i = 0; i < userAttributes.length; i++) {
        if (userAttributes[i].userAttributeKey == 'email')
          return userAttributes[i].value;
      }
    } catch(e) {
      return null;
    }
  }
  static Future<UserInfo> getUser(String email) async {
    try {
      String graphQLDocument = '''query ListUserInfos {
        listUserInfos(filter: {email: {eq: "$email"}}) {
          items {
            id
            name
            email
            doctorEmail
            goalPain
            acceptablePain
          }
          nextToken
        }
      }''';

      var operation = Amplify.API.query(
          request: GraphQLRequest<String>(
            document: graphQLDocument,
          ));
      var response = await operation.response;
      var data = response.data;
      print(data);
      print('Query result: ' + data);
      final query = json.decode(data)['listUserInfos']['items'];
      print(query);
      return UserInfo.fromJson(query[0]);
    } catch (e) {
      print('$e');
    }
  }
  static Future<int> readInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? '';
  }
  static saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }
}