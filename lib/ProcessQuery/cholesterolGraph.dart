import 'package:flutter/material.dart';
import 'cholesterol.dart';
import 'observer.dart';
import 'package:charts_flutter/flutter.dart';

// Represents a graph which displays the cholesterol values of patients.
class CholesterolGraph extends Observer {

  Cholesterol subjectObserved;
  final _CholesterolGraphState graphState = _CholesterolGraphState();

  CholesterolGraph(this.subjectObserved);

  @override
  _CholesterolGraphState createState() => graphState;

  // Obtains cholesterol values from subject observed.
  @override
  List getData() {
    return subjectObserved.getState();
  }

  // Invoked by subject to update
  @override
  void updateObserver() {
    graphState.updateObserver();
  }

}

class _CholesterolGraphState extends State<CholesterolGraph> {
  List data;

  @override
  void initState() {
    super.initState();
    data = widget.getData();
  }

  @override
  Widget build(BuildContext context) {
    // Display empty container if there is no data
    if (data.length == 0) {
      return Container();
    }

    // Display empty container if there is no valid data
    num invalidCholesterol = 0;
    for (int i=0; i<data.length; i++) {
      if (data[i]['Cholesterol'] == 'N/A') {
        invalidCholesterol += 1;
      }
    }
    if (invalidCholesterol == data.length) {
      return Container();
    }

    return Container(
      height: 500.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BarChart(
          getSeries(),
          domainAxis: OrdinalAxisSpec(
            renderSpec: SmallTickRendererSpec(
              labelRotation: 60,
              labelStyle: TextStyleSpec(
                fontSize: 15,
              ),
            ),
          ),
          primaryMeasureAxis: NumericAxisSpec(
            renderSpec: GridlineRendererSpec(
              labelStyle: TextStyleSpec(
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Initialise series item for bar chart
  List<Series<SeriesItem,String>> getSeries() {
    List<SeriesItem> chartData = [];
    for (int i=0; i<data.length; i++) {
      if(data[i]['Cholesterol'] == 'N/A') {
        continue;
      }
      chartData.add(new SeriesItem(data[i]['Name'], double.parse(data[i]['Cholesterol'])));
    }

    return [Series<SeriesItem,String>(
      id: "Patients",
      data: chartData,
      colorFn: (_,__) => MaterialPalette.blue.shadeDefault,
      domainFn: (SeriesItem cholesterolInfo, _) => cholesterolInfo.name,
      measureFn: (SeriesItem cholesterolInfo, _) => cholesterolInfo.cholesterolValue,
    )];
  }

  void updateObserver() {
    setState(() {});
  }
}

// Represents each item in the bar chart
class SeriesItem {
  final String name;
  final double cholesterolValue;

  SeriesItem(this.name, this.cholesterolValue);
}