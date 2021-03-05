import 'package:flutter/material.dart';
import 'observer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BloodPressureText extends Observer {

  // String to store patient ID and Name
  String patientIDSubject;
  String patientNameSubject;

  int length = 0;
  // List to store the history of patients BP value
  List patientLatestBPObservations = [];
  _BloodPressureTextState observerState = _BloodPressureTextState();

  BloodPressureText(this.patientIDSubject, this.patientNameSubject);

  @override
  _BloodPressureTextState createState() => observerState = _BloodPressureTextState();

  // This is a method to retrieve history of cholesterol values from the
  // sharedPreferences.
  @override
  Future<void> getData() async {
    List inMemory = await _getFromSharedPreference(this.patientIDSubject);
    patientLatestBPObservations = inMemory;
    length = int.parse(patientLatestBPObservations.removeAt(0));
  }

  // invoked to refresh the state of widget
  @override
  updateObserver() {
    observerState.updateObserver();
  }

  // Method to retrieve value from memory using "key"
  Future<List> _getFromSharedPreference(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final bloodPressureData = prefs.getStringList("Bpressure" + patientId);
    return bloodPressureData;
  }

}

class _BloodPressureTextState extends State<BloodPressureText> {

  @override
  void setState(func) {
    if (mounted && widget.patientLatestBPObservations.length > 0) {
      super.setState(func);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _getFromMemory(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null){
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Retrieving Data...",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
            );
          }
          else{
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text((){
                  // return text according to how many data there are here.
                  String  toReturn = widget.patientNameSubject + ": ";
                  for (var i=0; i < widget.length ; i++){
                    widget.patientLatestBPObservations.removeAt(0);
                    toReturn += widget.patientLatestBPObservations.removeAt(0);
                    if (i == widget.length - 1){
                      toReturn = toReturn + " " + "(" + widget.patientLatestBPObservations.removeAt(0) + ")";
                    }
                    else{
                      toReturn = toReturn + " " + "(" + widget.patientLatestBPObservations.removeAt(0) + "),";
                    }
                  }
                  return toReturn;
                }(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }
        }
      ),
    );
  }

  // returns True once data has been retrieved from memory
  Future<bool> _getFromMemory() async{
    await widget.getData();
    return true;
  }

  // Refreshes the widget
  updateObserver() {
    setState(() {});
  }
}