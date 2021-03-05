import 'package:flutter/material.dart';
import 'package:fit3077/UserInterface/loadingPage.dart';
import 'package:fit3077/UserInterface/displayPatients.dart';
import 'package:fit3077/UserInterface/tabsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Defines routes that navigate to all pages
void main() => runApp(MaterialApp(
  title: 'My App',
  theme: ThemeData(
    primaryColor: Colors.blueAccent[700],
  ),
  initialRoute: '/',
  routes: {
    '/': (context) => LoginPage(),
    '/retrieval': (context) => LoadingPage(),
    '/display': (context) => DisplayPatients(),
    '/data' : (context) => TabsPage(),
  },
));

// Login page for practitioners to enter their identifiers
class LoginPage extends StatelessWidget {
  static String practitionerIdentifier;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('My Application'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Identifier',
                  labelText: 'Please Enter Identifier: ',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
                onChanged: (text) {
                  practitionerIdentifier = text;
                },
              ),
            ),
            RaisedButton(
              // passes the entered identifier to the loadingPage for patients retrieval
              onPressed: () {
                clearData();
                Navigator.pushNamed(context, '/retrieval', arguments: practitionerIdentifier);
              },
              child: Text('Login'),
              textColor: Colors.white,
              color: Colors.blueAccent[700],
            )
          ],
        ),
      ),
    );
  }

  // Clears existing data in the memory for new login
  Future<void> clearData() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}
