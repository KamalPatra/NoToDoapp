import 'package:flutter/material.dart';
import 'package:notodo_app/ui/notodo_screen.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("No-To-Do"),
        centerTitle: true,
        backgroundColor: Colors.black54,
      ),
      body: NoToDoScreen(),
    );
  }
}
