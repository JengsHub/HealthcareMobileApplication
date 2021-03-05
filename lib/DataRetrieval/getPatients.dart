import 'dart:convert';
import 'package:http/http.dart';
import 'package:fit3077/DataRetrieval/jsonParser.dart';
import 'package:fit3077/invalidPracIdException.dart';

class GetPatients extends JsonParser{
  // Client needs to provide rootUrl

  String practitionerIdentifier;

  // Constructor of getPatients class, the practitionerIdentifier is the
  // identifier of practitioner in interest
  GetPatients(String practitionerIdentifier, String url): super(url){
    this.practitionerIdentifier = practitionerIdentifier;
  }

  // Override the method getParsedJson of parent class
  // This method returns a list of patients in the following format:
  // [{'patientName', 'patientId'}]
  @override
  Future<List> getParsedJson() async {

    num count = 0;
    bool hasNextPage = true;
    List patients = [];
    List<String> names = [];
    String nextUrl = this.rootUrl + '/Encounter?practitioner.identifier=http://hl7.org/fhir/sid/us-npi|'
        + practitionerIdentifier + '&_count=100';

    while (hasNextPage && count < 5) {
      String baseUrl = nextUrl;
      Response response = await get(baseUrl);
      Map data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['total'] == 0) {
        throw new InvalidPracIdException('Invalid practitioner ID');
      }

      hasNextPage = false;

      List links = data['link'];
      for (var i = 0; i < links.length; i++) {
        if (links[i]['relation'] == 'next') {
          hasNextPage = true;
          nextUrl = links[i]['url'];
          break;
        }
      }

      List encounters = data['entry'];

      for (var i = 0; i < encounters.length; i++) {
        String patientName = encounters[i]['resource']['subject']['display'];
        String patientId = encounters[i]['resource']['subject']['reference']
            .substring(8);

        if (names.contains(patientName)) {
          continue;
        }
        else {
          patients.add({'patientName': patientName, 'patientId': patientId});
          names.add(patientName);
        }
      }
      count += 1;
    }
    return patients;
  }
}