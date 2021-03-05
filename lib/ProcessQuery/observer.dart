import 'package:flutter/cupertino.dart';

// Represents observer that observes and reflects the state of a subject.
abstract class Observer extends StatefulWidget{

  // Invoked by observer to update its display
  void updateObserver();

  // Obtains data from subject for display
  void getData();

}