import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pickeep/set_item_screen.dart';
import 'package:pickeep/filter_screen.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'package:pickeep/item.dart';
import 'package:pickeep/item_screen.dart';
import 'package:pickeep/sign_screens/contact_info_screen.dart';
import 'package:pickeep/sign_screens/sign_main_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pickeep/favorites.dart';
import 'current_user_info.dart';
import 'firestore/firestore_users.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// The class handles the main screen of the application, i.e. all the navigation flow
// around the app surrounds this screen, which composed mainly from three tabs:
// scroll view, user’s favorite items and items uploaded by the logged in user.
// Furthermore the class handles the view of all the items from a specific user -
// this option required a uid field (see below).
// Class fields:
// 1. String filterType - Holds one of the values :None, Category, City, Both.
// 2. List chosenCat - list of the chosen categories to filter by.
// 3. List chosenCities - list of the chosen cities to filter by.
// 4. String uid - holds the user id of a user, required for altering the Home
// Screen in order to show user’s items. holds the string ”current” when the
// class shows the normal Home Screen.
class HomeScreen extends StatefulWidget {
  final String uid;
  const HomeScreen({Key? key, this.uid = "current"}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late List _chosenCat = [];
  late List _chosenCities = [];

  Widget streamBuilder(String tabType) {
    return StreamBuilder<QuerySnapshot>(
        stream: (tabType == 'home' || tabType == 'favorites')
            ? FirestoreItems.instance().getItemsOrderByUploadTime()
            : FirestoreItems.instance().getItemsByUser(widget.uid == "current"
                ? FirebaseAuth.instance.currentUser!.uid
                : widget.uid),
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
          message = _chosenCat.isNotEmpty
              ? message + _chosenCat.toString()
              : "${message}all";
          message = "$message categories";
          message = "$message from ";
          message =
              _chosenCities.isNotEmpty ? "${message}chosen" : "${message}all";
          message = "$message cities ";
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
                                    });
                                  });
                                },
                                child: const Text(
                                  "Category",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  semanticsLabel: "Filter by category",
                                ))),
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FilterScreen(
                                              filterType: 'City',
                                              lastChosen: _chosenCities,
                                            )),
                                  ).then((value) {
                                    setState(() {
                                      _chosenCities = value;
                                    });
                                  });
                                },
                                child: const Text("City",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    semanticsLabel: "Filter by City"))),
                      ])
                    : Container(),
                Expanded(
                  child: LayoutBuilder(builder: (context, constraint) {
                    return OrientationBuilder(builder: (context, orientation) {
                      List<QueryDocumentSnapshot> data =
                          snapshot.requireData.docs;

                      if (tabType == 'home') {
                        if (_chosenCities.isNotEmpty) {
                          data = data
                              .where((element) => _chosenCities
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
                        data = data
                            .where((element) => Favorites().contain(element.id))
                            .toList();
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
                                image: NetworkImage(item.imagePath!),
                                frameBuilder: (context, child, frame,
                                    wasSynchronouslyLoaded) {
                                  return child;
                                },
                                errorBuilder:
                                    (context, child, loadingProgress) {
                                  return const FittedBox(
                                    fit: BoxFit.fill,
                                    child: Center(
                                        heightFactor: 3,
                                        widthFactor: 3,
                                        child:
                                            Icon(Icons.signal_wifi_off_sharp)),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                                semanticLabel: item.name,
                                fit: BoxFit.fill,
                              ),
                              onTap: () async {
                                var connectivityResult =
                                    await (Connectivity().checkConnectivity());
                                if (connectivityResult ==
                                        ConnectivityResult.mobile ||
                                    connectivityResult ==
                                        ConnectivityResult.wifi ||
                                    connectivityResult ==
                                        ConnectivityResult.ethernet) {
                                  Map<String, dynamic> user;
                                  if (uid !=
                                      FirebaseAuth.instance.currentUser!.uid) {
                                    user = await FirestoreUser()
                                        .tryGetUserInfo(uid);
                                  } else {
                                    user = CurrentUserInfo().user.toJson();
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ItemScreen(
                                            item: item,
                                            itemId: itemId,
                                            uid: uid,
                                            user: user,
                                            fromHome: widget.uid == "current"
                                                ? true
                                                : false)),
                                  ).then((value) => {setState((){})});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Please check your internet connection")));
                                }
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
            title: Text(widget.uid == "current"
                ? 'Home Screen'
                : "${CurrentUserInfo().user.firstName} ${CurrentUserInfo().user.lastName}"),
            actions: [
              Visibility(
                  visible: widget.uid == "current",
                  child: IconButton(
                      onPressed: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ContactInfoScreen(isEdit: true)),
                            ).then((_) => {setState(() {})})
                          },
                      icon: const Icon(Icons.person,
                          semanticLabel: "My Profile"))),
              IconButton(
                  onPressed: () async {
                    await Provider.of<FirebaseAuthenticationNotifier>(context,
                            listen: false)
                        .signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const SignMainScreen()),
                        (route) => false);
                  },
                  icon: const Icon(Icons.logout, semanticLabel: "Sign Out"))
            ],
            bottom: widget.uid == "current"
                ? const TabBar(tabs: [
                    Tab(
                      icon: Icon(
                        Icons.home,
                        semanticLabel: "Home",
                      ),
                    ),
                    Tab(
                        icon: Icon(
                      Icons.star,
                      semanticLabel: "Favorite Items",
                    )),
                    Tab(
                      icon: Icon(Icons.folder, semanticLabel: "My Items"),
                    )
                  ])
                : null,
          ),
          body: widget.uid == "current"
              ? TabBarView(
                  children: [
                    //true for home and false for current user items
                    streamBuilder('home'),
                    streamBuilder('favorites'),
                    streamBuilder('userItem')
                  ],
                )
              : streamBuilder('userItem'),
          floatingActionButton: widget.uid == "current"
              ? FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () async => await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SetItemScreen()),
                  ),
                )
              : null,
        ));
  }
}
