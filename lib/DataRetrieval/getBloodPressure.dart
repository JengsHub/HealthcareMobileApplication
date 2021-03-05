import 'jsonParser.dart';
import 'dart:convert';
import 'package:http/http.dart';

class GetBloodPressure extends JsonParser {

  // string to store patientID of interest
  String patientID;

  GetBloodPressure(String patientID, String url) : super(url) {
    this.patientID = patientID;
  }

  // Returns up to 5 blood pressure observations
  // Observation format {'Diastolic': diastolic, 'Systolic': systolic, 'EffectiveDateTime': effectiveDateTime}
  @override
  Future<List> getParsedJson() async {
    String baseUrl = this.rootUrl + '/Observation?patient=' + patientID + '&code=55284-4&_sort=-date';
    Response response = await get(baseUrl);
    Map data = jsonDecode(response.body);
    num total = data['total'];
    List<Map> fiveLatestBPObservations = [];

    if (total == 0) {
      return [];
    }

    if (total > 5) {
      total = 5;
    }

    List entries = data['entry'];

    for (int i=0; i<total; i++) {
      double diastolic = entries[i]['resource']['component'][0]['valueQuantity']['value'].toDouble();
      double systolic = entries[i]['resource']['component'][1]['valueQuantity']['value'].toDouble();
      String effectiveDateTime = data['entry'][0]['resource']['effectiveDateTime'];
      DateTime dateTime = DateTime.parse(effectiveDateTime);
      effectiveDateTime = dateTime.toString().substring(0,10) + "/" + dateTime.toString().substring(11,16);
      fiveLatestBPObservations.add({'Diastolic': diastolic, 'Systolic': systolic, 'EffectiveDateTime':effectiveDateTime});
    }

    return fiveLatestBPObservations;

  }

}