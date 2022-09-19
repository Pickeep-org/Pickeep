import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pickeep/add_item_screen.dart';
import 'package:pickeep/filter_screen.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'package:pickeep/firestore/firestore_users.dart';
import 'package:pickeep/item.dart';
import 'package:pickeep/item_screen.dart';
import 'package:pickeep/sign_screens/sign_home_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pickeep/contact_info.dart';

Future<List<String>> getFavorites(String uid) async {
  return FirestoreUser().getUserFavorites(uid);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late bool _isChecked;

  final duration = const Duration(milliseconds: 300);
  List<String> favorites = [];
  late List _chosenCat = [];
  late List _choseLoc = [];
  @override
  void initState() {
    super.initState();
    _isChecked = false;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Home Screen'),
            actions: [
              IconButton(onPressed: () => {}, icon: const Icon(Icons.person)),
              IconButton(
                  onPressed: () async {
                    await Provider.of<FirebaseAuthenticationNotifier>(context,
                            listen: false)
                        .signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                SignHomeScreen()),
                        (route) => false);
                  },
                  icon: const Icon(
                    Icons.logout,
                  ))
            ],
            bottom: const TabBar(tabs: [
              Tab(
                icon: Icon(Icons.home),
              ),
              Tab(icon: Icon(Icons.star)),
              Tab(
                icon: Icon(Icons.folder),
              )
            ]),
          ),
          body: TabBarView(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream:
                      FirestoreItems.instance().getItemsOrderByName(_chosenCat),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
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
                                        });
                                      });
                                    },
                                    child: const Text("Category"))),
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
                                        });
                                      });
                                    },
                                    child: const Text("Location"))),
                          ]),
                          Expanded(
                            child: GridView.builder(
                              itemCount: snapshot.requireData.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                Item item = Item.fromJason(
                                    snapshot.requireData.docs[index]['item']);
                                String itemId =
                                    snapshot.requireData.docs[index].id;
                                String uid =
                                    snapshot.requireData.docs[index]['uid'];
                                bool isChecked = false;
                                if (favorites.contains(itemId)) {
                                  isChecked = true;
                                }
                                return Container(
                                  padding: const EdgeInsets.all(5),
                                  child: GestureDetector(
                                    child: Image(
                                      image: NetworkImage(item.image),
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
                                                  isChecked: isChecked,
                                                )),
                                      ).then((value) {
                                        if (value != null) {
                                          setState(() {
                                            isChecked = value;
                                            if (!isChecked) {
                                              favorites.remove(itemId);
                                            }
                                          });
                                        }
                                      });
                                    },
                                  ),
                                );
                              },
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                            ),
                          ),
                        ]);
                  }),
              FutureBuilder<List<String>>(
                  future: getFavorites(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, ids) {
                    if (ids.hasData) {
                      favorites = ids.data!;
                      return StreamBuilder<QuerySnapshot>(
                          stream: FirestoreItems.instance()
                              .getItemsByIdsList(ids.data!),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Something went wrong');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: GridView.builder(
                                      itemCount:
                                          snapshot.requireData.docs.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        Item item = Item.fromJason(snapshot
                                            .requireData.docs[index]['item']);
                                        String itemId =
                                            snapshot.requireData.docs[index].id;
                                        String uid = snapshot
                                            .requireData.docs[index]['uid'];
                                        bool isChecked = true;
                                        return Container(
                                          padding: const EdgeInsets.all(5),
                                          child: GestureDetector(
                                            child: Image(
                                              image: NetworkImage(item.image),
                                              fit: BoxFit.fill,
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ItemScreen(
                                                          item: item,
                                                          itemId: itemId,
                                                          uid: uid,
                                                          isChecked: isChecked,
                                                        )),
                                              ).then((value) {
                                                setState(() {
                                                  if (value != null) {
                                                    setState(() {
                                                      isChecked = value;
                                                      if (!isChecked) {
                                                        favorites
                                                            .remove(itemId);
                                                      }
                                                    });
                                                  }
                                                });
                                              });
                                            },
                                          ),
                                        );
                                      },
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2),
                                    ),
                                  ),
                                ]);
                          });
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
              StreamBuilder<QuerySnapshot>(
                  stream: FirestoreItems.instance()
                      .getItemsByUser(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: GridView.builder(
                              itemCount: snapshot.requireData.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                Item item = Item.fromJason(
                                    snapshot.requireData.docs[index]['item']);
                                String itemId =
                                    snapshot.requireData.docs[index].id;
                                bool isChecked = false;
                                if (favorites.contains(itemId)) {
                                  isChecked = true;
                                }
                                return Container(
                                  padding: const EdgeInsets.all(5),
                                  child: GestureDetector(
                                    child: Image(
                                      image: NetworkImage(item.image),
                                      fit: BoxFit.fill,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ItemScreen(
                                                  item: item,
                                                  itemId: itemId,
                                                  uid: FirebaseAuth.instance
                                                      .currentUser!.uid,
                                                  isChecked: _isChecked,
                                                )),
                                      ).then((value) {
                                        setState(() {
                                          if (value != null) {
                                            setState(() {
                                              isChecked = value;
                                              if (!isChecked) {
                                                favorites.remove(itemId);
                                              }
                                            });
                                          }
                                        });
                                      });
                                    },
                                  ),
                                );
                              },
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2),
                            ),
                          ),
                        ]);
                  }),
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
