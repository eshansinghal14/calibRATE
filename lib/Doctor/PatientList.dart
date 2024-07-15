import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:calibRATE/Doctor/AddPatient.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:calibRATE/Patient/Home.dart';
import 'package:calibRATE/Utilities.dart';
import 'package:calibRATE/models/ModelProvider.dart';
import 'package:amplify_api/amplify_api.dart';

class PatientList extends StatefulWidget {
  @override
  PatientListState createState() => PatientListState();
}
class PatientListState extends State<PatientList> {
  List<UserInfo> patients = [];
  var loadedPatients = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient List'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              // Amplify.DataStore.delete(patients[0]);
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddPatient()));
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: getPatients(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Utilities.displayAlert('Error', snapshot.error.toString(), context);
          }
          else if (loadedPatients) {
            return Container(
              margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
              child: Expanded(
                child: ListView.builder(
                  itemCount: patients.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, i) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          patients[i].name,
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Home(user: patients[i], isPatient: false)));
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  getPatients() async {
    try {
      var doctorEmail = await Utilities.getUserEmail();
      String graphQLDocument = '''query ListUserInfos {
        listUserInfos(filter: {doctorEmail: {eq: "$doctorEmail"}}) {
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
      print('Query result: ' + data);
      final query = json.decode(data)['listUserInfos']['items'];
      print(query);
      for (int i = 0; i < query.length; i++) {
        UserInfo user = UserInfo.fromJson(query[i]);
        if (!patients.contains(user)) patients.add(user);
        patients.add(UserInfo.fromJson(query[i]));
      }
      print(patients);
      // for (int i = 1; i < patients.length; i++) {
      //   String graphQLDocument = '''mutation deleteUserInfo(\$id: ID!) {
      //     deleteUserInfo(input: {id: \$id}) {
      //       id
      //       name
      //       email
      //       doctorEmail
      //       goalPain
      //       acceptablePain
      //     }
      //   }''';
      //   print(patients[i].id);
      //   var operation = Amplify.API.mutate(
      //       request: GraphQLRequest<String>(document: graphQLDocument, variables: {
      //         'id': patients[i].id
      //       }));
      //   var response = await operation.response;
      //   print(response.data);
      // }
    } catch (e) {
      Utilities.displayAlert('Error', e.message, context);
      print('$e');
    }
    // try {
    //   patients = await Amplify.DataStore.query(UserInfo.classType, where: UserInfo.DOCTOREMAIL.eq(await Utilities.getUserEmail()));
    // } on DataStoreException catch (e) {
    //   Utilities.displayAlert('Error', e.message, context);
    // }
    loadedPatients = true;
  }
}