import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'observer.dart';
import 'subject.dart';
import 'cholesterolTable.dart';
import 'package:fit3077/DataRetrieval/getCholesterol.dart';
import 'cholesterolGraph.dart';


class Cholesterol extends Subject{

  final _CholesterolState _cholesterolState = _CholesterolState();
  // This list will contain a list of {"patientName": name, "patientId": id}
  List monitoredPatients;
  Cholesterol(this.monitoredPatients);

  @override
  _CholesterolState createState() => _cholesterolState;


  @override
  void attachObserver() {
    // Attach observer done below
  }

  @override
  void detachObserver(BuildContext context){
    // Detach observer done below
  }

  @override
  List getState() {
    return _cholesterolState.getState();
  }

  // Invoked by any observer whenever subject's state is changed
  @override
  void updateState() {
    notifyObservers();
  }

  // Invoked whenever refresh seconds are updated
  @override
  void updateRefresh() {
    _cholesterolState.refreshStarter(this.refreshStateCount);
  }

  @override
  void notifyObservers() {
    _cholesterolState.notifyObservers();
  }

}

class _CholesterolState extends State<Cholesterol> with AutomaticKeepAliveClientMixin<Cholesterol>{

  List cholesterolValues;
  List<Observer> observers = [];
  List<bool> observersAvailable = [];
  // String subjectDescription;
  bool disposed = false;
  bool noJsonCall = true;

  @override
  void initState(){
    super.initState();

    Future.delayed(Duration.zero, () async{
      // add this.widget back
      this.observers.add(CholesterolTable(this.widget));
      this.observersAvailable.add(true);
      this.observers.add(CholesterolGraph(this.widget));
      this.observersAvailable.add(true);
    });

  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Container(
          child: Column(
            children: <Widget>[
              FutureBuilder(
                  future: _checkObservers(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Container(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text("Loading...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      );
                    }
                    else{
                      return Flexible(
                        child: ListView.builder(
                          itemCount: snapshot.data,
                          itemBuilder: (BuildContext context, int index){
                            if (this.observersAvailable[index] == true){
                              return this.observers[index];
                            }
                            return Container();
                          },
                        ),
                      );
                    }
                  }
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    child: this.observers.length < 1 || this.observersAvailable[0] == true ? Text('Detach table') : Text('Attach table'),
                    color: Colors.indigo[600],
                    textColor: Colors.white,
                    onPressed: () {
                      if (this.observersAvailable[0] == true) {
                        detachObserver(context, 0);
                      } else {
                        attachObserver(context, 0);
                      }
                      setState(() {});
                    },
                  ),
                  RaisedButton(
                    child: this.observers.length < 2 || this.observersAvailable[1] == true ? Text('Detach graph') : Text('Attach graph'),
                    color: Colors.indigo[600],
                    textColor: Colors.white,
                    onPressed: () {
                      if (this.observersAvailable[1] == true) {
                        detachObserver(context, 1);
                      } else {
                        attachObserver(context, 1);
                      }
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }

  //Load data
  Future<num> _checkObservers() async {
    this.cholesterolValues = await retrieveCholesterolValues();
    // refreshes table if noJsonCall is made
    if(noJsonCall == true){
      noJsonCall = false;
      setState((){});
    }
    refreshStarter(widget.refreshStateCount);
    return this.observers.length;
  }

  // Retrieve data from the fhir database and store into shared preference
  Future<List> retrieveCholesterolValues() async {
    List availableCholesterol = [];

    for (var i=0 ; i < widget.monitoredPatients.length; i++) {
      List inMemory = await _getFromSharedPreference(widget.monitoredPatients[i]['patientId']);
      if (inMemory != null){
        availableCholesterol.add({'Name': widget.monitoredPatients[i]['patientName'],
          'ID': widget.monitoredPatients[i]['patientId'],
          'Cholesterol': inMemory[0],
          'Effective Datetime': inMemory[1]
        });
      }
      else{
        noJsonCall = false;
        GetCholesterol cholesterolValue = GetCholesterol(widget.monitoredPatients[i]['patientId'], 'https://fhir.monash.edu/hapi-fhir-jpaserver/fhir');
        List temp = await cholesterolValue.getParsedJson();

        if (temp.length != 0) {
          availableCholesterol.add({'Name': widget.monitoredPatients[i]['patientName'],
            'ID': widget.monitoredPatients[i]['patientId'],
            'Cholesterol': temp[0].toString(),
            'Effective Datetime': temp[1]
          });
          _updateSharedPreference(widget.monitoredPatients[i]['patientId'], [temp[0].toString(), temp[1]]);
        } else {
          availableCholesterol.add({'Name': widget.monitoredPatients[i]['patientName'],
            'ID': widget.monitoredPatients[i]['patientId'],
            'Cholesterol': 'N/A',
            'Effective Datetime': 'N/A'});
          _updateSharedPreference(widget.monitoredPatients[i]['patientId'], ['N/A', 'N/A']);
        }
      }
    }

    if (availableCholesterol.length == 0) {
      _noCholesterolToast(context);
    }

    return availableCholesterol;
  }

  // Get the value from shared preference using "key"
  Future<List> _getFromSharedPreference(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final cholesterolData = prefs.getStringList("Cholesterol" + patientId);
    return cholesterolData;
  }

  // Update the value of a "key" in the shared preference
  Future<void> _updateSharedPreference(String patientId, List<String> details) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("Cholesterol" + patientId, details);
  }

  // Attach table/graph observer depending on user input
  void attachObserver(BuildContext context, num index) {
    this.observersAvailable[index] = true;
    if (index == 0) {
      this.observers[0] = CholesterolTable(this.widget);
    }
    else {
      this.observers[1] = CholesterolGraph(this.widget);
    }
    _attachToast(context);
    refreshStarter(widget.refreshStateCount);
  }

  // Detach a selected observer
  void detachObserver(BuildContext context, num index){
    this.observersAvailable[index] = false;
    this.observers[index] = null;
    _detachToast(context);
  }

  // Returns the cholesterol values to the observers
  List getState() {
    return this.cholesterolValues;
  }

  // clears shared preference and reset the widget to retrieve the latest data
  void refreshStarter(int stateCount){
    Future.delayed(Duration(seconds: widget.refreshSeconds), () async {
      // clear memory so that new data is retrieved
      if (disposed == false && stateCount == widget.refreshStateCount && observersAvailable[0] == true) {
        final pref = await SharedPreferences.getInstance();
        await pref.clear();
        this.cholesterolValues = await retrieveCholesterolValues();
        notifyObservers();
        refreshStarter(stateCount);
      }
    });

  }

  // Updates every running observer
  void notifyObservers() {
    //for every monitor in list call the update method.
    if (disposed){
      // do nothing
    }
    else{
      for (int i=0; i<observers.length; i++) {
        if (observersAvailable[i] == true) {
          observers[i].updateObserver();
        }
      }
      _refreshToast(context);
    }
  }

  // Toast to show that patient has no cholesterol value stored
  void _noCholesterolToast(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Please select patients with cholesterol records.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // toast to show the observations are updated
  void _refreshToast(BuildContext context){
    Fluttertoast.showToast(
        msg:  "Observations are updated.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0
    );
  }

  //  Toast to show that table has been detached
  void _detachToast(BuildContext context){
    Fluttertoast.showToast(
        msg:  "Display has been detached.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0
    );
  }

  //  Toast to show that table has been attached
  void _attachToast(BuildContext context){
    Fluttertoast.showToast(
        msg:  "Display has been attached.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0
    );
  }

  @override
  void dispose(){
    super.dispose();
    disposed = true;
    this.observers = [];
  }

}
