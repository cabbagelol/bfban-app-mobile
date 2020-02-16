import 'package:flutter/material.dart';

class editPage extends StatefulWidget {
  @override
  _editPageState createState() => _editPageState();
}

class _editPageState extends State<editPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(
              'assets/images/bk-companion.jpg'),
          fit: BoxFit.fitHeight,
        )),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title:
                  Text("举报玩家".toString(), style: TextStyle(color: Colors.white)),
            ),
            body: ListView(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(20),
                  child: Text("信息",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ],
            )));
  }
}
