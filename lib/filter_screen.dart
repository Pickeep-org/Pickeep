import 'package:flutter/material.dart';
import 'package:pickeep/filters.dart';


// The class handles the selecting process of filters by the user. the filters can be
// by cities, or by categories.
// given the similarity of the selecting process of categories when adding/editing
// item, the class also handles this process in add item screen (1.4). Class fields:
// 1. List isChecked - boolean list that holds the user choices.
// 2. List texts - holds the choices meant to be shown on screen.
// 3. List Chosen - holds the user filtering choices.
// 4. List LastChosen - holds the user filtering choices in the previous attempt
// of filtering.
// 5. String filterType - holds the filter type choice triggered by the user, the
// filter types are: Category, City, CatergoryAdd (for the add item process).
class FilterScreen extends StatefulWidget {
  final String filterType;
  final List lastChosen;
  const FilterScreen(
      {Key? key, required this.filterType, required this.lastChosen})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _FilterState();
}

class _FilterState extends State<FilterScreen> {
  late List<bool> _isChecked;
  late final List<String> _texts = [];
  late List _chosen = [];
  final snackBar =
  const SnackBar(content: Text('Please choose up to 3 categories'));


  // Given filter type, the method calls the instance of Filters(2.4),
  // and get the relevant list of fliters choices.
  void getList(String filterType) {
    ['Category', 'CategoryAdd'].contains(widget.filterType)
        ? _texts.addAll(Filters().categories)
        : _texts.addAll(Filters().districts);
  }

  @override
  void initState() {
    super.initState();
    getList(widget.filterType);
    if (_texts[0] != 'All' && widget.filterType != 'CategoryAdd') {
      _texts.insert(0, "All");
    }
    _chosen.addAll(widget.lastChosen);
    _isChecked = List<bool>.filled(_texts.length, false);
  }

  // A wrap function for checkBoxListCities(), handles the
  // the division of cities into districts for the UI.
  ListView listViewCheck() {
    return ListView.builder(
        itemCount: _texts.length,
        itemBuilder: (context, distIndex) {
          if(distIndex > 0){
          return CheckboxListTile(
              value: widget.lastChosen.toSet().containsAll(Filters()
                  .districtsMap[_texts[distIndex]]!)
                    ? true
                  : _chosen.toSet().containsAll(Filters()
                      .districtsMap[_texts[distIndex]]!),
              onChanged: (val) {
                setState(
                  () {
                    val!
                        ? _chosen.addAll(Filters()
                            .districtsMap[_texts[distIndex]]!)
                        : _chosen.removeWhere((item) => Filters().districtsMap[
                            _texts[distIndex]]!.contains(item));
                    if (!val) {
                      widget.lastChosen.removeWhere((item) => Filters().districtsMap[
                      _texts[distIndex]]!.contains(item));
                    }
                  },
                );
              },
              title:
              ExpansionTile(
                  title: Text(_texts[distIndex]),
                  children: List.generate(
                      Filters()
                          .districtsMap[_texts[distIndex]]!
                          .length,
                      (cityIndex) => checkBoxListCities(
                          _texts[distIndex], cityIndex)
                      )));}
          else {
            return CheckboxListTile(
              value: widget.lastChosen.toSet().containsAll(Filters().cities)
                ? true
                : _chosen.toSet().containsAll(Filters().cities),
              title: Text(_texts[distIndex]),
              onChanged: (val){
                setState(() {
                  val!
                      ? _chosen.addAll(Filters().cities)
                      : _chosen.clear();
                  if(!val) {
                    widget.lastChosen.clear();
                  }
                });
              }
            ,) ;
          }
        });
  }

  // Create the cities checkbox list, and handles the selecting
  // process for the UI.
  CheckboxListTile checkBoxListCities(String dist, int index) {
    return CheckboxListTile(
      title: Text(Filters().districtsMap[dist]![index]),
      value:
          widget.lastChosen.contains(Filters().districtsMap[dist]![index])
              ? true
              : _chosen.contains(Filters().districtsMap[dist]![index]),
      onChanged: (val) {
        setState(
          () {
            val!
                ? _chosen.add(Filters().districtsMap[dist]![index])
                : _chosen.remove(Filters().districtsMap[dist]![index]);
            if (!val) {
              widget.lastChosen
                  .remove(Filters().districtsMap[dist]![index]);
            }
          },
        );
      },
    );
  }

  // Create the categories checkbox list, and handles
  // the selecting process for the UI.
  CheckboxListTile checkBoxListCategories(int index) {
    return CheckboxListTile(
      title: Text(_texts[index]),
      value:
          widget.lastChosen.contains(_texts[index]) ? true : _isChecked[index],
      onChanged: (val) {
        setState(
          () {
            if(widget.filterType == 'Category'){
              if (index == 0) {
                _isChecked = List<bool>.filled(_texts.length, val!);
                val ? _chosen = List.from(_texts) : _chosen.clear();
              } else {
                _isChecked[index] = val!;
                val ? _chosen.add(_texts[index]) : _chosen.remove(_texts[index]);
                _isChecked.every((element) => element == true)? _isChecked[0] = true : false;
                if (!val) {
                  widget.lastChosen.remove(_texts[index]);

                  _isChecked[0] = val;
                }
              }
            } else{
              if (!val!) {
                _isChecked[index] = val;
                _chosen.remove(_texts[index]);
                widget.lastChosen.remove(_texts[index]);
              } else {
                if (_chosen.length < 3 && val) {
                  _chosen.add(_texts[index]);
                  _isChecked[index] = val;
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              }
            }
          },
        );
      },
    );
  }

  ListView listViewCategories() {
    return ListView.builder(
        itemCount: _texts.length,
        itemBuilder: (context, index) {
          return checkBoxListCategories(index);
        });
  }

  ListView listViewCities() {
    return ListView.builder(
        itemCount: _texts.length,
        itemBuilder: (context, index) {
          return checkBoxListCategories(index);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: FittedBox(
              fit: BoxFit.fitWidth, child: Text(['Category', 'CategoryAdd'].contains(widget.filterType) ? 'Choose Categories' : 'Choose ${widget.filterType}')),
          actions: [

            TextButton(onPressed: () => {
              setState(() {
                _isChecked = List<bool>.filled(_texts.length, false);
                _chosen.clear();
                widget.lastChosen.clear();
              })
            }, child: const Text('Clear All', style: TextStyle(color: Colors.white))),
          ],
          leading: IconButton(
              onPressed: () => {
                    Navigator.pop(context, _chosen),
                  },
              icon: const Icon(Icons.arrow_back))),
      body: ['Category', 'CategoryAdd'].contains(widget.filterType)
          ? listViewCategories()
          : listViewCheck(),
    );
  }
}
