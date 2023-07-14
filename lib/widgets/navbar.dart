import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text(
              'HR Dept.', //TODO: Replace to Device ID (eg. IT Dept, HR)
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              'Device: <ID>', //TODO: change to ID or location
              style: TextStyle(fontSize: 15),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      'https://t3.ftcdn.net/jpg/05/50/26/54/360_F_550265413_q14RreIwKgEuWEfZ6s6xIgish7SfOZrC.jpg'), //TODO: Change to uploadable image from gallery or what
                  fit: BoxFit.cover),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            iconColor: Colors.black,
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.of(context).popAndPushNamed('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            iconColor: Colors.black,
            title: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      ),
    );
  }
}
