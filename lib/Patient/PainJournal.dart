import 'package:flutter/material.dart';
import 'package:calibRATE/CustomWidgets.dart';
import 'package:intl/intl.dart';

class PainJournal extends StatefulWidget {
  List<PainEntry> entries;
  List<String> periods;
  PainJournal({this.entries, this.periods});
  @override
  PainJournalState createState() => PainJournalState(entries, periods);
}

class PainJournalState extends State<PainJournal> {
  final entries;
  var periods;
  PainJournalState(this.entries, this.periods);
  List<PainEntry> currentEntries;
  String currentPeriod = 'All';

  @override
  void initState() {
    currentEntries = entries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pain Journal'),
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
          children: <Widget>[
            DropdownButton<String>(
              value: currentPeriod,
              icon: const Icon(Icons.arrow_drop_down_outlined),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              onChanged: (String val) {
                setState(() {
                  currentPeriod = val;
                  updateCurrent();
                });
              },
              items: periods.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: currentEntries.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, i) {
                  return Card(
                    child: ListTile(
                      leading: Text(
                        entries[i].painScore.toString(),
                        style: TextStyle(fontWeight: FontWeight.normal, fontSize: 50.0),
                      ),
                      title: Text(
                        '${entries[i].date.month}-${entries[i].date.day}-${entries[i].date.year}, ${entries[i].isWeekly ? 'Weekly' : 'Outlier'}',
                      ),
                      subtitle: Text(
                        entries[i].note,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  updateCurrent() {
    currentEntries = [];
    for (int i = 0; i < entries.length; i++) {
      print(entries.length);
      String period =
          '${DateFormat('MMM').format(entries[i].date)} ${entries[i].date.year.toString()}';
      if (currentPeriod == period)
        currentEntries.add(entries[i]);
    }
  }
}