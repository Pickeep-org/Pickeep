import 'package:pickeep/firestore/firestore_categories.dart';
import 'package:pickeep/firestore/firestore_locatoins.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http ;

// TODO: refactor
class Filters {
  static final Filters _instance = Filters._intInstance();
  late List<String> locations;
  late List<String> categories;
  // late List<Map<String, List<String>>> districts;

  factory Filters() {
    return _instance;
  }

  Filters._intInstance();
  // Future locationsList() async {
  //   var url = 'https://firebasestorage.googleapis.com/v0/b/pickeep-3341c.appspot.com/o/files%2Fdatastore_cities.json?alt=media&token=64569638-9ef6-4ac8-92f3-8f2806dbdcbc';
  //   http.Response response = await http.get(Uri.parse(url));
  //   var user = jsonDecode(response.body);
  //   var answer = user['result']['records'];
  //   List<String> Districts =  answer.expand((e)=>[e[1]]).toSet().toList();
  //   locations = answer.expand((e)=>[e[0]]).toList();
  //   for(int i = 0; i < Districts.length; i++) {
  //     answer.where((e)=>{if (e[1] == Districts[i]) {
  //       districts.add({Districts[i] : e[0]})}});
  //   }
  //   return;
  //   //answer.where((e)=>{ e[1] });
  //   /*return answer.expand((e)=>[e[0]]).toList();
  //   [ e[1] : [e[0]] when all e[0] have same e[1]  ]
  //   [  [ tveria, kinneret ], [lala, beersheva]    ]
  //   [  tveria: kinneret , tzemah: kinneret  ]*/
  // }

  Future loadFilters() async {
    // await locationsList();
    locations = (await FirestoreLocations.instance().getLocationsOrderByCity())
        .docs
        .map((doc) => doc.get('city').toString())
        .toList();
    categories = (await FirestoreCategories.instance().getCategoriesOrderByName())
        .docs
        .map((doc) => doc.get('name').toString())
        .toList();
  }
}
