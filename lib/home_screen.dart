import 'package:flutter/material.dart';
import 'package:pickeep/filter_screen.dart';

class Item extends StatelessWidget {
  final int itemNo;
  const Item(
    this.itemNo,
  );
  @override
  Widget build(BuildContext context) {
    final Color color = Colors.primaries[itemNo % Colors.primaries.length];
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(0.0),
            child: Image.network(
              'https://picsum.photos/250?image=10',
              fit: BoxFit.fill,
            ),
            width: MediaQuery.of(context).size.width,
            height: 85,
          ),
          Text('product $itemNo')
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "HOME",
      home: Scaffold(
        appBar: AppBar(title: const Text('Home Screen'), actions: [
          IconButton(onPressed: () => {}, icon: const Icon(Icons.more_vert))
        ]),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FilterScreen(
                                  filterType: 'Category',
                                )),
                      );
                    },
                    child: const Text("Category"))),
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FilterScreen(
                                  filterType: 'Location',
                                )),
                      );
                    },
                    child: const Text("Location"))),
          ]),
          Expanded(
              child: GridView.builder(
            itemCount: 20,
            itemBuilder: (context, index) => Item(index),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2,
            ),
          )),
        ]),
      ),
    );
  }
}
