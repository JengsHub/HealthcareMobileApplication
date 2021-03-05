import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Displays retrieved list of patients
class DisplayPatients extends StatefulWidget {

  @override
  _DisplayPatientsState createState() => _DisplayPatientsState();

}

class _DisplayPatientsState extends State<DisplayPatients> {

  // {'patientName': patientName, 'patientId': patientID}
  List patients;
  List<String> isSelected;

  @override
  void initState(){
    super.initState();

    Future.delayed(Duration.zero, (){
      setState(() {
        patients = ModalRoute
            .of(context)
            .settings
            .arguments;

        // List to store whether patients are being selected for monitoring
        isSelected = List.generate(patients.length, (i) => 'None');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          // These lists will be passed on to the following page (TabsPage) for display.
          List cholesterolMonitored = [];
          List bloodPressureMonitored = [];

          for (var i=0; i<patients.length ; i++){
            if (isSelected[i] == 'Both') {
              cholesterolMonitored.add(patients[i]);
              bloodPressureMonitored.add(patients[i]);
            }
            else if (isSelected[i] == 'Cholesterol') {
              cholesterolMonitored.add(patients[i]);
            }
            else if (isSelected[i] == 'Blood Pressure') {
              bloodPressureMonitored.add(patients[i]);
            }
          }

          // Show toast if no patient is being selected.
          if (cholesterolMonitored.length == 0 && bloodPressureMonitored.length == 0){
            _showToast(context);
          }
          // Navigate to TabsPage by passing toPassOn
          else{
            Navigator.pushNamed(context, '/data',
                arguments: {'Cholesterol': cholesterolMonitored, 'BloodPressure': bloodPressureMonitored})
                .then((returnArgs) {
                  // Callback to update the list of patients currently being monitored when popped back to this page.
                  updateMonitoredPatients(returnArgs);
            });
          }
        },
        child: Text('Done'),
        backgroundColor: Colors.blueAccent[700],
      ),
      body: ListView.builder(
        itemCount: patients == null ? 0 : patients.length,
        itemBuilder: (context, index) {
          // Highlight selected patients
          return Card (
            child: Ink(
              color: isSelected[index] == 'Cholesterol' ? Colors.amber[300] :
                isSelected[index] == 'Blood Pressure' ? Colors.red[200] :
                isSelected[index] == 'Both' ? Colors.teal[300] : Colors.transparent,
              child: ListTile(
                title: Text(patients[index]['patientName'],
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: _dropDownList(context, index),
              )
            )
          );
        },
      ),
    );
  }

  Widget _dropDownList(BuildContext context, num index) {

    return DropdownButton(
      value: isSelected[index],
      icon: Icon(Icons.expand_more),
      iconSize: 28,
      elevation: 16,
      onChanged: (String newValue) {
        setState(() {
          isSelected[index] = newValue;
        });
      },
      items: [
        DropdownMenuItem<String>(
          value: 'Cholesterol',
          child: Text(
            'Cholesterol',
            style: TextStyle(
              color: Colors.black,
              fontSize: 17.0,
            ),
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Blood Pressure',
          child: Text(
            'Blood Pressure',
            style: TextStyle(
              color: Colors.black,
              fontSize: 17.0,
            ),
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Both',
          child: Text(
            'Both',
            style: TextStyle(
              color: Colors.black,
              fontSize: 17.0,
            ),
          ),
        ),
        DropdownMenuItem<String>(
          value: 'None',
          child: Text(
            'None',
            style: TextStyle(
              color: Colors.black,
              fontSize: 17.0,
            ),
          ),
        ),
      ],
    );
  }

  // Update list of patients being selected to monitor.
  // Callback function when popped back to this page.
  void updateMonitoredPatients(newMonitoredPatients) {
    List newCholesterolMonitored = newMonitoredPatients['Cholesterol'];
    List newBloodPressureMonitored = newMonitoredPatients['Blood Pressure'];

    setState(() {
      isSelected = List.generate(patients.length, (i) => 'None');

      for (int i=0; i<newCholesterolMonitored.length; i++) {
        num index = patients.indexOf(newCholesterolMonitored[i]);
        isSelected[index] = 'Cholesterol';
      }

      for (int i=0; i<newBloodPressureMonitored.length; i++) {
        num index = patients.indexOf(newBloodPressureMonitored[i]);
        if (isSelected[index] == 'Cholesterol') {
          isSelected[index] = 'Both';
        }
        else {
          isSelected[index] = 'Blood Pressure';
        }
      }
    });
  }

  // Toast shown when no patient is selected.
  void _showToast(BuildContext context){
    Fluttertoast.showToast(
        msg:  "Please pick at least 1 patient to monitor",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}