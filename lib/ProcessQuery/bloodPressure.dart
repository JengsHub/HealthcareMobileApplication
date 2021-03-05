import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'observer.dart';
import 'subject.dart';
import 'bloodPressureTable.dart';
import 'package:fit3077/DataRetrieval/getBloodPressure.dart';
import 'bloodPressureText.dart';
import 'bloodPressureGraph.dart';

class BloodPressure extends Subject {

  final _BloodPressureState _bloodPressureState = _BloodPressureState();
  List monitoredPatients;

  // A list of boolean corresponding to the number of monitored patients.
  // The elements are set to true if the corresponding patients are chosen for
  // latest observations display and their systolic values are higher than the
  // specified threshold value.
  List<bool> chosenForLatestDisplay = [];

  BloodPressure(List patients){
    this.monitoredPatients = patients;
    // Resets the list of patients that are selected for additional display
    resetChosen();
  }

  // Creating an instance of the widget class _BloodPressureState
  // to invoke its methods from parent
  @override
  _BloodPressureState createState() => _bloodPressureState;

  @override
  void attachObserver() {
    // Done below
  }

  @override
  void detachObserver(BuildContext context) {
    // Done below
  }

  // Invokes the getState() method below to obtain latest data
  @override
  List getState() {
    return _bloodPressureState.getState();
  }

  // used to reflect changes made in another widget(In this case the
  // bloodPressureTable class).
  @override
  void updateState() {
    _bloodPressureState.resetObservers();
    updateDisplay();
  }

  // This is a method which can be invoked to update the refreshSeconds
  @override
  void updateRefresh() {
    _bloodPressureState.refreshStarter(this.refreshStateCount);
  }

  // This method is invoked to notify all the observers linked to this subject
  // to get the latest data
  @override
  void notifyObservers() {
    _bloodPressureState.notifyObservers();
  }

  // This method is used to reset the chosenForLatestDisplay list above.
  void resetChosen() {
    chosenForLatestDisplay = [];
    for (var i=0; i<monitoredPatients.length; i++){
      chosenForLatestDisplay.add(false);
    }
  }

  // Invoked to refresh to bloodPressure widget to reflect latest changes.
  void updateDisplay() {
    _bloodPressureState.updateDisplay();
  }

}

class _BloodPressureState extends State<BloodPressure> with AutomaticKeepAliveClientMixin<BloodPressure>{

  //Declared lists required to store retrieved information
  List bloodPressureValues;
  //Declared lists requried to ensure that the widgets displayed are in sync
  List<Observer> observers = [];
  List<bool> observersAvailable = [];

  // boolean required to handle the State of this widget
  bool disposed = false;
  bool noJsonCall = true;

  //Overriden to initialise a table when invoked
  @override
  void initState(){
    super.initState();

    Future.delayed(Duration.zero, () async{
      this.observers.add(BloodPressureTable(this.widget));
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
                      itemCount: this.observers.length,
                      itemBuilder: (BuildContext context, int index){
                        if (this.observersAvailable[index] == true){
                          return this.observers[index];
                        }
                        return Container();
                      },
                    ),
                  );
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                RaisedButton(
                  child: this.observers.length < 1 || this.observersAvailable[0] == true ? Text('Detach Table') : Text('Attach Table'),
                  color: Colors.indigo[600],
                  textColor: Colors.white,
                  onPressed: () {
                    if (this.observersAvailable[0] == true) {
                      detachObserver(context);
                    } else {
                      attachObserver(context);
                    }
                    updateDisplay();
                  },
                ),
              ],
            ),
          ],
        ),
      )
    );
  }

  // Returns the number of widget slots to declare when the FutureBuilder Widget
  // is initialising the page
  Future<num> _checkObservers() async {
    this.bloodPressureValues = await retrieveBloodPressureValues();
    resetObservers();
    // refreshes table if noJsonCall is made
    if(noJsonCall == true){
      noJsonCall = false;
      setState((){});
    }

    refreshStarter(widget.refreshStateCount);
    return this.observers.length;
  }

  // Asynchronous function to retrieve the blood pressure values from database
  // When new data is retrieve, stores data into a sharedpreference instance
  // note: Only the latest blood pressure valued is stored in this class.
  // If the patient has more than 1 blood pressure value in their history,
  // The remaining (4 at max) data are stored into the shared preference
  // instance
  Future<List> retrieveBloodPressureValues() async {
    List availableBloodPressure =[];

    for (var i=0; i < widget.monitoredPatients.length ; i++){
      List inMemory = await _getFromSharedPreference(widget.monitoredPatients[i]['patientId']);
      if (inMemory != null){
        availableBloodPressure.add({
          'Name': widget.monitoredPatients[i]['patientName'],
          'ID': widget.monitoredPatients[i]['patientId'],
          'Systolic' : inMemory[1],
          'Diastolic' : inMemory[2],
          'Effective D/T': inMemory[3]
        });
      }
      else{
        noJsonCall = false;
        GetBloodPressure cholesterolValue = GetBloodPressure(widget.monitoredPatients[i]['patientId'], 'https://fhir.monash.edu/hapi-fhir-jpaserver/fhir');
        List temp = await cholesterolValue.getParsedJson();

        if (temp.length != 0) {
          availableBloodPressure.add({
            'Name': widget.monitoredPatients[i]['patientName'],
            'ID': widget.monitoredPatients[i]['patientId'],
            'Systolic': temp[0]['Diastolic'].toString(),
            'Diastolic': temp[0]['Systolic'].toString(),
            'Effective D/T': temp[0]['EffectiveDateTime'].toString()
          });

          List<String> toStore = [temp.length.toString()];
          for (var i=0; i < temp.length; i++){
            toStore.add(temp[i]['Diastolic'].toString());
            toStore.add(temp[i]['Systolic'].toString());
            toStore.add(temp[i]['EffectiveDateTime'].toString());
          }
          _updateSharedPreference(widget.monitoredPatients[i]['patientId'], toStore);
        } else {
          availableBloodPressure.add({
            'Name': widget.monitoredPatients[i]['patientName'],
            'ID': widget.monitoredPatients[i]['patientId'],
            'Systolic': 'N/A',
            'Diastolic': 'N/A',
            'Effective D/T': 'N/A'
          });
          _updateSharedPreference(widget.monitoredPatients[i]['patientId'], ['1', 'N/A', 'N/A', 'N/A']);
        }
      }
    }

    return availableBloodPressure;
  }

  // Method to retrieve data from memory using a "key"
  Future<List> _getFromSharedPreference(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final bloodPdata = prefs.getStringList("Bpressure" + patientId);
    return bloodPdata;
  }

  // Method to updated the value stored in a certain "key"
  Future<void> _updateSharedPreference(String patientId, List<String> details) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("Bpressure" + patientId, details);
  }

  // returns the latest blood pressure data
  List getState() {
    return this.bloodPressureValues;
  }

  // For each observer that is running, update their states
  void notifyObservers() {
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

  // refreshes the current widget to reflect changes made
  void updateDisplay(){
    setState(() {});
  }

  // Resets list of observers
  void resetObservers(){
    if (this.observers.length != 0 && this.observersAvailable.length != 0) {
      this.observers.removeRange(1, (this.observers.length));
      this.observersAvailable.removeRange(1, this.observersAvailable.length);

      // Adds text observers for chosen patients
      for (var i = 0; i < this.widget.chosenForLatestDisplay.length; i++) {
        if (this.widget.chosenForLatestDisplay[i] == true) {
          this.observers.add(BloodPressureText(
              this.widget.monitoredPatients[i]['patientId'],
              this.widget.monitoredPatients[i]['patientName']));
          this.observersAvailable.add(true);
        }
        else {
          this.observers.add(null);
          this.observersAvailable.add(false);
        }
      }

      // Adds graph observers for chosen patients
      for (var i = 0; i < this.widget.chosenForLatestDisplay.length; i++) {
        if (this.widget.chosenForLatestDisplay[i] == true) {
          this.observers.add(BloodPressureGraph(
              this.widget.monitoredPatients[i]['patientId'],
              this.widget.monitoredPatients[i]['patientName']));
          this.observersAvailable.add(true);
        }
        else {
          this.observers.add(null);
          this.observersAvailable.add(false);
        }
      }
    }
  }

  // Reattach the table observer
  void attachObserver(BuildContext context) {
    this.observers = [BloodPressureTable(this.widget)];
    this.observersAvailable = [true];

    _attachToast(context);
    refreshStarter(widget.refreshStateCount);
  }

  // Detaches the table observer along with every other observer
  void detachObserver(BuildContext context) {
    this.observers = [null];
    this.observersAvailable = [false];
    this.widget.chosenForLatestDisplay = [];

    _detachToast(context);
  }

  // Invoked every N seconds to pull new data from database
  void refreshStarter(int stateCount){
    if (widget != null) {
      Future.delayed(Duration(seconds: widget.refreshSeconds), () async {
        // clear memory so that new data is retrieved
        if (disposed == false && stateCount == widget.refreshStateCount && observersAvailable[0] == true) {
          final pref = await SharedPreferences.getInstance();
          await pref.clear();
          this.bloodPressureValues = await retrieveBloodPressureValues();
          notifyObservers();
          refreshStarter(stateCount);
        }
      });
    }
  }

  // toast message to notify of update
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

  // toast message to notify of attachment of table
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

  // toast message to notify of dettachment of table
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

  @override
  void dispose(){
    super.dispose();
    disposed = true;
    this.observers = [];
  }

}