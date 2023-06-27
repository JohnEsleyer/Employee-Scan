import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  const Navbar({ Key? key }) : super(key: key);

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
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold
              ),
            ),
            accountEmail: Text(
              'Device: <ID>', //TODO: change to ID or location
              style: TextStyle(
                fontSize: 15
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png'), //TODO: Change to uploadable image from gallery or what
                fit: BoxFit.cover
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            iconColor: Colors.black,
            title: const Text(
              'Login',
              style: TextStyle(
                color: Colors.black87,
              ),
              ),
            onTap: () {
              print("X");
            },
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
              print("X");
            },
          ),
        ],
      ),
    );
  }
}