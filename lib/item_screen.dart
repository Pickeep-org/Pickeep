import 'package:flutter/material.dart';
import 'package:pickeep/custom_icons_icons.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'package:pickeep/item.dart';
import 'package:pickeep/firestore/firestore_users.dart';
import 'package:pickeep/edit_item_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:pickeep/contact_info.dart';

Future<ContactInfo> getUserInfo(String uid) async {
  return ContactInfo.fromJason(await FirestoreUser().tryGetUserInfo(uid));
}

List<PopupMenuItem<String>> popUpMenuItems(String uid) {
  List<PopupMenuItem<String>> popupMenuItems = [
    const PopupMenuItem(child: Text("Owner Info"), value: "Owner Info")
  ];
  if (uid == FirebaseAuth.instance.currentUser!.uid) {
    popupMenuItems.add(
        const PopupMenuItem(child: Text("Delete item"), value: "Delete item"));
  }
  return popupMenuItems;
}

Future deleteItem(String itemId) {
  return FirestoreItems.instance().removeItem(itemId);
}

class ItemScreen extends StatefulWidget {
  //const ItemScreen({Key? key, this.title = "ItemScreen"}) : super(key: key);
  Item item;
  final String itemId;
  final String uid;
  final bool isChecked;

  ItemScreen(
      {Key? key,
      required this.item,
      required this.itemId,
      required this.uid,
      required this.isChecked})
      : super(key: key);
  @override
  _ItemScreenState createState() => _ItemScreenState();

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget noButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );
    Widget yesButton = TextButton(
      child: const Text("Yes"),
      onPressed: () async {
        // await FirestoreItems.instance().removeItem(itemId);
        Navigator.of(context).pop(true);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Attention"),
      content: const Text("Are you sure do you want to delete this item?"),
      actions: [
        noButton,
        yesButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class _ItemScreenState extends State<ItemScreen> {
  late bool isChecked;
  late ContactInfo userInfo;
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Item Screen'),
          leading: IconButton(
              onPressed: () => {Navigator.pop(context, isChecked)},
              icon: const Icon(Icons.arrow_back)),
          actions: [
            widget.uid == FirebaseAuth.instance.currentUser!.uid
                ? IconButton(
                    onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditItemScreen(
                                    item: widget.item, itemId: widget.itemId)),
                          ).then((value) {
                            setState(() {
                              if (value != null) {
                                widget.item = value;
                              }
                            });
                          })
                        },
                    icon: const Icon(Icons.edit))
                : Container(),
            IconButton(
                onPressed: () async {
                  if (isChecked) {
                    await FirestoreUser().remveItemFromFavorite(
                        FirebaseAuth.instance.currentUser!.uid, widget.itemId);
                  } else {
                    await FirestoreUser().addNewFavorite(
                        FirebaseAuth.instance.currentUser!.uid, widget.itemId);
                  }
                  setState(() {
                    if (isChecked) {
                      isChecked = false;
                    } else {
                      isChecked = true;
                    }
                  });
                },
                icon: isChecked
                    ? const Icon(Icons.star)
                    : const Icon(Icons.star_border)),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => popUpMenuItems(widget.uid),
              onSelected: (String? val) {
                if (val == "Delete item") {
                  widget.showAlertDialog(context);
                }
              },
            )
          ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image(
                image: NetworkImage(widget.item.image), fit: BoxFit.fitWidth),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.item.name,
                      style: const TextStyle(
                        fontSize: 26,
                      )),
                  const SizedBox(height: 10),
                  Text(widget.item.description,
                      style: const TextStyle(
                        fontSize: 18,
                      )),
                  Divider(
                    height: 30,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  Text('Location: ${widget.item.location}',
                      style: const TextStyle(
                        fontSize: 18,
                      )),
                  const SizedBox(height: 6),
                  const Text("Categories",
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  Wrap(
                    direction: Axis.horizontal,
                    spacing: 5,
                    children: widget.item.categories
                        .map((e) => Chip(label: Text(e)))
                        .toList(),
                  ),
                  widget.uid != FirebaseAuth.instance.currentUser!.uid
                      ? FutureBuilder<ContactInfo>(
                          future: getUserInfo(widget.uid),
                          builder: (context, contactInfo) {
                            if (contactInfo.hasData) {
                              userInfo = contactInfo.data!;
                              return Row(
                                children: [
                                  const Text('Contact Owner:',
                                      style: TextStyle(
                                        fontSize: 18,
                                      )),
                                  IconButton(
                                      onPressed: () {
                                        openPhone(
                                            userInfo.phoneNumber, context);
                                      },
                                      icon: const Icon(Icons.local_phone)),
                                  IconButton(
                                      onPressed: () {
                                        String message = "Hello " +
                                            userInfo.firstName +
                                            ", i saw your item " +
                                            widget.item.name;
                                        openSMS(userInfo.phoneNumber, message,
                                            context);
                                      },
                                      icon: const Icon(Icons.sms)),
                                  IconButton(
                                    onPressed: () {
                                      String message = "Hello " +
                                          userInfo.firstName +
                                          ", i saw your item " +
                                          widget.item.name;
                                      openWhatsapp(userInfo.phoneNumber,
                                          message, context);
                                    },
                                    icon: const Icon(Icons.whatsapp),
                                    alignment: Alignment.topLeft,
                                  ),
                                ],
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          })
                      : Container()
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

openWhatsapp(String phoneNumber, String message, BuildContext context) async {
  Uri whatsappUrlAndroid =
      Uri.parse("whatsapp://send?phone=" + phoneNumber + "&text=" + message);
  Uri whatappUrlIos =
      Uri.parse("https://wa.me/$phoneNumber?text=${Uri.parse(message)}");
  if (Platform.isIOS) {
    // for iOS phone only
    await canLaunchUrl(whatappUrlIos)
        ? await launchUrl(whatappUrlIos)
        : ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp no installed")));
  } else {
    // android , web
    await canLaunchUrl(whatsappUrlAndroid)
        ? await launchUrl(whatsappUrlAndroid)
        : ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp no installed")));
  }
}

openSMS(String phoneNumber, String message, BuildContext context) async {
  Uri sms = Uri.parse('sms:' + phoneNumber + '?body=' + message);
  await canLaunchUrl(sms)
      ? await launchUrl(sms)
      : ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error in sending sms")));
}

openPhone(String phoneNumber, BuildContext context) async {
  Uri phone = Uri.parse('tel:' + phoneNumber);
  await canLaunchUrl(phone)
      ? await launchUrl(phone)
      : ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error in calling owner")));
}
