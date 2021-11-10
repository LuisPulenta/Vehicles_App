import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/history.dart';
import 'package:vehicles_app/models/response.dart';

import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';
import 'package:vehicles_app/models/vehicle.dart';
import 'package:vehicles_app/screens/history_screen.dart';
import 'package:vehicles_app/screens/vehicle_screen.dart';

class VehicleInfoScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Vehicle vehicle;

  VehicleInfoScreen(
      {required this.token, required this.user, required this.vehicle});

  @override
  _VehicleInfoScreenState createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  bool _showLoader = false;
  late Vehicle _vehicle;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
    _getVehicle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE4D359),
      appBar: AppBar(
        title: Text(
            '${_vehicle.brand.description} ${_vehicle.line} ${_vehicle.plaque}'),
      ),
      body: Center(
        child: _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goHistory(History(
            date: '',
            dateLocal: '',
            details: [],
            detailsCount: 0,
            id: 0,
            mileage: 0,
            remarks: '',
            total: 0,
            totalLabor: 0,
            totalSpareParts: 0)),
      ),
    );
  }

  void _goHistory(History history) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HistoryScreen(
                  token: widget.token,
                  user: widget.user,
                  vehicle: _vehicle,
                  history: history,
                )));
    if (result == 'yes') {
      await _getVehicle();
    }
  }

  Widget _getContent() {
    return Column(
      children: <Widget>[
        _showVehicleInfo(),
        Expanded(
          child: _vehicle.histories.length == 0 ? _noContent() : _getListView(),
        )
      ],
    );
  }

  Widget _showVehicleInfo() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: _vehicle.imageFullPath,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                  height: 100,
                  width: 140,
                  placeholder: (context, url) => Image(
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.cover,
                    height: 300,
                    width: 300,
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,
                  left: 100,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text('Tipo de vehículo: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _vehicle.vehicleType.description,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text('Marca: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _vehicle.brand.description,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text('Modelo: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _vehicle.model.toString(),
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text('Placa: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _vehicle.plaque,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text('Línea: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _vehicle.line,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text('Color: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _vehicle.color,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text('Comentarios: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                _vehicle.remarks == null
                                    ? 'N/A'
                                    : _vehicle.remarks!,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text('N° de Historias: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              _vehicle.historiesCount.toString(),
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
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

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          'El vehículo no tiene historias registradas.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  _getListView() {
    return RefreshIndicator(
        onRefresh: _getVehicle,
        child: ListView(
          children: _vehicle.histories.map((e) {
            return Card(
                color: Color(0xFFFFFFCC),
                shadowColor: Color(0xFF0000FF),
                elevation: 10,
                margin: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () => _goHistory(e),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(5),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Column(
                          children: <Widget>[
                            Row(
                              children: [
                                Text(
                                  '${DateFormat('dd/MM/yyyy').format(DateTime.parse(e.dateLocal))}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${e.mileage} km',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  e.remarks == null ? 'N/A' : e.remarks!,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Mano de Obra: ${NumberFormat.currency(symbol: '\$').format(e.totalLabor)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Repuestos: ${NumberFormat.currency(symbol: '\$').format(e.totalSpareParts)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Total: ${NumberFormat.currency(symbol: '\$').format(e.total)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
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

  void _goEdit() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VehicleScreen(
                  token: widget.token,
                  user: widget.user,
                  vehicle: _vehicle,
                )));
    if (result == 'yes') {
      await _getVehicle();
    }
  }

  Future<Null> _getVehicle() async {
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
    //TODO:Pending to get the vehicle
    Response response =
        await ApiHelper.getVehicle(widget.token, _vehicle.id.toString());

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
      _vehicle = response.result;
    });
  }
}
