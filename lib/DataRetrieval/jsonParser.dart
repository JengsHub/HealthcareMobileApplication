abstract class JsonParser {
  // Abstract parser class

  // The root url of website to parse data from
  String rootUrl;

  // Constructor of JsonParser
  JsonParser(String rootUrl){
    this.rootUrl = rootUrl;
  }

  // abstract method defined for data retrieval
  Future<List> getParsedJson();
}