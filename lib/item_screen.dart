import 'package:flutter/material.dart';
import 'package:pickeep/filters.dart';
import 'package:pickeep/item.dart';
import 'package:pickeep/firestore/firestore_users.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemScreen extends StatefulWidget {
  //const ItemScreen({Key? key, this.title = "ItemScreen"}) : super(key: key);
  final Item item;
  final String itemId;
  final bool isChecked;
  ItemScreen({Key? key, required this.item, required this.itemId, required this.isChecked}) : super(key: key);
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  late bool isChecked;
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Screen'), leading: IconButton(
          onPressed: () => {Navigator.pop(context, isChecked)},
          icon: const Icon(Icons.arrow_back)), actions: [
        IconButton(
            onPressed: () async {
              if (isChecked) {
                await FirestoreUser().remveItemFromFavorite(
                    FirebaseAuth.instance.currentUser!.uid,
                    widget.itemId);
              } else {
                await FirestoreUser().addNewFavorite(
                    FirebaseAuth.instance.currentUser!.uid,
                    widget.itemId);
              }
              setState(() {
                if (isChecked) {
                  isChecked = false;
                } else {
                  isChecked = true;
                }
              });
            },
            icon: isChecked? const Icon(Icons.star) : const Icon(Icons.star_border)),
        IconButton(onPressed: () => {}, icon: const Icon(Icons.more_vert))
      ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image(
                image: NetworkImage(
                    'https://firebasestorage.googleapis.com/v0/b/pickeep-3341c.appspot.com/o/items%2F${widget.item.image}?alt=media'),
                fit: BoxFit.fitWidth),
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
