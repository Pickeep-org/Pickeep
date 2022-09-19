import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pickeep/add_item_screen.dart';
import 'package:pickeep/filter_screen.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'package:pickeep/item.dart';
import 'package:pickeep/item_screen.dart';
import 'package:pickeep/sign_screens/sign_home_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pickeep/favorites.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final duration = const Duration(milliseconds: 300);
  late List _chosenCat = [];
  late List _choseLoc = [];

  Widget streamBuilder(String tabType) {
    return StreamBuilder<QuerySnapshot>(
        stream: tabType == 'home'
            ? FirestoreItems.instance().getItemsOrderByName(_chosenCat)
            : tabType == 'favorites'
                ? FirestoreItems.instance().getItemsByIdsList(Favorites().get())
                : FirestoreItems.instance()
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
                      ])
                    : Container(),
                Expanded(
                  child: GridView.builder(
                    itemCount: snapshot.requireData.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      Item item = Item.fromJason(
                          snapshot.requireData.docs[index]['item']);
                      String itemId = snapshot.requireData.docs[index].id;
                      String uid = snapshot.requireData.docs[index]['uid'];
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
                                      fromHome: true)),
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
        });
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
