import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miaged_montorsi/clothes_detail.dart';

import 'clothes_list.dart';

/// Panier: afficher le panier de l'utilisateur, avec le prix total de ses articles ajoutés

class Panier extends StatelessWidget {
  String loggedUser = "";

  Panier({Key key, @required this.loggedUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panier',
      home: PanierPage(this.loggedUser),
    );
  }
}

class PanierPage extends StatefulWidget {
  String loggedUser = "";

  PanierPage(String loggedUser) {
    this.loggedUser = loggedUser;
  }

  @override
  _PanierPageState createState() {
    return _PanierPageState(this.loggedUser);
  }
}

class _PanierPageState extends State<PanierPage> {
  List<String> panierId = [];

  String loggedUser = "";
  String title = "";
  String brand = "";
  String size = "";
  String price = "";
  String imageLink = "";

  int totalPrice = 0;

  _PanierPageState(String loggedUser) {
    this.loggedUser = loggedUser;
  }

  Widget _buildList(BuildContext context) {
    print("on crée la liste");
    try {
      return FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            return new ListView.builder(
                padding: const EdgeInsets.all(10),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: this.panierId.length,
                itemBuilder: (context, index) {
                  //print("Index: " + index.toString());
                  

                  return InkWell(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            snapshot?.data[index]?.image_link ?? ""),
                        // no matter how big it is, it won't overflow
                      ),
                      title: Text(
                        snapshot?.data[index]?.title ?? "",
                        textScaleFactor: 1.1,
                      ),
                      trailing: new IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            updatePanier(index);

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Panier(
                                    loggedUser: this.loggedUser,
                                  ),
                                ));
                          }),
                      subtitle: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                  child: new Column(
                    children: <Widget>[
                  
                    new Column(
                      children: <Widget>[
                        new Container(
                          child: new Text(
                            "Prix: " +snapshot?.data[index]?.price.toString() ?? "",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        new Container(
                          child: new Text(
                            "Taille: " +snapshot?.data[index]?.size.toString() ?? "",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                     ] ),

                  )],
              ),
                  
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClothesDetail(
                              id: panierId[index],
                              title: snapshot.data[index].title,
                              brand: snapshot.data[index].brand,
                              price: snapshot.data[index].price.toString(),
                              size: snapshot.data[index].size.toString(),
                              imageLink: snapshot.data[index].image_link,
                              loggedUser: this.loggedUser,
                            ),
                          ));
                    },
                  ));
                });
          });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getDataId(),
        builder: (context, snapshot) {
          
          return Scaffold(
            appBar: AppBar(
                leading: BackButton(
                  color: Colors.black,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClothesList(
                            loggedUser: this.loggedUser,
                          ),
                        ));
                  },
                ),
                title: Text('Panier de ' + this.loggedUser),
                centerTitle: true),
            body: _buildBody(context),
          );
        });
  }


  Widget _buildBody(BuildContext context) {
    return FutureBuilder(
        future: getTotalPrice(),
        builder: (context, snapshot) {
          return new Container(
              height: 400.0,
              alignment: Alignment.center,
              child: new Column(
                children: [
                  Expanded(child: _buildList(context)),
                  new Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: new Text(
                      "Prix total: "+
                      snapshot.data.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Aleo',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0,
                          color: Colors.black),
                    ),
                  ),
                ],
              ));
        });
  }

  Future getTotalPrice() async {
    for (int i = 0; i < panierId.length; i++) {
      DocumentReference documentReference =
          Firestore.instance.collection("clothes").document(panierId[i]);

      await documentReference.get().then((datasnapshot) {
        this.totalPrice += datasnapshot.data()["price"];
      });
    }

    return this.totalPrice;
  }

  Future getData() async {
      List<Record> articles = [];

    articles.clear();

    for (int i = 0; i < panierId.length; i++) {
          Record recTemp = new Record();

      print("i: "+i.toString());
      DocumentReference documentReference =
          Firestore.instance.collection("clothes").document(panierId[i]);

      await documentReference.get().then((datasnapshot) {
        recTemp.title = datasnapshot.data()["title"].toString();
        recTemp.brand = datasnapshot.data()["brand"];

        recTemp.size = datasnapshot.data()["size"];
        recTemp.price = datasnapshot.data()["price"];
        recTemp.image_link = datasnapshot.data()["image_link"].toString();
       print("Titre de l'objet chargé: " +
                        recTemp.title+
                      "");
        articles.add(recTemp);

        //print("ELEMENT "+element);
      });
      print("ARTICLES: "+articles.toString());
    }

    return articles;
  }

  Future getDataId() async {
    DocumentReference documentReference =
        Firestore.instance.collection("users").document(this.loggedUser);
    await documentReference.get().then((datasnapshot) {
      panierId = datasnapshot.data()["panier"].cast<String>();
      print("length:"+panierId.length.toString());
      return datasnapshot.data()["panier"].cast<String>();
    });
  }

  void updatePanier(int indexToRemove) {
    panierId.removeAt(indexToRemove);
    DocumentReference newPanier =
        Firestore.instance.collection("users").document(this.loggedUser);
    newPanier.update({'panier': panierId});
  }
}

//afficher les détails des vêtements
//inspiré de https://codelabs.developers.google.com/codelabs/flutter-firebase/index.html#4

class Record {
  String id, brand, image_link, title, size;
  int price;
  DocumentReference reference;

  Record() {}
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
