import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pickeep/add_item_screen.dart';
import 'package:pickeep/filter_screen.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'package:pickeep/item.dart';
import 'package:pickeep/item_screen.dart';
import 'package:pickeep/sign_screens/new_sign.dart';
import 'package:pickeep/sign_screens/sign_home_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pickeep/favorites.dart';
import 'package:pickeep/edit_user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final duration = const Duration(milliseconds: 300);
  late String filterType = 'None';
  late List _chosenCat = [];
  late List _choseLoc = [];

  Widget streamBuilder(String tabType) {
    return StreamBuilder<QuerySnapshot>(
        stream: (tabType == 'home' || tabType == 'favorites')
            ? FirestoreItems.instance().getItemsOrderByName()
            : FirestoreItems.instance()
                .getItemsByUser(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Container();
          }
          String message = "Items of ";
          message = _chosenCat.isNotEmpty ? message + _chosenCat.toString() : message + "all";
          message = message + " categories";
          message = message + " from ";
          message = _choseLoc.isNotEmpty ? message + "chosen" : message + "all";
          message = message + " locations ";
          SemanticsService.announce(message, TextDirection.ltr);
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tabType == 'home'
                    ? Row(children: [
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FilterScreen(
                                              filterType: 'Category',
                                              lastChosen: _chosenCat,
                                            )),
                                  ).then((value) {
                                    setState(() {
                                      _chosenCat = value;
                                      if (_chosenCat.isNotEmpty) {
                                        filterType = ['Location', 'Both']
                                                .contains(filterType)
                                            ? 'Both'
                                            : 'Category';
                                      } else {
                                        filterType = filterType == 'Both'
                                            ? 'Location'
                                            : 'None';
                                      }
                                    });
                                  });
                                },
                                child: const Text("Category", semanticsLabel: "Filter by category",))),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FilterScreen(
                                              filterType: 'Location',
                                              lastChosen: _choseLoc,
                                            )),
                                  ).then((value) {
                                    setState(() {
                                      _choseLoc = value;
                                      if (_choseLoc.isNotEmpty) {
                                        filterType = ['Category', 'Both']
                                                .contains(filterType)
                                            ? 'Both'
                                            : 'Location';
                                      } else {
                                        filterType = ['Category', 'Both']
                                                .contains(filterType)
                                            ? 'Category'
                                            : 'None';
                                      }
                                    });
                                  });
                                },
                                child: const Text("Location", semanticsLabel: "Filter by location"))),
                      ])
                    : Container(),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraint) {
                    return OrientationBuilder(builder: (context, orientation) {
                      List<QueryDocumentSnapshot> data = snapshot.requireData.docs;

                      if (tabType == 'home') {
                        if (_choseLoc.isNotEmpty) {
                          data = data
                              .where((element) => _choseLoc
                                  .contains(element['item']['location']))
                              .toList();
                        }

                        if (_chosenCat.isNotEmpty) {
                          data = data
                              .where((element) =>
                                  test1(element['item']['categories']))
                              .toList();
                        }
                      } else if (tabType == 'favorites') {
                        data = data.where((element) => Favorites().get().contains(element.id)).toList();
                      }

                      return GridView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          Item item = Item.fromJason(data[index]['item']);
                          String itemId = data[index].id;
                          String uid = data[index]['uid'];
                          return Container(
                            padding: const EdgeInsets.all(5),
                            child: GestureDetector(
                              child: Image(
                                image: NetworkImage(item.image), semanticLabel: item.name,
                                fit: BoxFit.fill,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ItemScreen(
                                          item: item,
                                          itemId: itemId,
                                          uid: uid,
                                          fromHome: true)),
                                );
                              },
                            ),
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: constraint.maxWidth < 1280
                                ? orientation == Orientation.portrait
                                    ? 2
                                    : 3
                                : orientation == Orientation.portrait
                                    ? 4
                                    : 6),
                      );
                    });
                  }),
                ),
              ]);
        });
  }

  bool test1(List categories) {
    bool flag = false;

    for (int i = 0; i < categories.length; i++) {
      if (_chosenCat.contains(categories[i])) {
        flag = true;

        break;
      }
    }

    return flag;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Home Screen',),
            actions: [
              IconButton(onPressed: () => {
        Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => EditProfileScreen()),
        ).then((_) => {  setState(() {})})


        }, icon: const Icon(Icons.person, semanticLabel: "My Profile")),
              IconButton(
                  onPressed: () async {
                    await Provider.of<FirebaseAuthenticationNotifier>(context,
                            listen: false)
                        .signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const SignInPage()),
                        (route) => false);
                  },
                  icon: const Icon(
                    Icons.logout, semanticLabel: "Sign Out"
                  ))
            ],
            bottom: const TabBar(tabs: [
              Tab(
                icon: Icon(Icons.home, semanticLabel: "Home",),
              ),
              Tab(icon: Icon(Icons.star, semanticLabel: "Favorite Items",)),
              Tab(
                icon: Icon(Icons.folder, semanticLabel: "My Items"),
              )
            ]),
          ),
          body: TabBarView(
            children: [
              //true for home and false for current user items
              streamBuilder('home'),
              streamBuilder('favorites'),
              streamBuilder('userItem')
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async => await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddItemScreen()),
            ),
          ),
        ));
  }
}
