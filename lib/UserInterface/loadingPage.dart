import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fit3077/DataRetrieval/getPatients.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fit3077/invalidPracIdException.dart';

// Retrieves patients data using practitioner's identifier.
// Navigates to displayPatients page after data is successfully retrieved.
class LoadingPage extends StatefulWidget {

  @override
  _LoadingPageState createState() => _LoadingPageState();

}

class _LoadingPageState extends State<LoadingPage> {

  String practitionerIdentifier;
  List patients;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero,() async {
      practitionerIdentifier = ModalRoute.of(context).settings.arguments;
      // Pop back to the previous page if no identifier is entered
      if (practitionerIdentifier == null){
        Navigator.pop(context);
        _showToast(context);
      }

      try {
        int.parse(practitionerIdentifier);
      } on FormatException catch (e) {
        print(e);
        Navigator.pop(context);
        _showToast(context);
      }
      retrievePatients(practitionerIdentifier);
    });
  }

  // Show rotating circle to show that data is being retrieved.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SpinKitRotatingCircle(
        color: Colors.white,
        size: 50.0,
      ),
    );
  }

  // Uses GetPatients to retrieve corresponding patients of practitioner.
  void retrievePatients(practitionerIdentifier) async {
    GetPatients nameId = GetPatients(practitionerIdentifier, 'https://fhir.monash.edu/hapi-fhir-jpaserver/fhir');

    try {
      patients = await nameId.getParsedJson();
      Navigator.pushNamed(context, '/display', arguments: patients);

    } on InvalidPracIdException catch (e) {
      // Pop back to the previous page if exception is caught
      print(e);
      Navigator.pop(context);
      _showToast(context);
    }
  }

  // Toast shown when invalid practitioner identifier was entered.
  void _showToast(BuildContext context){
    Fluttertoast.showToast(
        msg:  "Invalid identifier",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}