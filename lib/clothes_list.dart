import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miaged_montorsi/clothes_detail.dart';
import 'package:miaged_montorsi/panier.dart';
import 'package:miaged_montorsi/profile.dart';

//inspiré de https://codelabs.developers.google.com/codelabs/flutter-firebase/index.html#8 pour la création de la liste

/// ClothesList: liste des vêtements disponibles sur l'application

class ClothesList extends StatelessWidget {
  String loggedUser = "";

  ClothesList({Key key, @required this.loggedUser}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print("USERNAME: " + loggedUser);

    return MaterialApp(
      title: 'Listes de vêtements',
      home: ClothesListPage(loggedUser),
    );
  }
}

class ClothesListPage extends StatefulWidget {
  String loggedUser = "";

  ClothesListPage(String loggedUser) {
    this.loggedUser = loggedUser;
  }

  @override
  _ClothesListPageState createState() {
    return _ClothesListPageState(loggedUser);
  }
}

class _ClothesListPageState extends State<ClothesListPage> {
  int _selectedIndex = 0;
  String loggedUser = "";
  List<String> panier = [];
  String filter="";

  _ClothesListPageState(String loggedUser) {
    this.loggedUser = loggedUser;
  }

  //afficher liste des vêtements
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) =>_buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.title),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: InkWell(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new Container(
                        child: Image.network(record.image_link,
                            width: 50, height: 50),
                      ),
                    ],
                  ),
                  Expanded(
                    child: new Column(
                      children: <Widget>[
                        new Container(
                          child: new Text(
                            record.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Column(
                    children: <Widget>[
                      new Container(
                        child: new Text("Taille"),
                      ),
                      new Container(
                        child: new Text(record.size.toString()),
                      )
                    ],
                  ),
                  new Column(
                    children: <Widget>[
                      new Container(
                        child: new Text("Prix"),
                      ),
                      new Container(
                        child: new Text(record.price.toString()),
                      )
                    ],
                  )
                ],
              ),
              onTap: () {
                print("on clique");
                String img_link = record.image_link;
                print(record.title);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClothesDetail(
                        id: record.reference.id,
                        title: record.title,
                        brand: record.brand,
                        price: record.price.toString(),
                        size: record.size.toString(),
                        imageLink: img_link,
                        loggedUser: this.loggedUser,
                      ),
                    ));
              })),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          onTap: _changedDropDownItem,
              tabs: [
                Tab(icon: Icon(Icons.checkroom)),
                Tab(text: "Lingerie"),
                Tab(text: "Tee-shirts"),
                Tab(text: "Pantalons"),
              ],
            ),
          title: Text('Bienvenue, ' + this.loggedUser), centerTitle: true),
      body: _buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.money_outlined),
            label: 'Acheter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    )
      )
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
    switch (_selectedIndex) {
      
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Panier(
                loggedUser: this.loggedUser,
              ),
            )); break;

            case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(
                loggedUser: this.loggedUser,
              ),
            )); break;
    }
    
  }

void _changedDropDownItem(int newValue) {
    setState(() {
       switch(newValue)
       {
         case 0: filter=""; break;
         case 1: filter="lingerie"; break;
         case 2: filter="tee-shirt"; break;
         case 3: filter="pantalon"; break;
       }
    });
}

  Widget _buildBody(BuildContext context) {
    List<QueryDocumentSnapshot> list=[];
    List<QueryDocumentSnapshot> elementsToRemove=[];

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('clothes').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        list=snapshot.data.documents;
        if(filter=="") return _buildList(context, list);
        list.forEach((element) {

          if(element["category"]==filter)
          { 
          print("élément snapshot: "+element["title"].toString());
          }
          else elementsToRemove.add(element);
         // print("taille liste: "+list.length.toString());
        });
        elementsToRemove.forEach((element) {list.remove(element);});
        return _buildList(context, list);
      },
    );
  }
}

//afficher les détails des vêtements
//inspiré de https://codelabs.developers.google.com/codelabs/flutter-firebase/index.html#4
class Record {
  final String brand, image_link, title, size;
  final int price;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['brand'] != null),
        assert(map['image_link'] != null),
        assert(map['price'] != null),
        assert(map['size'] != null),
        assert(map['title'] != null),
        brand = map['brand'],
        image_link = map['image_link'],
        title = map['title'],
        price = map['price'],
        size = map['size'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "Record<$title:$brand, $image_link, $price, $size>";
}
