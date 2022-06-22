import 'package:pickeep/firestore/firestore_categories.dart';
import 'package:pickeep/firestore/firestore_locatoins.dart';

// TODO: refactor
class Filters {
  static final Filters _instance = Filters._intInstance();
  late List<String> locations;
  late List<String> categories;

  factory Filters() {
    return _instance;
  }

  Filters._intInstance();

  Future loadFilters() async {
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
