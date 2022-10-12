import 'package:pickeep/firestore/firestore_categories.dart';
import 'package:pickeep/firestore/firestore_locatoins.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http ;

import 'dart:convert';
import 'package:http/http.dart' as http;

// TODO: refactor



class Filters {

  Future locationsList() async {
    var url = 'https://firebasestorage.googleapis.com/v0/b/pickeep-3341c.appspot.com/o/files%2Fdatastore_cities.json?alt=media&token=8ffbf7e5-0e98-4d02-84ca-a131db95c62e';
    http.Response response = await http.get(Uri.parse(url));
    var user = jsonDecode(response.body);
    var answer = user['result']['records'];
    districts =  answer.expand((e)=>[e[1]]).toSet().toList().cast<String>()..sort();
    locations = answer.expand((e)=>[e[0]]).toList().cast<String>();
    for(int i = 0; i < districts.length; i++) {
      var result = answer.where((e)=> e[1] == districts[i]);
      districtsLocations[ districts[i] ] = result.expand((e)=>[e[0]]).toList();
    }
    return;
  }

  static final Filters _instance = Filters._intInstance();
  late List<String> locations;
  late List<String> districts;
  late List<String> categories;
  late Map<String, List<dynamic>> districtsLocations = {};

  factory Filters() {
    return _instance;
  }

  Filters._intInstance();


  Future loadFilters() async {
    await locationsList();
    categories = (await FirestoreCategories.instance().getCategoriesOrderByName())
        .docs
        .map((doc) => doc.get('name').toString())
        .toList();
  }
}
