import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';

import 'package:vehicles_app/models/vehicle_type.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/screens/vehicle_Type_screen.dart';

class VehicleTypesScreen extends StatefulWidget {
  final Token token;

  VehicleTypesScreen({required this.token});

  @override
  _vehicleTypesScreenState createState() => _vehicleTypesScreenState();
}

class _vehicleTypesScreenState extends State<VehicleTypesScreen> {
  List<VehicleType> _vehicleTypes = [];
  List<VehicleType> _vehicleTypes2 = [];
  bool _showLoader = false;

  bool _isFiltered = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _getvehicleTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE4D359),
      appBar: AppBar(
        title: Text('Tipos de Vehículo'),
        actions: <Widget>[
          _isFiltered
              ? IconButton(
                  onPressed: _removeFilter, icon: Icon(Icons.filter_none))
              : IconButton(onPressed: _showFilter, icon: Icon(Icons.filter_alt))
        ],
      ),
      body: Center(
        child: _showLoader
            ? LoaderComponent(text: 'Por favor espere...')
            : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Future<Null> _getvehicleTypes() async {
    setState(() {
      _showLoader = true;
    });

    Response response = await ApiHelper.getVehicleTypes(widget.token.token);

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
      _vehicleTypes = response.result;
      _vehicleTypes2 = _vehicleTypes;
    });
  }

  Widget _getContent() {
    return _vehicleTypes.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          _isFiltered
              ? 'No hay tipos de vehículo con ese criterio de búsqueda'
              : 'No hay tipos de vehículo registrados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getvehicleTypes,
      child: ListView(
        children: _vehicleTypes2.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goEdit(e),
              child: Container(
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(2),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.description,
                          style: TextStyle(fontSize: 16),
                        ),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFilter() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text('Filtrar Tipos de Vehículo'),
            content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Text('Escriba las primeras letras del Tipo de Vehículo'),
              SizedBox(
                height: 10,
              ),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                    hintText: 'Criterio de búsqueda...',
                    labelText: 'Buscar',
                    suffixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                onChanged: (value) {
                  _search = value;
                },
              ),
            ]),
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar')),
              TextButton(onPressed: () => _filter(), child: Text('Filtrar')),
            ],
          );
        });
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
    });
    _vehicleTypes2 = _vehicleTypes;
  }

  _filter() {
    if (_search.isEmpty) {
      return;
    }
    List<VehicleType> filteredList = [];
    for (var vehicleType in _vehicleTypes) {
      if (vehicleType.description
          .toLowerCase()
          .contains(_search.toLowerCase())) {
        filteredList.add(vehicleType);
      }
    }

    setState(() {
      _vehicleTypes2 = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VehicleTypeScreen(
                token: widget.token,
                vehicleType: VehicleType(description: '', id: 0))));
    if (result == 'yes') {
      _getvehicleTypes();
    }
  }

  void _goEdit(VehicleType vehicleType) async {
    String? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VehicleTypeScreen(
                token: widget.token, vehicleType: vehicleType)));
    if (result == 'yes') {
      _getvehicleTypes();
    }
  }
}
