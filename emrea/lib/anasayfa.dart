import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emrea/giris.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import 'ekle.dart';
import 'duzenle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

final _auth = FirebaseAuth.instance;

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Yemek Tarifleri",
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController textController = TextEditingController();
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('tarifler').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => ekle()));
        },
        child: Icon(
          Icons.add,
        ),
      ),
      appBar: AppBar(
        title: Text('Yemek Tarifleri'),
        actions: [
          RaisedButton(
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => giris()));
            },
            child: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            color: Colors.blue,
          )
        ],
      ),
      body: StreamBuilder(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Bir Hata Oluştu..");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Yükleniyor..");
          }

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (_, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            duzenle(docid: snapshot.data!.docs[index]),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        height: 6,
                      ),
                      Container(
                        height: 160,
                        child: ListTile(
                          leading: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: 100,
                              maxWidth: 75,
                            ),
                            child: Image.asset(
                              'assets/logo.png',
                            ),
                          ),
                          trailing: Icon(Icons.calendar_view_day_outlined),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              width: 10,
                              color: Colors.black,
                            ),
                          ),
                          title: Text(
                            snapshot.data!.docChanges[index].doc['baslik'],
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          subtitle: Text(
                            snapshot.data!.docChanges[index].doc['icerik'],
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
