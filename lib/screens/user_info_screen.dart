import 'package:flutter/material.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/screens/user_screen.dart';

class UserInfoScreen extends StatefulWidget {
  final Token token;
  final User user;

  UserInfoScreen({required this.token, required this.user});

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.fullName),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              _showUserInfo(),
              _showButtons(),
            ],
          ),
          _showLoader
              ? LoaderComponent(
                  text: "Por favor espere...",
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _showUserInfo() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: FadeInImage(
              placeholder: AssetImage('assets/logo.png'),
              image: NetworkImage(widget.user.imageFullPath),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            Text('Email: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(widget.user.email,
                                style: TextStyle(
                                  fontSize: 12,
                                )),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('Tipo de Documento: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(widget.user.documentType.description,
                                style: TextStyle(
                                  fontSize: 12,
                                )),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('Documento: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(widget.user.document,
                                style: TextStyle(
                                  fontSize: 12,
                                )),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('Dirección: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(widget.user.address,
                                style: TextStyle(
                                  fontSize: 12,
                                )),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('Teléfono: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(widget.user.phoneNumber,
                                style: TextStyle(
                                  fontSize: 12,
                                )),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text('N° de vehículos: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(widget.user.vehiclesCount.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _showEditUserButton(),
          SizedBox(
            width: 20,
          ),
          _showAddVehicleButton(),
        ],
      ),
    );
  }

  Widget _showEditUserButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text('Editar Usuario'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Color(0xFF120E43);
          }),
        ),
        onPressed: () => _goEdit(),
      ),
    );
  }

  Widget _showAddVehicleButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text('Agregar Vehículo'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Colors.purple;
          }),
        ),
        onPressed: () {},
      ),
    );
  }

  void _goEdit() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                UserScreen(token: widget.token, user: widget.user)));
    if (result == 'yes') {
      //Pending refresh using info
    }
  }
}
