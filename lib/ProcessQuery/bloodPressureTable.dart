import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'bloodPressure.dart';
import 'observer.dart';
import 'package:fit3077/DataRetrieval/getPatientInfo.dart';

// Represents a table which displays the cholesterol values of patients
class BloodPressureTable extends Observer{

  // Instance of subject is created
  BloodPressure subjectObserved;

  // Initialise an instance _BloodPressureTableState for referencing
  _BloodPressureTableState observerState = _BloodPressureTableState();

  BloodPressureTable(this.subjectObserved);

  @override
  _BloodPressureTableState createState() => observerState = _BloodPressureTableState();

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

class _BloodPressureTableState extends State<BloodPressureTable>{

  // Contains patients that are selected to be deleted.
  List <Map> selectedElements = [];
  List data;

  // Initialised blood pressure values for highlighting of values
  double highDiastolic;
  double highSystolic;

  @override
  void initState(){
    super.initState();
    data = widget.getData();
  }

  @override
  void setState(func) {
    if (mounted) {
      super.setState(func);
    }
  }

  @override
  Widget build(BuildContext context) {

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
                  DataTable(
                    columnSpacing: 5.0,
                    horizontalMargin: 5.0,
                    columns: getColumnHeaders(data),
                    rows: getRows(data),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          width: 100.0,
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
                              hintText: "Systolic",
                            ),
                            onChanged: (text) {highSystolic = double.parse(text);},
                          ),
                        ),
                        SizedBox(
                          width: 100.0,
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
                              hintText: "Diastolic",
                            ),
                            onChanged: (text) {highDiastolic = double.parse(text);},
                          ),
                        ),
                        FloatingActionButton.extended(
                          heroTag: 'HighlightButton',
                          label: Text('Highlight'),
                          icon: Icon(Icons.done),
                          backgroundColor: Colors.lightGreen[800],
                          onPressed: () {
                            setState(() {});
                            FocusScope.of(context).unfocus();
                            _highlighted(context);
                          },
                        )
                      ],
                    ),

                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FloatingActionButton.extended(
                          heroTag: "deleteButton",
                          label: Icon(Icons.delete),
                          backgroundColor: Colors.lightGreen[800],
                          onPressed: () {removeElements();},
                        ),
                        FloatingActionButton.extended(
                          heroTag: "LastFive",
                          label: Text("View Latest"),
                          backgroundColor: Colors.lightGreen[800],
                          onPressed: () {
                            setLatestDisplayList(context);
                          },
                        )
                      ],
                    ),
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
          Container(
            height: 50.0,
            child: Text(
              data[i][headers[j]],
              // Display patient data according to average cholesterol values of patients being monitored.
              style: TextStyle(
                fontSize: 14.6,
                fontWeight: FontWeight.bold,
                color: getColor(headers[j], data[i][headers[j]]),
                // color:
              ),

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
      widget.subjectObserved.chosenForLatestDisplay.removeAt(data.indexOf(selectedElements[i]));
      data.remove(selectedElements[i]);
    }

    widget.subjectObserved.updateState();

    setState(() {
      // Refreshes list of selected patients.
      selectedElements = [];
    });
  }

  // Set the list in chosenForLatestDisplay list in subject to reflect the
  // patients selected
  void setLatestDisplayList(BuildContext context) async{
      // Validate selected patients for latest observations display
      if (validateLatestDisplay(context)){
        widget.subjectObserved.resetChosen();
        for (var i = 0; i < selectedElements.length; i++){
          widget.subjectObserved.chosenForLatestDisplay[data.indexOf(selectedElements[i])] = true;
        }

        widget.subjectObserved.updateDisplay();

        setState(() {
          // Refreshes list of selected patients.
          selectedElements = [];
        });

      }
    else{
      _invalidSelection(context);
    }
  }

  // Checks whether the selected patients are valid for latest observations display if
  // systolic value has been specified
  bool validateLatestDisplay(BuildContext context){
    if (this.highSystolic == null){
      _invalidSystolic(context);
      return false;
    }
    else{
      for (var i = 0; i < selectedElements.length; i++){
        // if selected elements has values lower than high systolic, return false
        if (double.parse(data[data.indexOf(selectedElements[i])]['Systolic']) < this.highSystolic){
          return false;
        }
      }
    }
    return true;
  }

  updateObserver() {
    setState(() {});
  }

  // Returns the colour of font to display depending on if blood pressure
  // value is higher than specified
  Color getColor(String type, String content) {
    if (type == 'Diastolic' && highDiastolic != null && content != 'N/A' && double.parse(content) > highDiastolic ){
      return Colors.purple;
    }
    else if (type == 'Systolic' && highSystolic != null && content != 'N/A' && double.parse(content) > highSystolic ){
      return Colors.purple;
    }

    return Colors.black;
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

  // Toast to show that the values have been highlighted
  void _highlighted(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Values have been highlighted",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  // Toast to show value not specified
  void _invalidSystolic(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Systolic value not specified.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }

  // Toast to show selected patients do not have systolic value higher than
  // specified
  void _invalidSelection(BuildContext context) {
    Fluttertoast.showToast(
      msg: "Selected Patient(s) does not have high systolic values.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }
}