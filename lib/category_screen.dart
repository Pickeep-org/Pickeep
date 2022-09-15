import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pickeep/filters.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _CategoryState();
}

class _CategoryState extends State<CategoryScreen> {
  late List<bool> _isChecked;
  late bool isScrolled = true;
  final duration = const Duration(milliseconds: 300);
  late List<String> _texts;
  final List<String> _chosen = [];
  final snackBar =
      const SnackBar(content: Text('Please choose up to 3 categories'));
  @override
  void initState() {
    super.initState();
    _texts = Filters().categories;
    _isChecked = List<bool>.filled(_texts.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const FittedBox(
              fit: BoxFit.fitWidth,
              child: Text('Choose Category')),
            actions: [
              ElevatedButton(
                  onPressed: () => {
                        setState(() {
                          _isChecked = List<bool>.filled(_texts.length, false);
                          _chosen.clear();
                        })
                      },
                  child: const Text('Clear All')),
              IconButton(onPressed: () => {}, icon: const Icon(Icons.more_vert))
            ],
            leading: IconButton(
                onPressed: () => {Navigator.pop(context)},
                icon: const Icon(Icons.arrow_back))),
        body: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              final ScrollDirection direc = notification.direction;
              setState(() {
                if (direc == ScrollDirection.reverse) {
                  isScrolled = false;
                } else if (direc == ScrollDirection.forward) {
                  isScrolled = true;
                }
              });
              return true;
            },
            child: ListView.builder(
              itemCount: _texts.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_texts[index]),
                  value: _isChecked[index],
                  onChanged: (val) {
                    setState(
                      () {
                        if (!val!) {
                          _isChecked[index] = val;
                          _chosen.remove(_texts[index]);
                          return;
                        }
                        if (_chosen.length < 3 && val) {
                          _isChecked[index] = val;
                          _chosen.add(_texts[index]);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                    );
                  },
                );
              },
            )),
        floatingActionButton: AnimatedSlide(
          duration: duration,
          offset: isScrolled ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: duration,
            opacity: isScrolled ? 1 : 0,
            child: FloatingActionButton(
              child: const Icon(Icons.done),
              onPressed: () {
                Navigator.pop(context, _chosen);
              },
            ),
          ),
        ),
      );
  }
}
