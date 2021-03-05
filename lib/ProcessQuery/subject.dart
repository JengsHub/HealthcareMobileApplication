import 'package:flutter/cupertino.dart';
import 'observer.dart';


abstract class Subject extends StatefulWidget{

  // String subjectDescription;
  num refreshSeconds = 300;
  num refreshStateCount = 0;
  List<Observer> observers;
  List<bool> observersAvailable;
  List monitoredPatients;

  // Methods required to synchronise implemented Subjects
  // To attach observer
  void attachObserver();
  // To detach observer
  void detachObserver(BuildContext context);
  // Notifies all its observers
  void notifyObservers();
  // Returns a subject's state when invoked by observer
  List getState();
  // Invoked by observer to update a subject's state whenever changes are made by observer
  void updateState();
  // Invoked when refresh seconds are updated
  void updateRefresh();

  // changes the refresh seconds
  void setRefreshSeconds(num seconds) {
    this.refreshSeconds = seconds;
  }
}