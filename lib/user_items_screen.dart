import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pickeep/sign_screens/sign_home_page.dart';
import 'package:provider/provider.dart';
import 'contact_Info.dart';
import 'firebase_authentication/firebase_authentication_notifier.dart';
import 'firestore/firestore_items.dart';
import 'firestore/firestore_users.dart';
import 'item.dart';
import 'item_screen.dart';
import 'package:pickeep/favorites.dart';

class UserItemsScreen extends StatefulWidget {
  final String uid;
  final String userName;
  const UserItemsScreen({Key? key, required this.uid, required this.userName})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _UserItemState();
}

class _UserItemState extends State<UserItemsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Text(widget.userName + ' Items:')),
        actions: [
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
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirestoreItems.instance().getItemsByUser(widget.uid),
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
                        String itemId = snapshot.requireData.docs[index].id;
                        return Container(
                          padding: const EdgeInsets.all(5),
                          child: GestureDetector(
                            child: Image(
                              image: NetworkImage(item.image),
                              fit: BoxFit.fill,
                            ),
                            onTap: () async{
                              Map<String, dynamic> user = await FirestoreUser().tryGetUserInfo(widget.uid);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ItemScreen(
                                          item: item,
                                          itemId: itemId,
                                          uid: widget.uid,
                                          user: user,
                                          fromHome: false,
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
    );
  }
}
