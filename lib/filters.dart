import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Filters {

  Future loadCities() async {
    var url = 'https://firebasestorage.googleapis.com/v0/b/pickeep-3341c.appspot.com/o/files%2Fdatastore_cities.json?alt=media&token=a579b08f-45b5-490d-80a7-c9b3371ee0c2';
    http.Response response = await http.get(Uri.parse(url));
    var user = jsonDecode(response.body);
    var answer = user['result']['records'];
    districts =  answer.expand((e)=>[e[1]]).toSet().toList().cast<String>()..sort();
    cities = answer.expand((e)=>[e[0]]).toList().cast<String>();
    for(int i = 0; i < districts.length; i++) {
      var result = answer.where((e)=> e[1] == districts[i]);
      districtsMap[ districts[i] ] = result.expand((e)=>[e[0]]).toList();
    }
    return;
  }

  Future loadCategories() async{
    categories = (await FirebaseFirestore.instance.collection('Categories').orderBy('name').get())
        .docs
        .map((doc) => doc.get('name').toString())
    .toList();
  }

  static final Filters _instance = Filters._intInstance();
  late List<String> cities;
  late List<String> districts;
  late List<String> categories;
  late Map<String, List<dynamic>> districtsMap = {};

  factory Filters() {
    return _instance;
  }

  Filters._intInstance();


  Future loadFilters() async {
    await loadCities();
    await loadCategories();
  }
}
