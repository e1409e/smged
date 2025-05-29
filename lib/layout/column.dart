import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("HELLO WORLD", style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold)),
          TextField(
            decoration: InputDecoration(
              labelText: "Enter your name",
              
            ),
          ),
          ],
      ),

    );
  }
}
