import 'package:flutter/material.dart';
import 'package:pickeep/filters.dart';
import 'package:pickeep/item.dart';

class ItemScreen extends StatefulWidget {
  //const ItemScreen({Key? key, this.title = "ItemScreen"}) : super(key: key);
  final Item item;
  ItemScreen({Key? key, required this.item}) : super(key: key);
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Screen'), actions: [
        // IconButton(onPressed: () => {}, icon: const Icon(Icons.star)),
        IconButton(onPressed: () => {}, icon: const Icon(Icons.more_vert))
      ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //Expanded(child: Image.network('https://picsum.photos/250?image=1')),
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
