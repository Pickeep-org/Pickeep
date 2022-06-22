import 'package:flutter/material.dart';
import 'package:pickeep/filters.dart';

class FilterList {
  List<String> getList(String filterType) {
    return filterType == 'Category' ? Filters().categories : Filters().locations;
  }
}

class FilterScreen extends StatefulWidget {
  final String filterType;
  const FilterScreen({Key? key, required this.filterType}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _FilterState();
}

class _FilterState extends State<FilterScreen> {
  late List<bool> _isChecked;
  late List<String> _texts;
  @override
  void initState() {
    super.initState();
    _texts = FilterList().getList(widget.filterType);
    _texts.insert(0, "all");
    _isChecked = List<bool>.filled(_texts.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FILTER",
      home: Scaffold(
        appBar: AppBar(
            title: Text('Choose ${widget.filterType}'),
            actions: [
              ElevatedButton(
                  onPressed: () => {
                        setState(() {
                          _isChecked = List<bool>.filled(_texts.length, false);
                        })
                      },
                  child: const Text('Clear All')),
              IconButton(onPressed: () => {}, icon: const Icon(Icons.more_vert))
            ],
            leading: IconButton(
                onPressed: () => {Navigator.pop(context)},
                icon: const Icon(Icons.arrow_back))),
        body: ListView.builder(
          itemCount: _texts.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              title: Text(_texts[index]),
              value: _isChecked[index],
              onChanged: (val) {
                setState(
                  () {
                    index == 0
                        ? _isChecked = List<bool>.filled(_texts.length, val!)
                        : _isChecked[index] = val!;
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
