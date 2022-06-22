import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pickeep/add_item_screen.dart';
import 'package:pickeep/filter_screen.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/sign_screens/sign_home_page.dart';
import 'package:provider/provider.dart';

class Item extends StatelessWidget {
  final int itemNo;
  const Item(
    this.itemNo,
  );
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(0.0),
            child: Image.network(
              'https://picsum.photos/250?image=10',
              fit: BoxFit.fill,
            ),
            width: MediaQuery.of(context).size.width,
            height: 20,
          ),
          Text('product $itemNo')
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late bool _isChecked;
  final duration = const Duration(milliseconds: 300);
  @override
  void initState() {
    super.initState();
    _isChecked = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen'), actions: [
        IconButton(
            onPressed: () async {
              await Provider.of<FirebaseAuthenticationNotifier>(context,
                      listen: false)
                  .signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) => SignHomeScreen()),
                  (route) => false);
            },
            icon: const Icon(
              Icons.logout,
            ))
      ]),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FilterScreen(
                                filterType: 'Category',
                              )),
                    );
                  },
                  child: const Text("Category"))),
          Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FilterScreen(
                                filterType: 'Location',
                              )),
                    );
                  },
                  child: const Text("Location"))),
        ]),
        NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            final ScrollDirection direc = notification.direction;
            setState(() {
              if (direc == ScrollDirection.reverse) {
                _isChecked = false;
              } else if (direc == ScrollDirection.forward) {
                _isChecked = true;
              }
            });
            return true;
          },
          child: Expanded(
              child: GridView.builder(
            itemCount: 20,
            itemBuilder: (context, index) => Item(index),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2,
            ),
          )),
        )
      ]),
      floatingActionButton: AnimatedSlide(
        duration: duration,
        offset: _isChecked ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: duration,
          opacity: _isChecked ? 1 : 0,
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async => await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddItemScreen()),
            ),
          ),
        ),
      ),
    );
  }
}
