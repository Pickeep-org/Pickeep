import 'package:flutter/material.dart';
import 'package:pickeep/favorites.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'package:pickeep/home_screen.dart';
import 'package:pickeep/item.dart';
import 'package:pickeep/firestore/firestore_users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pickeep/user_items_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:pickeep/contact_info.dart';
import 'package:share_plus/share_plus.dart';

Future<ContactInfo> getUserInfo(String uid) async {
  return ContactInfo.fromJason(await FirestoreUser().tryGetUserInfo(uid));
}

List<PopupMenuItem<String>> popUpMenuItems(String uid) {
  List<PopupMenuItem<String>> popupMenuItems = [];
  popupMenuItems.add(const PopupMenuItem(child: Text("edit information"), value: "edit information"));
  return popupMenuItems;
}

class UserScreen extends StatefulWidget {
  //const UserScreen({Key? key, this.title = "UserScreen"}) : super(key: key);
  ContactInfo contactInfo;
  final bool fromHome;
  // final bool isChecked;

  UserScreen(
      {Key? key,
        required this.contactInfo,
        required this.fromHome,
      // required this.isChecked
      })
      : super(key: key);
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  //late ContactInfo userInfo;// = aw getUserInfo(uid);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('User Screen'),
          leading: IconButton(
              onPressed: () => {Navigator.pop(context)},
              icon: const Icon(Icons.arrow_back)),
          actions: [
                IconButton(
                    onPressed: () => {
                      /*
                      Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => EditUserScreen(
                      item: widget.item, itemId: widget.itemId)),
                      ).then((value) {
                      setState(() {
                      if (value != null) {
                      widget.item = value;
                      }
                      });
                      });*/
                      },
                    icon: const Icon(Icons.edit)),
            widget.fromHome
            ? Container()  : Container()
          ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.contactInfo.firstName + " " + widget.contactInfo.lastName,
                      style: const TextStyle(
                        fontSize: 26,
                      )),
                  const SizedBox(height: 10),
                  Text(widget.contactInfo.lastName,
                      style: const TextStyle(
                        fontSize: 18,
                      )),
                  Divider(
                    height: 30,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  Text('Location: ${widget.contactInfo.city}',
                      style: const TextStyle(
                        fontSize: 18,
                      )),
                  const SizedBox(height: 6),
                  const Text("Categories",
                      style: TextStyle(
                        fontSize: 18,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
      //),
    );
  }
}