import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miaged_montorsi/clothes_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Home());
}

final firestoreInstance = FirebaseFirestore.instance;
bool connected = false;

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MIAGED',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _email = "";
  String _password = "";

  _HomePageState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MIAGED'), centerTitle: true),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: new TextField(
              controller: _emailFilter,
              decoration: new InputDecoration(labelText: 'Email'),
            ),
          ),
          new Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ),
          new Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: new RaisedButton(
              child: new Text('Login'),
              onPressed: _login,
            ),
          ),
        ],
      ),
    );
  }

  void _login() {
    connected = false;
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection('users');

    userCollection.get().then((QuerySnapshot querySnapshot) => {
          querySnapshot.docs.forEach((doc) {
            if (this._email == doc["email"]) {
              if (this._password == doc["password"]) {
                connected = true;
                String username=doc["username"];
                String id=doc.id;
                print("bienvenue, " + doc.id);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClothesList(
                        loggedUser: id,
                      ),
                    ));
              }
            }
          })
        });
    if (connected == false) print("aucun utilisateur ne correspond");
  }
}
