import 'dart:convert';
import 'package:http/http.dart';
import 'package:fit3077/DataRetrieval/jsonParser.dart';

class GetCholesterol extends JsonParser{
  // Client needs to provide rootUrl

  String patientIdentifier;

  // Constructor of getCholesterol class, the patientID is the
  // identifier of patient in interest
  GetCholesterol(String patientID, String url) : super(url){
    this.patientIdentifier = patientID;
  }

  // Override the method getParsedJson of parent class
  // This method returns a list of information regarding cholesterol of patient
  // in the following format:
  // [cholesterolValue, effectiveDateTime]
  @override
  Future<List> getParsedJson() async {
    String baseUrl = this.rootUrl + '/Observation?patient=' + patientIdentifier + '&code=2093-3&_sort=-date';
    Response response = await get(baseUrl);
    Map data = jsonDecode(response.body);
    double cholesterolValue;
    String effectiveDateTime;
    DateTime dateTime;
//    String dateTime;
//    DateTime effectiveDateTime;

    num total = data['total'];
    if (total == 0){
      return [];
    }

    // Refactored to sort according to date
    cholesterolValue = data['entry'][0]['resource']['valueQuantity']['value'];
    effectiveDateTime = data['entry'][0]['resource']['effectiveDateTime'];
    dateTime = DateTime.parse(effectiveDateTime);
    effectiveDateTime = dateTime.toString().substring(0,10) + "/" + dateTime.toString().substring(11,16);


//    // In the future we can change json request to sort data by date first
//    for (var i=0 ; i < total; i++){
//      dateTime = data['entry'][i]['resource']['effectiveDateTime'];
//      DateTime currentEffectiveDateTime = DateTime.parse(dateTime);
//
//      if (effectiveDateTime == null){
//        effectiveDateTime = currentEffectiveDateTime;
//        cholesterolValue = data['entry'][i]['resource']['valueQuantity']['value'];
//      }
//      else if(currentEffectiveDateTime.isAfter(effectiveDateTime)){
//        effectiveDateTime = currentEffectiveDateTime;
//        cholesterolValue = data['entry'][i]['resource']['valueQuantity']['value'];
//      }
//      else{
//        print(effectiveDateTime.toString());
//        print(dateTime);
//      }
//    }
//
//    dateTime = effectiveDateTime.toString().substring(0,10) + "/" + effectiveDateTime.toString().substring(11,16);

    return [cholesterolValue, effectiveDateTime];
  }

}
