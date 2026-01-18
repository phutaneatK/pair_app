import 'package:flutter/material.dart';

void main() {
  runApp(const PairApp());
}

class PairApp extends StatelessWidget {
  const PairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: Text('Pair App'))),
    );
  }
}
