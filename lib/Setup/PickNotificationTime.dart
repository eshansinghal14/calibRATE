import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:calibRATE/CustomWidgets.dart';
import 'package:calibRATE/Patient/SubmitWeekly.dart';
import 'package:calibRATE/Setup/Instructions.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class PickNotificationTime extends StatefulWidget {
  @override
  PickNotificationTimeState createState() => PickNotificationTimeState();
}

class PickNotificationTimeState extends State<PickNotificationTime> {
  FlutterLocalNotificationsPlugin notification;
  final days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  int day;
  int time;
  var nextVisible = false;

  String _setTime, _setDate;
  String _hour, _minute, _time;
  String dateTime;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 00, minute: 00);
  TextEditingController _timeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _timeController.text = formatDate(
        DateTime(2021, 05, 24, DateTime.now().hour, DateTime.now().minute),
        [hh, ':', nn, '', am]).toString();
    var androidInit = new AndroidInitializationSettings('app_icon');
    var iosInit = new IOSInitializationSettings();
    var initSettings =
    new InitializationSettings(android: androidInit, iOS: iosInit);
    notification = new FlutterLocalNotificationsPlugin();
    notification.initialize(initSettings,
        onSelectNotification: notificationSelected);
    tz.initializeTimeZones();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text('Weekly Notification Selection'),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Column(
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Step 3. ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black)),
                    TextSpan(
                        text:
                            'You will be receiving weekly notifications to record your pain within the app. '
                            'Please select best day of the week and time for you to receive these notification so you can '
                            'stay on top of your pain.',
                        style: TextStyle(fontSize: 18.0, color: Colors.black)),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 350,
                child: Column(
                  children: buildDays(),
                ),
              ),
              InkWell(
                onTap: () {
                  _selectTime(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  child: TextFormField(
                    style: TextStyle(fontSize: 30),
                    textAlign: TextAlign.center,
                    onSaved: (String val) {
                      _setTime = val;
                    },
                    enabled: false,
                    keyboardType: TextInputType.text,
                    controller: _timeController,
                    decoration: InputDecoration(
                        disabledBorder:
                            UnderlineInputBorder(borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.all(0)),
                  ),
                ),
              ),
              Visibility(
                visible: nextVisible,
                child: MainButton(
                    text: 'Next',
                    onClicked: () {
                      submitWeekly(context);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        _time = _hour + ' : ' + _minute;
        _time = formatDate(
            DateTime(2021, 05, 24, selectedTime.hour, selectedTime.minute),
            [hh, ':', nn, " ", am]).toString();
        _timeController.text = _time;
      });
      nextVisible = true;
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
  }

  List<Widget> buildDays() {
    List<Widget> buttons = List.generate(13, (i) {
      if (i % 2 == 1)
        return SizedBox(
          height: 10,
        );
      return SizedBox(
        width: double.infinity,
        height: 40,
        child: ButtonTheme(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: day == i ~/ 2 ? Colors.amber : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  )),
              child: Text('${days[i ~/ 2]}', style: TextStyle(fontSize: 16.0)),
              onPressed: () {
                setState(() {
                  day = i ~/ 2;
                  _selectTime(context);
                });
              }),
        ),
      );
    });
    return buttons;
  }

  void submitWeekly(BuildContext context) {
    var alertDialog = AlertDialog(
      title: Text('Please Confirm'),
      content: Text(
          'You will receive weekly notifications every ${days[day]} at $_time to submit your pain for the week.'),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Confirm',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          onPressed: () {
            showNotification();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Instructions()));
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

  Future showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        'id', 'Submit Pain Score', 'Please submit your pain for this week.',
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var genNotificationDetails =
    new NotificationDetails(android: androidDetails, iOS: iosDetails);

    var now = DateTime.now();
    var st = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);
    final addDays = (day - now.weekday + 7) % 7;
    print(selectedTime.hour);
    print(addDays);
    st.add(new Duration(days: addDays));

    final tzScheduleTime = tz.TZDateTime.from(st, tz.local);
    // final tzScheduleTime = tz.TZDateTime(location, st.year, st.month, st.day, selectedTime.hour, selectedTime.minute);
    print(tzScheduleTime.toString());
    // notification.show(1, 'Submit Pain', 'Weekly Pain Notification', genNotificationDetails);
    notification.zonedSchedule(1, 'Submit Pain', 'Weekly Pain Notification',
        tzScheduleTime, genNotificationDetails,
        payload: 'Submit Weekly Pain',
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
            .absoluteTime,
        androidAllowWhileIdle: true);
  }

  Future notificationSelected(String payload) async {
    if (payload == 'Submit Weekly Pain')
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => SubmitWeekly()));
  }
}
