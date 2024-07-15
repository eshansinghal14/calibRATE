import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:calibRATE/CustomWidgets.dart';
import 'package:calibRATE/Patient/PainJournal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:date_util/date_util.dart';
import 'package:calibRATE/Utilities.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:calibRATE/models/UserInfo.dart';
import 'package:calibRATE/models/ModelProvider.dart';
import 'package:amplify_api/amplify_api.dart';

class Home extends StatefulWidget {
  UserInfo user;
  bool isPatient;
  Home({this.user, this.isPatient});
  @override
  HomeState createState() => HomeState(user, isPatient);
}

class HomeState extends State<Home> {
  final user;
  final isPatient;
  HomeState(this.user, this.isPatient);
  FlutterLocalNotificationsPlugin notification;
  var entriesLoaded = false;
  var segmentVal = 1;
  final Map<int, Widget> segmentTabs = const <int, Widget>{
    0: Text('Weekly'),
    1: Text('Outlier')
  };
  final List<Color> gradientColors = [Colors.red[900], Colors.red[900], Colors.green, Colors.green, Colors.amber, Colors.amber];
  List<double> gradientStops = [];
  int pain;
  String painNote = '';
  List<PainEntry> entries = [];
  List<FlSpot> weeklyPoints = [];
  List<FlSpot> outlierPoints = [];
  var periods = ['All'];
  String currentPeriod = 'All';
  GlobalKey graphKey = GlobalKey();
  final painNoteController = TextEditingController();
  FocusNode painNoteNode = new FocusNode();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: isPatient ? Text('Home') : Text('${user.name}\'s Summary'),
        automaticallyImplyLeading: !isPatient,
      ),
      body: FutureBuilder(
        future: getPainEntries(),
        builder: (context, snapshot) {
          if (entriesLoaded) {
            return Container(
              height: MediaQuery.of(context).size.height,
              color: Theme.of(context).primaryColor,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    entries.length > 0 ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      width: MediaQuery.of(context).size.width - 20,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                'Pain Graph',
                                style: TextStyle(color: Colors.black, fontSize: 36.0),
                              ),
                              Spacer(),
                              DropdownButton<String>(
                                value: currentPeriod,
                                icon: const Icon(Icons.arrow_drop_down_outlined),
                                iconSize: 24,
                                elevation: 24,
                                style: const TextStyle(color: Colors.black),
                                onChanged: (String val) {
                                  setState(() {
                                    currentPeriod = val;
                                  });
                                },
                                items:
                                periods.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          Container(
                            key: graphKey,
                            height: (MediaQuery.of(context).size.width - 20) * 9 / 16,
                            width: MediaQuery.of(context).size.width - 40,
                            child: LineChart(
                              LineChartData(
                                minX: 0,
                                maxX: 4,
                                minY: 0,
                                maxY: 10,
                                lineTouchData: LineTouchData(
                                    touchCallback: (LineTouchResponse touchResponse) {
                                      setState(() {
                                        if (touchResponse.lineBarSpots != null)
                                          showPointInfo(touchResponse.lineBarSpots, touchResponse.touchInput);
                                      });
                                    }
                                ),
                                titlesData: getAxisTitles(),
                                gridData: FlGridData(
                                    show: false,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey[300],
                                        strokeWidth: 2,
                                      );
                                    },
                                    drawVerticalLine: true,
                                    getDrawingVerticalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey[300],
                                        strokeWidth: 2,
                                      );
                                    }
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    bottom: BorderSide(width: 2, color: Colors.grey[300]),
                                    left: BorderSide(width: 2, color: Colors.grey[300]),
                                  ),
                                ),
                                axisTitleData: FlAxisTitleData(
                                  show: false,
                                  leftTitle: AxisTitle(
                                    showTitle: true,
                                    titleText: 'Pain Score',
                                    // textStyle: TextStyle(fontSize: 16.0),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: weeklyPoints,
                                    barWidth: 5,
                                    colors: [Theme.of(context).primaryColor],
                                    belowBarData: BarAreaData(
                                      show: true,
                                      colors: gradientColors.map((color) => color.withOpacity(0.8)).toList(),
                                      gradientColorStops: gradientStops,
                                      gradientFrom: Offset(1,0),
                                      gradientTo: Offset(1,1),
                                    ),
                                  ),
                                  LineChartBarData(
                                    spots: outlierPoints,
                                    barWidth: 0,
                                    colors: [Theme.of(context).primaryColor],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            height: 325,
                            child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Pain Journal',
                                    style: TextStyle(color: Colors.black, fontSize: 30.0),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: weeklyPoints.length + outlierPoints.length,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (context, i) {
                                      PainEntry e = entries[i];
                                      if ('${DateFormat('MMM').format(e.date)} ${e.date.year.toString()}' == currentPeriod || currentPeriod == 'All') {
                                        return Card(
                                          child: ListTile(
                                            leading: Text(
                                              e.painScore.toString(),
                                              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 50.0),
                                            ),
                                            title: Text(
                                              '${e.date.month}-${e.date.day}-${e.date.year}, ${e.isWeekly ? 'Weekly' : 'Outlier'}',
                                            ),
                                            subtitle: Text(
                                              e.note,
                                            ),
                                          ),
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                ),
                                ButtonTheme(
                                  buttonColor: Colors.transparent,
                                  child: ElevatedButton(
                                    child: Text(
                                      'See More',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blue[800],
                                        backgroundColor: Colors.transparent
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.white,
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PainJournal(entries: entries, periods: periods)));
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ) : Container(),
                    isPatient ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                'Record Pain',
                                style: TextStyle(fontSize: 34.0),
                              ),
                              CupertinoSlidingSegmentedControl(
                                groupValue: segmentVal,
                                children: segmentTabs,
                                onValueChanged: (i) {
                                  setState(() {
                                    segmentVal = i;
                                  });
                                },
                              ),
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
                    ) : Container(),
                  ],
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  getBackgroundGradient() async {
    final acceptable = 1 - (user.acceptablePain / 10.0 + 0.05);
    final goal = 1 - (user.goalPain / 10.0 + 0.05);
    gradientStops = [0, acceptable, acceptable, goal, goal, 1];
  }
  addPainEntry() async {
    final formatter = new DateFormat('yyyy-MM-dd');
    // Amplify.DataStore.save(PainData(painScore: pain, isWeekly: segmentVal == 0, date: '${formatter.format(DateTime.now())}', painNote: painNote, userinfoID: user.id));
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
        "isWeekly": segmentVal == 0,
        "date": '${formatter.format(DateTime.now())}',
        "painNote": painNote,
        "userinfoID": user.id
      };
      var request = GraphQLRequest<String>(document: graphQLDocument, variables: variables);
      var operation = Amplify.API.mutate(request: request);
      var response = await operation.response;
      var data = response.data;
      print('Mutation result: ' + data);
    } catch (e) {
      Utilities.displayAlert('Error', '$e', context);
      print('Mutation failed: $e');
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home(user: user, isPatient: isPatient)));
  }

  showPointInfo(List<LineBarSpot> points, PointerEvent event) {
    final RenderBox rb = graphKey.currentContext.findRenderObject();
    final height = rb.size.height;
    final y1 = rb.localToGlobal(Offset.zero).dy;

    for (int i = 0; i < points.length; i++) {
      int pain = (((height - (event.position.dy - y1)) * 11 / height) - 1.4).round();
      print((((height - (event.position.dy - y1)) * 11 / height) - 1.3));
      print(pain);
      if (points[i].y == pain) {
        for (int j = 0; j < entries.length; j++) {
          PainEntry e = entries[j];
          if (((daysFrom(e) / daysFrom(entries[entries.length - 1])) * 4) == points[i].x &&
              e.painScore.toDouble() == points[i].y) {
            var painInfo = AlertDialog(
              content: ListTile(
                leading: Text(
                  e.painScore.toString(),
                  style: TextStyle(fontSize: 50.0, fontWeight: FontWeight.normal),
                ),
                title: Text(
                  '${e.date.month}-${e.date.day}-${e.date.year}, ${e.isWeekly ? 'Weekly' : 'Outlier'}',
                ),
                subtitle: Text(
                  e.note,
                ),
              )
            );

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return painInfo;
              }
            );
          }
        }
      }
    }
  }

  String getMonthAbb(int month) {
    var monthString = month.toString();
    if (monthString.length == 1) monthString = '0$monthString';
    return DateFormat('MMM').format(DateTime.parse('2021-$monthString-06'));
  }

  FlTitlesData getAxisTitles() {
    return FlTitlesData(
      show: true,
      bottomTitles: SideTitles(
        showTitles: true,
        getTextStyles: (value) => TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        getTitles: (value) {
          if (currentPeriod == 'All') {
            int monthDif = ((entries[entries.length - 1].date.month - entries[0].date.month +
                (entries[entries.length - 1].date.year - entries[0].date.year) * 12));
            final month = monthDif ~/ 4;
            if (monthDif == 0) {
              if (value.toInt() == 2) return getMonthAbb(entries[0].date.month);
            }
            else if (monthDif == 1) {
              if (value.toInt() == 1) return getMonthAbb(entries[0].date.month);
              if (value.toInt() == 3) return getMonthAbb(entries[entries.length-1].date.month);
            }
            else if (monthDif == 2) {
              if (value.toInt() == 0) return getMonthAbb(entries[0].date.month);
              if (value.toInt() == 2) return getMonthAbb(entries[0].date.month+1);
              if (value.toInt() == 4) return getMonthAbb(entries[entries.length-1].date.month);
            }
            else if (monthDif == 3) {
              if (value.toInt() == 0) return getMonthAbb(entries[0].date.month);
              if (value.toInt() == 1) return getMonthAbb(entries[0].date.month+1);
              if (value.toInt() == 3) return getMonthAbb(entries[0].date.month+2);
              if (value.toInt() == 4) return getMonthAbb(entries[entries.length-1].date.month);
            }
            else {
              switch (value.toInt()) {
                case 0:
                  return getMonthAbb(entries[0].date.month);
                case 1:
                  return getMonthAbb(((month % 12) + entries[0].date.month).toInt());
                case 2:
                  return getMonthAbb((((month * 2) % 12) + entries[0].date.month).toInt());
                case 3:
                  return getMonthAbb((((month * 3) % 12) + entries[0].date.month).toInt());
                case 4:
                  return getMonthAbb((entries[entries.length-1].date.month).toInt());
              }
            }
          }
          else {
            DateFormat format = new DateFormat('MMM yyyy');
            final date = format.parse(currentPeriod);
            final days = DateUtil().daysInMonth(date.month, date.year);
            switch (value.toInt()) {
              case 0:
                return '1';
              case 1:
                return (days / 4).floor().toString();
              case 2:
                return (days / 2).floor().toString();
              case 3:
                return (days * 3 / 4).floor().toString();
              case 4:
                return days.toString();
            }
          }
          return '';
        },
        margin: 8,
      ),
      leftTitles: SideTitles(
        showTitles: true,
        getTextStyles: (value) => TextStyle(
          color: Colors.grey[400],
          fontSize: 14,
        ),
        getTitles: (value) {
          return '${value.toInt()}';
        },
        margin: 8,
      ),
    );
  }

  getGraphPoints() {
    weeklyPoints = [];
    outlierPoints = [];
    for (int i = 0; i < entries.length; i++) {
      PainEntry e = entries[i];
      String period =
          '${DateFormat('MMM').format(e.date)} ${e.date.year.toString()}';
      if (e.isWeekly) {
        if (currentPeriod == 'All') {
          if (entries.length < 2)
            weeklyPoints.add(FlSpot(2, e.painScore.toDouble()));
          else
            weeklyPoints.add(FlSpot((daysFrom(e) / daysFrom(entries[entries.length - 1])) * 4,
                e.painScore.toDouble()));
        }
        if (currentPeriod == period)
          weeklyPoints.add(FlSpot(((e.date.day / DateUtil().daysInMonth(e.date.month, e.date.year)) * 4)
              .toDouble(), e.painScore.toDouble()));
      }
      else {
        if (currentPeriod == 'All')
          outlierPoints.add(FlSpot((daysFrom(e) / daysFrom(entries[entries.length - 1])) * 4,
              e.painScore.toDouble()));
        if (currentPeriod == period)
          outlierPoints.add(FlSpot(((e.date.day / DateUtil().daysInMonth(e.date.month, e.date.year)) * 4)
              .toDouble(), e.painScore.toDouble()));
      }
    }
  }

  double daysFrom(PainEntry entry) {
    return entries[0].date.difference(entry.date).inDays.toDouble();
  }

  getPainEntries() async {
    // entries = [
    //   PainEntry(5, DateTime.parse('2021-05-06'), 'asdflaskdjfhsdkljvndlkvnsdvk sdv sdv sadv av sdvsd vasv', true),
    //   PainEntry(9, DateTime.parse('2021-05-06'), 'sadvkjsndvlksajndvkljsanvsad vsad vsad vasdv ad', false),
    //   PainEntry(8, DateTime.parse('2021-05-13'), 'asdoasdvjklsadnvasd vsdv sadv sadv asdv ad', true),
    //   PainEntry(2, DateTime.parse('2021-05-20'), '', true),
    //   PainEntry(7, DateTime.parse('2021-05-20'), '', false),
    //   PainEntry(4, DateTime.parse('2021-05-27'), '', true),
    //   PainEntry(10, DateTime.parse('2021-06-23'), '', true),
    //   PainEntry(7, DateTime.parse('2021-07-23'), '', true),
    //   PainEntry(3, DateTime.parse('2021-07-23'), '', false),
    //   PainEntry(10, DateTime.parse('2021-08-23'), '', true),
    //   PainEntry(8, DateTime.parse('2021-09-23'), '', false),
    //   PainEntry(10, DateTime.parse('2021-10-23'), '', true)
    // ];
    // List<PainData> userPain = (await Amplify.DataStore.query(PainData.classType, where: PainData.USERINFOID.eq(user.id)));
    try {
      String graphQLDocument = '''query ListPainDatas {
        listPainDatas(filter: {userinfoID: {eq: "${user.id}"}}) {
          items {
            id
            painScore
            isWeekly
            date
            painNote
            userinfoID
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
      final query = json.decode(data)['listPainDatas']['items'];
      print(query);
      for (int i = 0; i < query.length; i++) {
        PainData p = PainData.fromJson(query[i]);
        PainEntry entry = PainEntry(p.painScore, DateTime.parse(p.date), p.painNote, p.isWeekly);
        if ((entries.firstWhere((e) => (e.date == entry.date && e.painScore == entry.painScore),
            orElse: () => null)) == null) entries.add(entry);
      }
      print(entries);
    } catch (e) {
      Utilities.displayAlert('Error', e.message, context);
      print('$e');
    }
    entries.sort((a, b)=> a.date.compareTo(b.date));
    for (int i = 0; i < entries.length; i++) {
      String period =
          '${DateFormat('MMM').format(entries[i].date)} ${entries[i].date.year.toString()}';
      if (!periods.contains(period)) periods.add(period);
    }
    getGraphPoints();
    getBackgroundGradient();
    entriesLoaded = true;
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
}

