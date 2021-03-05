import 'package:fit3077/DataRetrieval/jsonParser.dart';
import 'dart:convert';
import 'package:http/http.dart';

class GetPatientInfo extends JsonParser {
  // Client needs to provide rootUrl

  String patientId;

  // Constructor of getPatientInfo class, the patientId is the
  // id number of patient in interest
  GetPatientInfo(String patientId, String url): super(url) {
    this.patientId = patientId;
  }

  // Override the method getParsedJson of parent class
  // This method returns a list of information regarding patient in the
  // following format:
  // [{"name", "gender", "birthDate", "address", "city", "country"}]
  @override
  Future<List> getParsedJson() async {
    String baseUrl = this.rootUrl + '/Patient/' + patientId;
    Response response = await get(baseUrl);
    Map data = jsonDecode(response.body);

    Map nameMap = data["name"][0];
    String name = nameMap["given"][0] + " " + nameMap["family"];
    String gender = data['gender'];
    String birthDate = data['birthDate'];
    String address = data['address'][0]['line'][0];
    String city = data['address'][0]['city'];
    String country = data['address'][0]['country'];

    return [{"name": name, "gender": gender, "birthDate": birthDate, "address": address,
    "city": city, "country": country}];
  }

}