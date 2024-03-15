import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('Baciu Rares'),
            accountEmail: const Text('baciu.rares25@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset('assets/images/poza.jpeg', width: 90, height: 90, fit: BoxFit.cover)
              )
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                image: new AssetImage('assets/images/banner.jpg'),
                fit: BoxFit.cover
              )
            )
            ),
          ListTile(
            leading: Icon(Icons.local_police_outlined),
            title: Text('Cops On-Duty'),
            onTap: () => print('Cops On-Doty'),
          ),
          ListTile(
            leading: Icon(Icons.videocam_outlined),
            title: Text('Video Face Recognition'),
            onTap: () => print('Video Face Recognition'),
          ),
          ListTile(
            leading: Icon(Icons.car_crash_outlined),
            title: Text('Plate Recognition'),
            onTap: () => print('Plate Recognition'),
          ),
          ListTile(
            leading: Icon(Icons.people_alt_outlined),
            title: Text('Call Reinforcements'),
            onTap: () => print('Call Reinforcements'),
          ),

        ]
      )
    );
  }
}