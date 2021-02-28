import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miaged_montorsi/clothes_list.dart';

/**
 * ClothesDetail: afficher le détail d'un vêtement sélectionné dans la liste ou dans le panier
 */
class ClothesDetail extends StatelessWidget {
  String id = "";
  String title = "";
  String brand = "";
  String size = "";
  String price = "";
  String imageLink = "";
  String loggedUser = "";

  ClothesDetail(
      {Key key,
      @required this.id,
      @required this.title,
      @required this.brand,
      @required this.size,
      @required this.price,
      @required this.imageLink,
      @required this.loggedUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Titre: " + this.title);
    return MaterialApp(
      title: 'Listes de vêtements',
      home: ClothesDetailPage(this.id, this.title, this.brand, this.size,
          this.price, this.imageLink, this.loggedUser),
    );
  }
}

class ClothesDetailPage extends StatefulWidget {
  String id = "";

  String title = "";
  String brand = "";
  String size = "";
  String price = "";
  String imageLink = "";
  String loggedUser = "";

  ClothesDetailPage(String id, String title, String brand, String size,
      String price, String imageLink, String loggedUser) {
    this.id = id;
    this.title = title;
    this.brand = brand;
    this.size = size;
    this.price = price;
    this.imageLink = imageLink;
    this.loggedUser = loggedUser;

    print("image link: " + this.imageLink);
  }
  @override
  _ClothesDetailPageState createState() {
    return _ClothesDetailPageState(this.id, this.title, this.brand, this.size,
        this.price, this.imageLink, this.loggedUser);
  }
}

class _ClothesDetailPageState extends State<ClothesDetailPage> {
  int _selectedIndex = 0;
  String id = "";
  String title = "";
  String brand = "";
  String size = "";
  String price = "";
  String imageLink = "";
  String loggedUser = "";

  _ClothesDetailPageState(String id, String title, String brand, String size,
      String price, String imageLink, String loggedUser) {
    this.id = id;
    this.title = title;
    this.brand = brand;
    this.size = size;
    this.price = price;
    this.imageLink = imageLink;
    this.loggedUser = loggedUser;
    print(this.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détails du vêtement'), centerTitle: true),
      body: _buildBody(context),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back),
            label: 'Retour à la liste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Ajouter au panier',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

void _onItemTapped(int index) {
    setState(() {
          _selectedIndex = index;
          print(_selectedIndex);
    });  
     switch (_selectedIndex) {
      case 0:
        Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClothesList(
                    loggedUser: this.loggedUser,
                  ),
                )); break;
      case 1: _addPanier(); break;
    }
    
  }

  Widget _buildBody(BuildContext context) {

    return  Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                        child: Image.network(this.imageLink,
                            width: 300, height: 200),
                            alignment: Alignment.center,
                      ),
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    this.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: ''
                    ),
                  ),
                ),
                Text(
                  "Par "+this.brand,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Taille: "+this.size,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  "Prix: "+this.price,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addPanier() {
    final firestoreInstance = FirebaseFirestore.instance;
    List<String> articles = [];
    DocumentReference currentPanier =
        Firestore.instance.collection("users").document(this.loggedUser);
    currentPanier.get().then((datasnapshot) {
      articles = datasnapshot.data()["panier"].cast<String>();
      print("ancien panier: " + articles.toString());
      articles.add(this.id);

      DocumentReference newPanier =
          Firestore.instance.collection("users").document(this.loggedUser);
      newPanier.update({'panier': articles});
      print("nouveau panier: " + articles.toString());
    });
  }
}

goBack(BuildContext context) {}

//afficher les détails des vêtements
//inspiré de https://codelabs.developers.google.com/codelabs/flutter-firebase/index.html#4
class Record {
  final String brand, image_link, title;
  final int price, size;
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
