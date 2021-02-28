import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miaged_montorsi/clothes_list.dart';
import 'package:miaged_montorsi/main.dart';
import 'package:miaged_montorsi/panier.dart';

class Profile extends StatelessWidget {
  String loggedUser = "";

  Profile({Key key, @required this.loggedUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIAGED',
      home: ProfilePage(this.loggedUser),
    );
  }
}

class ProfilePage extends StatefulWidget {
  String loggedUser = "";

  ProfilePage(String loggedUser) {
    this.loggedUser = loggedUser;
  }

  @override
  _ProfilePageState createState() {
    return _ProfilePageState(this.loggedUser);
  }
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 2;
  String loggedUser = "";

  String email = "";
  String password = "";
  String address = "";
  String birthday = "";
  String city = "";
  String postal_code = "";
  String username = "";

  _ProfilePageState(String loggedUser) {
    this.loggedUser = loggedUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: FlatButton(
            minWidth: 200.0,
            height: 100.0,
            color: Colors.transparent,
            child: Text("Valider", style: TextStyle(color: Colors.white)),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    updateBase();
                    return AlertDialog(
                        title: Text("Panier sauvegardé"),
                        content: Text("Les informations sont sauvegardées"),
                        actions: [
                          FlatButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ]);
                  });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClothesList(
                      loggedUser: this.loggedUser,
                    ),
                  ));
            },
          ),
          title: Text('Mon profil'),
          centerTitle: true),
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
            ));
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Panier(
                loggedUser: this.loggedUser,
              ),
            ));
    }
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder(
        future: getUserInfo(this.loggedUser),
        builder: (context, snapshot) {
         

          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Press button to start.');
            case ConnectionState.active:
            case ConnectionState.waiting:
              print("PRINT 1");
              break;
            case ConnectionState.done:
              {
                 final TextEditingController passwordController =
              new TextEditingController();
          passwordController.text = snapshot.data[4].toString();
          final TextEditingController addressController =
              new TextEditingController();
          addressController.text = snapshot.data[0].toString();
          final TextEditingController birthdayController =
              new TextEditingController();
          birthdayController.text = snapshot.data[1].toString();
          final TextEditingController cityController =
              new TextEditingController();
          cityController.text = snapshot.data[2].toString();
          final TextEditingController postalCodeController =
              new TextEditingController();
          postalCodeController.text = snapshot.data[5].toString();
          final TextEditingController usernameController =
              new TextEditingController();
          usernameController.text = snapshot.data[6].toString();

          passwordController.addListener(() {
            this.password = passwordController.text;
          });
          addressController.addListener(() {
            this.address = addressController.text;
          });
          birthdayController.addListener(() {
            this.birthday = birthdayController.text;
          });
          cityController.addListener(() {
            this.city = cityController.text;
          });
          postalCodeController.addListener(() {
            this.postal_code = postalCodeController.text;
          });
          usernameController.addListener(() {
            this.username = usernameController.text;
          });
                updateAttributes(snapshot);
                return new Container(
                  child: new Column(
                    children: <Widget>[
                      new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new TextField(
                          decoration: new InputDecoration(
                              labelText: 'Nom d\'utilisateur'),
                          enabled: false,
                          controller: usernameController,
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new TextField(
                          decoration:
                              new InputDecoration(labelText: 'Mot de passe'),
                          controller: passwordController,
                          obscureText: true,
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new TextField(
                          decoration:
                              new InputDecoration(labelText: 'Anniversaire'),
                          controller: birthdayController,
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new TextField(
                          decoration: new InputDecoration(labelText: 'Adresse'),
                          controller: addressController,
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new TextField(
                          decoration:
                              new InputDecoration(labelText: 'Code Postal'),
                          controller: postalCodeController,
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new TextField(
                          decoration: new InputDecoration(labelText: 'Ville'),
                          controller: cityController,
                        ),
                      ),
                      new RaisedButton(
                        child: Text('Se déconnecter'),
                textColor: Colors.red,
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ));
                },
                      )
                    ],
                  ),
                );
              }

            // You can reach your snapshot.data['url'] in here
          }
          return Container();

          // print("liste: "+snapshot.toString());
          //  print("email: "+snapshot.toString());
        });
  }

  Future getUserInfo(String user) async {
    List<String> infos = [];

    DocumentReference documentReference =
        Firestore.instance.collection("users").document(user);
    await documentReference.get().then((datasnapshot) {
      print("PRINT 2");
      infos.add(datasnapshot.data()["address"]);
      print(datasnapshot.data()["address"]);

      infos.add(datasnapshot.data()["birthday"]);
      infos.add(datasnapshot.data()["city"]);
      infos.add(datasnapshot.data()["email"]);
      infos.add(datasnapshot.data()["password"]);
      infos.add(datasnapshot.data()["postal_code"]);
      infos.add(datasnapshot.data()["username"]);

      /* infos["address"] = datasnapshot.data()["address"];
                                          infos["birthday"] = datasnapshot.data()["birthday"];
                                          infos["city"] = datasnapshot.data()["city"];
                                          infos["email"] = datasnapshot.data()["email"];
                                          infos["password"] = datasnapshot.data()["password"];
                                          infos["postal_code"] = datasnapshot.data()["postal_code"];
                                          infos["username"] = datasnapshot.data()["username"];*/
      print("liste:" + infos.toString());
    });
    return infos;
  }

  void updateAttributes(AsyncSnapshot snapshot) {
    this.address = snapshot.data[0].toString();
    this.birthday = snapshot.data[1].toString();
    this.password = snapshot.data[4].toString();
    this.email = snapshot.data[3].toString();
    this.postal_code = snapshot.data[5].toString();
    this.city = snapshot.data[2].toString();
    this.username = snapshot.data[6].toString();
  }

  void updateBase() {
    DocumentReference newPanier =
        Firestore.instance.collection("users").document(this.loggedUser);
    newPanier.update({
      'address': this.address,
      'birthday': this.birthday,
      'city': this.city,
      'password': this.password,
      'postal_code': this.postal_code,
      'username': this.username
    });
  }
}
