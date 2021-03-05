import 'package:flutter/material.dart';
import 'observer.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Represents a graph which displays up to the latest five blood pressure observations of patients.
class BloodPressureGraph extends Observer {

  // Store patient ID and name to retrieve from shared preference
  String patientIDSubject;
  String patientNameSubject;
  _BloodPressureGraphState _graphState = _BloodPressureGraphState();

  BloodPressureGraph(this.patientIDSubject, this.patientNameSubject);

  @override
  _BloodPressureGraphState createState() => _graphState = _BloodPressureGraphState();

  // Retrieves data saved in shared preference
  @override
  Future<List> getData() async {
    final sharedPreference = await SharedPreferences.getInstance();
    final savedData = sharedPreference.getStringList("Bpressure" + this.patientIDSubject);
    num length = int.parse(savedData.removeAt(0));
    List data = [];
    for (int i=0; i<length; i++) {
      savedData.removeAt(0);
      data.add(savedData.removeAt(0));
      savedData.removeAt(0);
    }
    return data;

  }

  // Called by subject to update its display
  @override
  updateObserver() {
    _graphState._updateObserver();
  }

}

class _BloodPressureGraphState extends State<BloodPressureGraph>{

  List data;

  @override
  void setState(func) {
    if (mounted) {
      super.setState(func);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _getData(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Retrieving Data..."
                ),
              ),
            );
          }
          else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.patientNameSubject),
                Container(
                  height: 500.0,
                  padding: EdgeInsets.all(20.0),
                  child: LineChart(
                    _getSeries(),
                  ),
                ),
              ],
            );
          }
        }),
      );
  }

  // Obtains data from subject
  Future<bool> _getData() async {
    data = await widget.getData();
    return true;
  }

  // Initialise line chart series items
  List<Series<SeriesItem,num>> _getSeries() {
    List<SeriesItem> chartData = [];
    for (int i=0; i<data.length; i++) {
      chartData.add(new SeriesItem(i+1, double.parse(data[i])));
    }

    return [Series<SeriesItem,num>(
      id: "Observations",
      data: chartData,
      colorFn: (_,__) => MaterialPalette.blue.shadeDefault,
      domainFn: (SeriesItem systolicInfo, _) => systolicInfo._observationNum,
      measureFn: (SeriesItem systolicInfo, _) => systolicInfo._systolicValue,
    )];
  }

  void _updateObserver() {
    setState(() {});
  }
}

// Represents a series item of line chart
class SeriesItem {
  final num _observationNum;
  final double _systolicValue;

  SeriesItem(this._observationNum, this._systolicValue);
}