import 'package:flutter/material.dart';
import 'package:police_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<User_provider>(context);
    final userEmail = userProvider.userEmail;
    final userImage = userProvider.profilePic;
    final userName = userProvider.userName;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName ?? ''),
            accountEmail: Text(userEmail ?? ''),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  userImage ?? '',
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null)
                      return child;
                    return CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    );
                  },
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Text('Nu se poate incarca imaginea');
                  },
                  width: 90, height: 90, fit: BoxFit.cover)
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