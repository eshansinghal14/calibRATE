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

import 'package:amplify_datastore_plugin_interface/amplify_datastore_plugin_interface.dart';
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the PainData type in your schema. */
@immutable
class PainData extends Model {
  static const classType = const _PainDataModelType();
  final String id;
  final String userinfoID;
  final int painScore;
  final bool isWeekly;
  final String date;
  final String painNote;

  @override
  getInstanceType() => classType;

  @override
  String getId() {
    return id;
  }

  const PainData._internal(
      {@required this.id,
      this.userinfoID,
      @required this.painScore,
      @required this.isWeekly,
      @required this.date,
      @required this.painNote});

  factory PainData(
      {String id,
      String userinfoID,
      @required int painScore,
      @required bool isWeekly,
      @required String date,
      @required String painNote}) {
    return PainData._internal(
        id: id == null ? UUID.getUUID() : id,
        userinfoID: userinfoID,
        painScore: painScore,
        isWeekly: isWeekly,
        date: date,
        painNote: painNote);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PainData &&
        id == other.id &&
        userinfoID == other.userinfoID &&
        painScore == other.painScore &&
        isWeekly == other.isWeekly &&
        date == other.date &&
        painNote == other.painNote;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("PainData {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("userinfoID=" + "$userinfoID" + ", ");
    buffer.write("painScore=" +
        (painScore != null ? painScore.toString() : "null") +
        ", ");
    buffer.write(
        "isWeekly=" + (isWeekly != null ? isWeekly.toString() : "null") + ", ");
    buffer.write("date=" + "$date" + ", ");
    buffer.write("painNote=" + "$painNote");
    buffer.write("}");

    return buffer.toString();
  }

  PainData copyWith(
      {String id,
      String userinfoID,
      int painScore,
      bool isWeekly,
      String date,
      String painNote}) {
    return PainData(
        id: id ?? this.id,
        userinfoID: userinfoID ?? this.userinfoID,
        painScore: painScore ?? this.painScore,
        isWeekly: isWeekly ?? this.isWeekly,
        date: date ?? this.date,
        painNote: painNote ?? this.painNote);
  }

  PainData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userinfoID = json['userinfoID'],
        painScore = json['painScore'],
        isWeekly = json['isWeekly'],
        date = json['date'],
        painNote = json['painNote'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'userinfoID': userinfoID,
        'painScore': painScore,
        'isWeekly': isWeekly,
        'date': date,
        'painNote': painNote
      };

  static final QueryField ID = QueryField(fieldName: "painData.id");
  static final QueryField USERINFOID = QueryField(fieldName: "userinfoID");
  static final QueryField PAINSCORE = QueryField(fieldName: "painScore");
  static final QueryField ISWEEKLY = QueryField(fieldName: "isWeekly");
  static final QueryField DATE = QueryField(fieldName: "date");
  static final QueryField PAINNOTE = QueryField(fieldName: "painNote");
  static var schema =
      Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "PainData";
    modelSchemaDefinition.pluralName = "PainData";

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
        key: PainData.USERINFOID,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: PainData.PAINSCORE,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.int)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: PainData.ISWEEKLY,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.bool)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: PainData.DATE,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: PainData.PAINNOTE,
        isRequired: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));
  });
}

class _PainDataModelType extends ModelType<PainData> {
  const _PainDataModelType();

  @override
  PainData fromJson(Map<String, dynamic> jsonData) {
    return PainData.fromJson(jsonData);
  }
}
