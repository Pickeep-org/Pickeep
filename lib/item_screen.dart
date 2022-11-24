import 'package:flutter/material.dart';
import 'package:pickeep/home_screen.dart';
import 'package:pickeep/set_item_screen.dart';
import 'package:pickeep/favorites.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'package:pickeep/item.dart';
import 'package:pickeep/firestore/firestore_users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:pickeep/contact_info.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// The class handles the item’s view screen. If the user who view this screen is
// the owner of the item, the class allow this user to edit or delete the item. If the
// user is not the owner, the class allow the user to view more of the owner items
// (trigger the home screen, but in viewing items from a certain user mod(1.1)),
// and also a contact methods in order to contact the owner about this item. Class
// fields:
// 1. Item item - an instance of an item (2.1).
// 2. String uid - the user’s database Id.
// 3. String ItemId - the item’s database Id.
// 4. bool fromHome - a flag that get true if the last screen was Home screen,
// and false otherwise (happens when the last screen was the home screen
// but in view items from a certain user mod.
// 5. Map user - holds the owner information.
class ItemScreen extends StatefulWidget {
  //const ItemScreen({Key? key, this.title = "ItemScreen"}) : super(key: key);
  final Item item;
  final String itemId;
  final String uid;
  final Map<String, dynamic> user;
  final bool fromHome;
  const ItemScreen(
      {Key? key,
      required this.item,
      required this.itemId,
      required this.uid,
      required this.user,
      required this.fromHome})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _ItemScreenState();

  // This method triggered when the user press on the
  // image, and handles the view of the full image.
  showImageDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.network(item.imagePath!, fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.center,
                    child: MaterialButton(
                      shape: const CircleBorder(),
                      color: Colors.green.shade900,
                      child: const Icon(
                        Icons.close,
                        size: 25,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
              // child:
            ));
  }

  // Handles the delete message when a user press to delete
  // the item at view (only the owner of the item can trigger this method).
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
        String image = item.imagePath!.substring(
            item.imagePath!.indexOf("/items%2F") + "/items%2F".length,
            item.imagePath!.indexOf("?alt=media"));
        await FirestoreItems.instance().removeItem(itemId);
        final curref =
            firebase_storage.FirebaseStorage.instance.ref('items/$image');
        await curref.delete();
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
                  child: GestureDetector(
                    child: Image(
                      image: NetworkImage(widget.item.imagePath!),
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        return child;
                      },
                      errorBuilder: (context, child, loadingProgress) {
                        return const FittedBox(
                          fit: BoxFit.fill,
                          child: Center(
                              heightFactor: 3,
                              widthFactor: 3,
                              child: Icon(Icons.signal_wifi_off_sharp)),
                        );
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
                    onTap: () {
                      widget.showImageDialog(context);
                    },
                  ))),
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
                              icon: const Icon(Icons.pin_drop_sharp,
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
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Visibility(
                      visible: _isCurrentUserItem,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  semanticsLabel: "Edit this item",
                                ),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SetItemScreen(
                                            curItem: widget.item,
                                            itemId: widget.itemId))),
                              )),
                          const SizedBox(
                            width: 3,
                          ),
                          Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                // style: ElevatedButton.styleFrom(
                                //     backgroundColor: Colors.red),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  semanticsLabel: "Delete this item",
                                ),
                                onPressed: () async => {
                                  if (await widget.showAlertDialog(context))
                                    {
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst)
                                    }
                                },
                              ))
                        ],
                      )),
                  Visibility(
                      visible: !_isCurrentUserItem && widget.fromHome,
                      child: ElevatedButton(
                        child: const Text('View more items of this owner',
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        onPressed: () async => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                      uid: widget.uid,
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

  // Handles the logic of the favorites and share icons at the
  // appbar.
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
        onPressed: () => {
              Share.share(
                  "Hello, I want to share with you that I found ${widget.item.name} for free on Pickeep app!")
            },
        icon: const Icon(
          Icons.share,
          semanticLabel: "Share",
        )));

    return actions;
  }

  // Given a phone number and a message, this method
  // triggered when the whatsapp icon is pressed and handles the sending of a
  // message to the owner of the item.
  openWhatsapp(String phoneNumber, String message, BuildContext context) async {
    Uri whatsappUrlAndroid =
        Uri.parse("whatsapp://send?phone=$phoneNumber&text=$message");
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

  // Given a phone number and a message, this method triggered
  // when the SMS icon is pressed and handles the sending of a message to the
  // owner of the item.
  openSMS(String phoneNumber, String message, BuildContext context) async {
    Uri sms = Uri.parse('sms:$phoneNumber?body=$message');
    await canLaunchUrl(sms)
        ? await launchUrl(sms)
        : ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error in sending sms")));
  }

  // Given a phone number, this method triggered when the
  // Phone icon is pressed and hadles the connection with the local phone app
  // in order to place a call to the owner.
  openPhone(String phoneNumber, BuildContext context) async {
    Uri phone = Uri.parse('tel:$phoneNumber');
    await canLaunchUrl(phone)
        ? await launchUrl(phone)
        : ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error in calling owner")));
  }

  // Given an address, the method trigger a launch of a local
  // navigation app (google maps for example), and send the address.
  openMaps(String address, BuildContext context) async {
    String add = Uri.encodeComponent(address);
    Uri url = Uri.parse("geo:0,0?q=$add");
    await canLaunchUrl(url)
        ? await launchUrl(url)
        : ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error in open google maps")));
  }
}
