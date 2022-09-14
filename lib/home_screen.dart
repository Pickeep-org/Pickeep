import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pickeep/add_item_screen.dart';
import 'package:pickeep/filter_screen.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'package:pickeep/item.dart';
import 'package:pickeep/item_screen.dart';
import 'package:pickeep/sign_screens/sign_home_page.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late bool _isChecked;
  final duration = const Duration(milliseconds: 300);
  List<String> _chosen = [];
  @override
  void initState() {
    super.initState();
    _isChecked = true;
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
                  stream: FirestoreItems.instance().getItemsOrderByName(),
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
                                            builder: (context) =>
                                                const FilterScreen(
                                                  filterType: 'Category',
                                                )),
                                      ).then((value) {
                                        if (value != null) {
                                          setState(() {
                                            _chosen = value;
                                          });
                                        }
                                      });
                                    },
                                    child: const Text("Category"))),
                            Expanded(
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const FilterScreen(
                                                  filterType: 'Location',
                                                )),
                                      );
                                    },
                                    child: const Text("Location"))),
                          ]),
                          Expanded(
                            child: GridView.builder(
                              itemCount: snapshot.requireData.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                Item item = Item.fromJason(
                                    snapshot.requireData.docs[index]['item']);

                                return Container(
                                  padding: const EdgeInsets.all(5),
                                  child: GestureDetector(
                                    child: Image(
                                      image: NetworkImage(
                                          'https://firebasestorage.googleapis.com/v0/b/pickeep-3341c.appspot.com/o/items%2F${item.image}?alt=media'),
                                      fit: BoxFit.fill,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ItemScreen(
                                                  item: item,
                                                )),
                                      );
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
              const Icon(Icons.star),
              StreamBuilder<QuerySnapshot>(
                  stream: FirestoreItems.instance()
                      .getItemsByUser("q0IAeCKcvfSF9dB8o6ejmcV3QQy2"),
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
                                return Container(
                                  padding: const EdgeInsets.all(5),
                                  child: GestureDetector(
                                    child: Image(
                                      image: NetworkImage(
                                          'https://firebasestorage.googleapis.com/v0/b/pickeep-3341c.appspot.com/o/items%2F${item.image}?alt=media'),
                                      fit: BoxFit.fill,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ItemScreen(
                                                  item: item,
                                                )),
                                      );
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
