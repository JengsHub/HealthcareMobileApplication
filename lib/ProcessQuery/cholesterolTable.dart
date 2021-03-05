import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fit3077/ProcessQuery/cholesterol.dart';
import 'package:fit3077/ProcessQuery/observer.dart';
import 'package:fit3077/DataRetrieval/getPatientInfo.dart';

// Represents a table which displays the cholesterol values of patients
class CholesterolTable extends Observer{

  Cholesterol subjectObserved;
  final _CholesterolTableState observerState = _CholesterolTableState();

  CholesterolTable(this.subjectObserved);

  @override
  _CholesterolTableState createState() => observerState;

  // Obtains data from subject to be displayed.
  @override
  List getData() {
    return this.subjectObserved.getState();
  }

  // Called by subject to update display.
  @override
  updateObserver() {
    observerState.updateObserver();
  }

}

class _CholesterolTableState extends State<CholesterolTable>{

  // Contains patients that are selected to be deleted.
  List <Map> selectedElements = [];
  List data;
  // Stores amount of patients with valid cholesterol observations.
  num validCholesterol;
  double averageCholesterol;

  @override
  void initState(){
    super.initState();
    data = widget.getData();
  }

  @override
  Widget build(BuildContext context) {

    averageCholesterol = getAverageCholesterol();

    if (data.length == 0) {
      return Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 20.0),
            child: Text("Please select a patient.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 500.0,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.minHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget> [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: DataTable(
                      columnSpacing: 5.0,
                      horizontalMargin: 5.0,
                      columns: getColumnHeaders(data),
                      rows: getRows(data),
                    ),
                  ),
                  FloatingActionButton.extended(
                    heroTag: "deleteBtn",
                    label: Icon(Icons.delete),
                    backgroundColor: Colors.lightGreen[800],
                    onPressed: () {removeElements();},
                  ),
                ]
              ),
            ),
          );
        }
      ),
    );
  }

  // Construct column headers of the table.
  List<DataColumn> getColumnHeaders(List data) {
    List headers = data[0].keys.toList();
    List<DataColumn> columnHeaders = [];

    for (var i=0; i<headers.length; i++) {
      // Exclude display of patient IDs.
      if (i==1) {
        continue;
      }
      // Simplified column header.
      else if (headers[i] == "Effective Datetime"){
        headers[i] = "Effective D/T";
      }

      print(headers[i]);
      columnHeaders.add(DataColumn(
        label: Text(
          headers[i],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: Colors.black,
          ),
        ),
      ));
    }

    return columnHeaders;
  }

  // Construct rows of the table.
  List<DataRow> getRows(List data) {
    List headers = data[0].keys.toList();
    List<DataRow> rows = [];

    for (var i=0; i<data.length; i++) {
      List<DataCell> currentCells = [];

      for (var j=0; j<headers.length; j++) {
        // Exclude patient IDs.
        if (j == 1) {
          continue;
        }
        // Construct individual cells.
        currentCells.add(DataCell(
          Text(
            data[i][headers[j]],
            // Display patient data according to average cholesterol values of patients being monitored.
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color:
              (data[i]['Cholesterol'] != 'N/A' && validCholesterol > 1 && double.parse(data[i]['Cholesterol']) > averageCholesterol)
                  ? Colors.red : Colors.black,
            ),
          ),
          // Retrieves additional patient information when any cell of a row is tapped.
          onTap: () async {
            // Show toast to indicate that data is being retrieved.
            _pleaseWait(context);
            Map patient = await getInfo(i);
            showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopUp(context, patient),
            );
          },
        ));
      }
      // Rows can be selected to be deleted.
      rows.add(DataRow(
          cells: currentCells,
          selected: selectedElements.contains(data[i]),
          onSelectChanged: (boolean) {
            onSelectedRow(boolean, data[i]);
          }
      ));
    }
    return rows;
  }

  // Update the list of selected patients when a patient is being selected or unselected.
  onSelectedRow(bool selected, Map element) async {
    setState( () {
      if (selected) {
        selectedElements.add(element);
      } else {
        selectedElements.remove(element);
      }
    });
  }

  // Remove patients from monitoring after remove button is being pressed.
  removeElements() async {
    // Remove selected patients from display and subject's list according to selected rows.
    for (var i = 0; i < selectedElements.length; i++) {
      widget.subjectObserved.monitoredPatients.removeAt(data.indexOf(selectedElements[i]));
      data.remove(selectedElements[i]);
    }

    widget.subjectObserved.updateState();


    setState(() {
      // Refreshes list of selected patients.
      selectedElements = [];
    });
  }

  // Computes the average cholesterol value of current monitored patients.
  double getAverageCholesterol() {

    validCholesterol = 0;
    double total = 0;

    for (var i=0; i<data.length; i++) {
      if (data[i]['Cholesterol'] == 'N/A') {
        continue;
      }
      // Increment amount of patients with valid cholesterol observation.
      validCholesterol += 1;
      total += double.parse(data[i]['Cholesterol']);
    }
    return total/validCholesterol;
  }

  updateObserver() {
    setState(() {});
  }

  // Uses GetPatientInfo to retrieve additional patient information.
  // Called when any cell of a row is being tapped.
  Future<Map> getInfo(index) async {
    GetPatientInfo patientInfo = GetPatientInfo(data[index]['ID'],'https://fhir.monash.edu/hapi-fhir-jpaserver/fhir');
    List infoList = await patientInfo.getParsedJson();
    Map currentPatient = infoList[0];
    return currentPatient;
  }

  // Pop up dialog to display additional patient information.
  Widget _buildPopUp(BuildContext context, Map patient) {
    return new AlertDialog(
      title: const Text('Patient info'),
      content: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Name: ' + patient['name']),
          Text('Gender: ' + patient['gender']),
          Text('Birthdate: ' + patient['birthDate']),
          Text('Address: ' + patient['address']),
          Text('City: ' + patient['city']),
          Text('Country: ' + patient['country']),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
          color: Colors.lightGreen[800],
          textColor: Colors.white,
        ),
      ],
    );
  }

  // Toast show when additional patient information is being retrieved.
  void _pleaseWait(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Please wait.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }
}