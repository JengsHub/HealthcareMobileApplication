// Exception to be raised when invalid practitioner identifier was entered.

class InvalidPracIdException implements Exception {

  final _message;

  InvalidPracIdException([this._message]);

  String toString() {
    if (_message == null) return "Exception";
    return "Exception: $_message";
  }

}