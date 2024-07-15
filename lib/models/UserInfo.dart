/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// ignore_for_file: public_member_api_docs

import 'ModelProvider.dart';
import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the UserInfo type in your schema. */
@immutable
class UserInfo extends Model {
  static const classType = const _UserInfoModelType();
  final String id;
  final String name;
  final String email;
  final String doctorEmail;
  final int goalPain;
  final int acceptablePain;
  final List<PainData> userPain;

  @override
  getInstanceType() => classType;

  @override
  String getId() {
    return id;
  }

  const UserInfo._internal(
      {@required this.id,
      @required this.name,
      @required this.email,
      @required this.doctorEmail,
      @required this.goalPain,
      @required this.acceptablePain,
      this.userPain});

  factory UserInfo(
      {String id,
      @required String name,
      @required String email,
      @required String doctorEmail,
      @required int goalPain,
      @required int acceptablePain,
      List<PainData> userPain}) {
    return UserInfo._internal(
        id: id == null ? UUID.getUUID() : id,
        name: name,
        email: email,
        doctorEmail: doctorEmail,
        goalPain: goalPain,
        acceptablePain: acceptablePain,
        userPain: userPain != null
            ? List<PainData>.unmodifiable(userPain)
            : userPain);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserInfo &&
        id == other.id &&
        name == other.name &&
        email == other.email &&
        doctorEmail == other.doctorEmail &&
        goalPain == other.goalPain &&
        acceptablePain == other.acceptablePain &&
        DeepCollectionEquality().equals(userPain, other.userPain);
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("UserInfo {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$name" + ", ");
    buffer.write("email=" + "$email" + ", ");
    buffer.write("doctorEmail=" + "$doctorEmail" + ", ");
    buffer.write(
        "goalPain=" + (goalPain != null ? goalPain.toString() : "null") + ", ");
    buffer.write("acceptablePain=" +
        (acceptablePain != null ? acceptablePain.toString() : "null"));
    buffer.write("}");

    return buffer.toString();
  }

  UserInfo copyWith(
      {String id,
      String name,
      String email,
      String doctorEmail,
      int goalPain,
      int acceptablePain,
      List<PainData> userPain}) {
    return UserInfo(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        doctorEmail: doctorEmail ?? this.doctorEmail,
        goalPain: goalPain ?? this.goalPain,
        acceptablePain: acceptablePain ?? this.acceptablePain,
        userPain: userPain ?? this.userPain);
  }

  UserInfo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        email = json['email'],
        doctorEmail = json['doctorEmail'],
        goalPain = json['goalPain'],
        acceptablePain = json['acceptablePain'],
        userPain = json['userPain'] is List
            ? (json['userPain'] as List)
                .map((e) => PainData.fromJson(new Map<String, dynamic>.from(e)))
                .toList()
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'doctorEmail': doctorEmail,
        'goalPain': goalPain,
        'acceptablePain': acceptablePain,
        'userPain': userPain?.map((e) => e?.toJson())?.toList()
      };

  static final QueryField ID = QueryField(fieldName: "userInfo.id");
  static final QueryField NAME = QueryField(fieldName: "name");
  static final QueryField EMAIL = QueryField(fieldName: "email");
  static final QueryField DOCTOREMAIL = QueryField(fieldName: "doctorEmail");
  static final QueryField GOALPAIN = QueryField(fieldName: "goalPain");
  static final QueryField ACCEPTABLEPAIN =
      QueryField(fieldName: "acceptablePain");
  static final QueryField USERPAIN = QueryField(
      fieldName: "userPain",
      fieldType: ModelFieldType(ModelFieldTypeEnum.model,
          ofModelName: (PainData).toString()));
  static var schema =
      Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "UserInfo";
    modelSchemaDefinition.pluralName = "UserInfos";

    modelSchemaDefinition.authRules = [
      AuthRule(authStrategy: AuthStrategy.PUBLIC, operations: [
        ModelOperation.CREATE,
        ModelOperation.UPDATE,
        ModelOperation.DELETE,
        ModelOperation.READ
      ])
    ];

    modelSchemaDefinition.addField(ModelFieldDefinition.id());

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserInfo.NAME,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserInfo.EMAIL,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserInfo.DOCTOREMAIL,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserInfo.GOALPAIN,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.int)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: UserInfo.ACCEPTABLEPAIN,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.int)));

    modelSchemaDefinition.addField(ModelFieldDefinition.hasMany(
        key: UserInfo.USERPAIN,
        isRequired: false,
        ofModelName: (PainData).toString(),
        associatedKey: PainData.USERINFOID));
  });
}

class _UserInfoModelType extends ModelType<UserInfo> {
  const _UserInfoModelType();

  @override
  UserInfo fromJson(Map<String, dynamic> jsonData) {
    return UserInfo.fromJson(jsonData);
  }
}
