import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/screens/brands_screen.dart';
import 'package:vehicles_app/screens/login_screen.dart';
import 'package:vehicles_app/screens/procedures_screen.dart';
import 'package:vehicles_app/screens/users_screen.dart';
import 'package:vehicles_app/screens/vehicle_types_screen.dart';

import 'document_types_screen.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE4D359),
      appBar: AppBar(
        title: Text('Vehicles'),
      ),
      body: _getBody(),
      drawer: widget.token.user.userType == 0
          ? _getMechanicMenu()
          : _getCustomerMenu(),
    );
  }

  Widget _getBody() {
    return Container(
      margin: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage('assets/logo.png'),
            width: 250,
          ),
          SizedBox(
            height: 40,
          ),
          ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl: widget.token.user.imageFullPath,
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
                height: 200,
                width: 200,
                placeholder: (context, url) => Image(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.cover,
                  height: 200,
                  width: 200,
                ),
              )),
          SizedBox(
            height: 30,
          ),
          Center(
            child: Text(
              'Bienvenido/a ${widget.token.user.fullName}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _getMechanicMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(child: Image(image: AssetImage('assets/logo.png'))),
          ListTile(
            leading: Icon(Icons.two_wheeler),
            title: Text('Marcas'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BrandsScreen(
                            token: widget.token,
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.precision_manufacturing),
            title: Text('Procedimientos'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProceduresScreen(
                            token: widget.token,
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.badge),
            title: Text('Tipos de Documento'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DocumentTypesScreen(
                            token: widget.token,
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.toys),
            title: Text('Tipos de Vehículo'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VehicleTypesScreen(
                            token: widget.token,
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Usuarios'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UsersScreen(
                            token: widget.token,
                          )));
            },
          ),
          Divider(
            color: Colors.black,
            height: 2,
          ),
          ListTile(
            leading: Icon(Icons.face),
            title: Text('Editar perfil'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión'),
            onTap: () {
              _logOut();
            },
          ),
        ],
      ),
    );
  }

  _getCustomerMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(child: Image(image: AssetImage('assets/logo.png'))),
          ListTile(
            leading: Icon(Icons.two_wheeler),
            title: Text('Mis Vehículos'),
            onTap: () {},
          ),
          Divider(
            color: Colors.black,
            height: 2,
          ),
          ListTile(
            leading: Icon(Icons.face),
            title: Text('Editar perfil'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión'),
            onTap: () {
              _logOut();
            },
          ),
        ],
      ),
    );
  }

  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', false);
    await prefs.setString('userBody', '');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}
