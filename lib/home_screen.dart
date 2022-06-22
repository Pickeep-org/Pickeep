import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pickeep/filter_screen.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/sign_screens/sign_home_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Item extends StatefulWidget {
  final int itemNo;
  const Item({Key? key, required this.itemNo}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  late ListResult itemsImages;
  late Uint8List imageFile;
  late int itemNo;
  var isInitialized = false;
  Reference storageRef = FirebaseStorage.instance.ref();
  getInfo() async {
    int maxSize = 1024 * 1024 * 1;
    storageRef
        .child("items/bed1.jpg")
        .getData(maxSize)
        .then((data) => {
              setState(() {
                imageFile = data!;
                isInitialized = true;
              })
            })
        .catchError((error) {});
  }

  @override
  void initState() {
    super.initState();
    itemNo = widget.itemNo;
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return isInitialized
          ?  Image.memory(
       imageFile,
         fit: BoxFit.cover,
       )
               : const Text("no data");
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
            itemBuilder: (context, index) => Item(itemNo: index),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
              mainAxisExtent: MediaQuery.of(context).size.width / 2,
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
              childAspectRatio: 1,
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
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
