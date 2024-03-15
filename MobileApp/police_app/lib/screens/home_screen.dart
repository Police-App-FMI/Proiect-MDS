import 'package:flutter/material.dart';
import 'package:police_app/NavBar.dart';
class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Police App'),
      ),
      body: Center(
        child: Text('Main Page')
      ),
      
    );
  }
}