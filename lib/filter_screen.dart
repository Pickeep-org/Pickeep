import 'package:flutter/material.dart';
import 'package:pickeep/filters.dart';

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
  late List<String> _texts = [];
  late List _chosen = [];
  final snackBar =
  const SnackBar(content: Text('Please choose up to 3 categories'));
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
  List<Widget> _getChildren(int count, String name) => List<Widget>.generate(
        count,
        (i) => ListTile(title: Text('$name$i')),
      );

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

  ListView ListViewCategories() {
    return ListView.builder(
        itemCount: _texts.length,
        itemBuilder: (context, index) {
          return checkBoxListCategories(index);
        });
  }

  ListView ListViewCities() {
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
          ? ListViewCategories()
          : listViewCheck(),
    );
  }
}
