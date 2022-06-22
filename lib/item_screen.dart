import 'package:flutter/material.dart';

List<String> categories = [
  "Pokemon cards",
  "Gold",
  "Human organs",
  "Food",
  "Dogs",
  "Cats",
  "Banana",
];



class ItemScreen extends StatefulWidget {
  //const ItemScreen({Key? key, this.title = "ItemScreen"}) : super(key: key);
  //final String title;
  @override
  _ItemScreenState createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Screen'), actions: [
        IconButton(onPressed: () => {}, icon: const Icon(Icons.star)),
        IconButton(onPressed: () => {}, icon: const Icon(Icons.more_vert))
      ]),
      //body: SingleChildScrollView(//maybe, without expanded or flex: 0
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Expanded(child: Image.network('https://picsum.photos/250?image=1')),
            Expanded(
                child: Image.network(
              'https://picsum.photos/250?image=1',
              //width: double.infinity,
              fit: BoxFit.fitWidth,
            )),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Item Name",
                        style: TextStyle(
                          fontSize: 26,
                        )),
                    const SizedBox(height: 10),
                    Text(
                        "Item's description:\nThis is the item's description and here will be the item's description.",
                        style: TextStyle(
                            fontSize: 18,
                            /*height: 2,*/ color: Colors.black.withOpacity(0.6))),
                    Divider(
                      height: 30,
                      color: Colors.black.withOpacity(0.3),
                    ),
                    const Text("Categories",
                        style: TextStyle(fontSize: 18,)),
                    Wrap(
                      direction: Axis.horizontal,
                      spacing: 5,
                      children:
                          categories.map((e) => Chip(label: Text(e))).toList(),
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

/*
Expanded(child: Image.network(
'https://picsum.photos/250?image=1',
width: double.infinity,
fit: BoxFit.fitWidth,
)),*/
