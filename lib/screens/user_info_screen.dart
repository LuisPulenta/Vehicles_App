import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/brand.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/models/vehicle.dart';
import 'package:vehicles_app/models/vehicle_type.dart';
import 'package:vehicles_app/screens/user_screen.dart';
import 'package:vehicles_app/screens/vehicle_info_screen.dart';
import 'package:vehicles_app/screens/vehicle_screen.dart';

class UserInfoScreen extends StatefulWidget {
  final Token token;
  final User user;

  UserInfoScreen({required this.token, required this.user});

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  bool _showLoader = false;
  late User _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = widget.user;
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE4D359),
      appBar: AppBar(
        title: Text(_user.fullName),
      ),
      body: Center(
        child: _showLoader
            ? LoaderComponent(
                text: 'Por favor espere...',
              )
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAddVehicle(Vehicle(
            id: 0,
            vehicleType: VehicleType(id: 0, description: ''),
            brand: Brand(id: 0, description: ''),
            model: 2021,
            plaque: '',
            line: '',
            color: '',
            remarks: '',
            vehiclePhotos: [],
            vehiclePhotosCount: 0,
            imageFullPath: '',
            histories: [],
            historiesCount: 0)),
      ),
    );
  }

  Widget _showUserInfo() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: CachedNetworkImage(
                  imageUrl: _user.imageFullPath,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  height: 120,
                  width: 120,
                  placeholder: (context, url) => Image(
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.cover,
                    height: 120,
                    width: 120,
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,
                  left: 80,
                  child: InkWell(
                    onTap: () => _goEdit(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        color: Colors.green[50],
                        height: 40,
                        width: 40,
                        child: Icon(
                          Icons.edit,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  )),
            ],
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
                            Text(_user.email,
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
                            Text(_user.documentType.description,
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
                            Text(_user.document,
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
                            Text(_user.address,
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
                            Text(_user.phoneNumber,
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
                            Text(_user.vehiclesCount.toString(),
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

  void _goEdit() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserScreen(
                  token: widget.token,
                  user: _user,
                  myProfile: false,
                )));
    if (result == 'yes') {
      //TODO: Pending refresh user info
      _getUser();
    }
  }

  Future<Null> _getUser() async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Verifica que estés conectado a Internet',
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    Response response = await ApiHelper.getUser(widget.token, _user.id);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: response.message,
          actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
          ]);
      return;
    }

    setState(() {
      _user = response.result;
    });
  }

  _goAdd() {}

  Widget _getContent() {
    return Column(
      children: <Widget>[
        _showUserInfo(),
        Expanded(
          child: _user.vehicles.length == 0 ? _noContent() : _getListView(),
        )
      ],
    );
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          'El usuario no tiene vehículos registrados.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
        onRefresh: _getUser,
        child: ListView(
          children: _user.vehicles.map((e) {
            return Card(
                color: Color(0xFFFFFFCC),
                shadowColor: Color(0xFF0000FF),
                elevation: 10,
                margin: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () => _goVehicle(e),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: e.imageFullPath,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover,
                          height: 80,
                          width: 120,
                          placeholder: (context, url) => Image(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover,
                            height: 80,
                            width: 120,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(e.plaque,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Text(e.vehicleType.description,
                                        style: TextStyle(
                                          fontSize: 12,
                                        )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(e.brand.description,
                                        style: TextStyle(
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Text(e.line,
                                        style: TextStyle(
                                          fontSize: 12,
                                        )),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(e.color,
                                        style: TextStyle(
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 40,
                        )
                      ],
                    ),
                  ),
                ));
          }).toList(),
        ));
  }

  void _goVehicle(Vehicle vehicle) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VehicleInfoScreen(
                token: widget.token, user: _user, vehicle: vehicle)));

    _getUser();
  }

  void _goAddVehicle(Vehicle vehicle) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VehicleScreen(
                token: widget.token, user: _user, vehicle: vehicle)));
    if (result == 'yes') {
      _getUser();
    }
  }
}
