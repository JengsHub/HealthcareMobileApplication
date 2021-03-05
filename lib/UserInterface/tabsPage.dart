import 'package:flutter/material.dart';
import 'package:fit3077/ProcessQuery/cholesterol.dart';
import 'package:fit3077/ProcessQuery/bloodPressure.dart';
import 'package:fit3077/ProcessQuery/subject.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Contains tabs to display patients under monitoring.
class TabsPage extends StatefulWidget {

  List<Subject> subjects;

  final _TabsPageState _tabsPageState = _TabsPageState();

  @override
  _TabsPageState createState() => _tabsPageState;

}

class _TabsPageState extends State<TabsPage> {

  num seconds;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async{
      // Contains monitored patients passed from the previous page.
      setState(() {
        Map allMonitoredPatients = ModalRoute.of(context).settings.arguments;
        widget.subjects = [];
        widget.subjects.add(Cholesterol(allMonitoredPatients['Cholesterol']));
        widget.subjects.add(BloodPressure(allMonitoredPatients['BloodPressure']));
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              // Pass the updated list of monitored patients back to the previous page.
              //TO DO
              Navigator.pop(context,
                {'Cholesterol': widget.subjects[0].monitoredPatients, 'Blood Pressure': widget.subjects[1].monitoredPatients});
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(child: Text("Cholesterol")),
              Tab(child: Text("Blood Pressure")),
            ],
          ),
          title: Text("Data Page"),
        ),
          body: Column(
            children: [
              Flexible(
                child: TabBarView(
                  children: <Widget>[
                    widget.subjects == null ? Container() : widget.subjects[0],
                    widget.subjects == null ? Container() : widget.subjects[1],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 150.0,
                      height: 50.0,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.lightGreen[800],
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.lightGreen,
                            ),
                          ),
                          hintText: "Refresh seconds",
                        ),
                        onChanged: (text) {seconds = int.parse(text);},
                      ),
                    ),
                    FloatingActionButton.extended(
                      heroTag: 'updateBtn',
                      label: Text('Update'),
                      icon: Icon(Icons.autorenew),
                      backgroundColor: Colors.lightGreen[800],
                      onPressed: () {
                        for (int i=0; i<widget.subjects.length; i++) {
                          if (widget.subjects[i] != null){
                            widget.subjects[i].setRefreshSeconds(seconds);
                            widget.subjects[i].refreshStateCount += 1;
                            widget.subjects[i].updateRefresh();
                          }
                        }
                        FocusScope.of(context).unfocus();
                        _updateRefreshToast(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  //Toast to show that the refresh second has been updated
  void _updateRefreshToast(BuildContext context){
    Fluttertoast.showToast(
        msg:  "Refresh seconds have been updated.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0
    );
  }

}