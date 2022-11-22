import 'package:flutter/material.dart';
import 'package:pickeep/set_item_screen.dart';
import 'package:pickeep/favorites.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'package:pickeep/item.dart';
import 'package:pickeep/firestore/firestore_users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pickeep/user_items_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:pickeep/contact_info.dart';
import 'package:share_plus/share_plus.dart';

Future deleteItem(String itemId) {
  return FirestoreItems.instance().removeItem(itemId);
}

class ItemScreen extends StatefulWidget {
  //const ItemScreen({Key? key, this.title = "ItemScreen"}) : super(key: key);
  Item item;
  final String itemId;
  final String uid;
  final bool showViewMoreOwnerItemsOption;
  late Map<String, dynamic> user;

  ItemScreen(
      {Key? key,
      required this.item,
      required this.itemId,
      required this.uid,
      required this.showViewMoreOwnerItemsOption,
      required this.user})
      : super(key: key);
  @override
  _ItemScreenState createState() => _ItemScreenState();

  showAlertDialog(BuildContext context) {
    Widget noButton = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );
    Widget yesButton = TextButton(
      child: const Text("Yes"),
      onPressed: () async {
        await FirestoreItems.instance().removeItem(itemId);
        Navigator.of(context).pop(true);
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Attention"),
      content: const Text("Are you sure do you want to delete this item?"),
      actions: [
        noButton,
        yesButton,
      ],
    );

    // show the dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class _ItemScreenState extends State<ItemScreen> {
  late bool isFavorite;
  late ContactInfo userInfo;
  late bool _isCurrentUserItem;

  @override
  void initState() {
    super.initState();
    _isCurrentUserItem = widget.uid == FirebaseAuth.instance.currentUser!.uid;
    isFavorite = Favorites().contain(widget.itemId);
    userInfo = ContactInfo.fromJason(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.item.name), actions: getActions(context)),
      body: Column(
        children: [
          Expanded(
              flex: 3,
              child: Container(
                constraints: const BoxConstraints.expand(),
                child: Image(
                  image: NetworkImage(widget.item.imagePath!),
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    return child;
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                  semanticLabel: widget.item.name,
                  fit: BoxFit.cover,
                ),
              )),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(widget.item.description,
                      style: const TextStyle(
                        fontSize: 18,
                      )),
                  Divider(
                    height: 30,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  Text('Location: ${widget.item.city}',
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
                  Visibility(
                    visible:
                        widget.uid != FirebaseAuth.instance.currentUser!.uid,
                    child: Row(
                      children: [
                        const Text('Contact Owner:',
                            style: TextStyle(
                              fontSize: 18,
                            )),
                        IconButton(
                            onPressed: () {
                              openPhone(userInfo.phoneNumber, context);
                            },
                            icon: const Icon(Icons.local_phone,
                                semanticLabel: "Contact owner via phone")),
                        IconButton(
                            onPressed: () {
                              String message =
                                  "Hello ${userInfo.firstName} , i saw your item ${widget.item.name}";
                              openSMS(userInfo.phoneNumber, message, context);
                            },
                            icon: const Icon(Icons.sms,
                                semanticLabel: "Contact owner via SMS")),
                        IconButton(
                          onPressed: () {
                            String message =
                                "Hello ${userInfo.firstName} , i saw your item ${widget.item.name}";

                            openWhatsapp(
                                userInfo.phoneNumber, message, context);
                          },
                          icon: const Icon(Icons.whatsapp,
                              semanticLabel: "Contact owner via WhatsApp"),
                          alignment: Alignment.topLeft,
                        ),
                        Visibility(
                          visible: widget.item.address != "",
                          child: IconButton(
                              onPressed: () {
                                String address =
                                    "${widget.item.address}, ${widget.item.city}";
                                openMaps(address, context);
                              },
                              icon: const Icon(Icons.navigation_sharp,
                                  semanticLabel: "Navigate to Item")),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Visibility(
                      visible: _isCurrentUserItem,
                      child: ElevatedButton(
                        child: const Text('Edit',
                            style: TextStyle(
                              fontSize: 18,
                            )),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SetItemScreen(
                                    curItem: widget.item,
                                    itemId: widget.itemId))),
                      )),
                  Visibility(
                      visible: _isCurrentUserItem,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('Delete',
                            style: TextStyle(
                              fontSize: 18,
                            )),
                        onPressed: () async => {
                          if (await widget.showAlertDialog(context))
                            {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst)
                            }
                        },
                      )),
                  Visibility(
                      visible: widget.showViewMoreOwnerItemsOption &&
                          !_isCurrentUserItem,
                      child: ElevatedButton(
                        child: const Text('View more owner items',
                            style: TextStyle(
                              fontSize: 18,
                            )),
                        onPressed: () async => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserItemsScreen(
                                      uid: widget.uid,
                                      userName:
                                          "${userInfo.firstName} ${userInfo.lastName}",
                                    )),
                          ).then((value) {
                            setState(() {
                              isFavorite = Favorites().contain(widget.itemId);
                            });
                          })
                        },
                      ))
                ],
              )),
        ],
      ),
      //),
    );
  }

  List<Widget> getActions(BuildContext context) {
    List<Widget> actions = [];

    if (!_isCurrentUserItem) {
      actions.add(IconButton(
          onPressed: () async {
            if (isFavorite) {
              await FirestoreUser().removeItemFromFavorite(
                  FirebaseAuth.instance.currentUser!.uid, widget.itemId);
              Favorites().remove(widget.itemId);
            } else {
              await FirestoreUser().addNewFavorite(
                  FirebaseAuth.instance.currentUser!.uid, widget.itemId);
              Favorites().add(widget.itemId);
            }
            setState(() {
              if (isFavorite) {
                isFavorite = false;
              } else {
                isFavorite = true;
              }
            });
          },
          icon: isFavorite
              ? const Icon(Icons.star, semanticLabel: "remove from favorites")
              : const Icon(Icons.star_border,
                  semanticLabel: "add to favorites")));
    }

    actions.add(IconButton(
        onPressed: () => {Share.share("something")},
        icon: const Icon(
          Icons.share,
          semanticLabel: "Share",
        )));

    return actions;
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

openMaps(String address, BuildContext context) async {
  String add = Uri.encodeComponent(address);
  //Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$add");
  Uri url = Uri.parse("geo:0,0?q=$add");
  await canLaunchUrl(url)
      ? await launchUrl(url)
      : ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error in open google maps")));
}

openWeb() async {
  const url = 'https://www.google.com';
  Uri rt = Uri.parse(url);
  await launchUrl(rt);
}
