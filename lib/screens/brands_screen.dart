import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';

import 'package:vehicles_app/models/brand.dart';
import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/screens/brand_screen.dart';

class BrandsScreen extends StatefulWidget {
  final Token token;

  BrandsScreen({required this.token});

  @override
  _brandsScreenState createState() => _brandsScreenState();
}

class _brandsScreenState extends State<BrandsScreen> {
  List<Brand> _brands = [];
  List<Brand> _brands2 = [];
  bool _showLoader = false;

  bool _isFiltered = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _getbrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE4D359),
      appBar: AppBar(
        title: Text('Marcas'),
        actions: <Widget>[
          _isFiltered
              ? IconButton(
                  onPressed: _removeFilter,
                  icon: Icon(Icons.filter_none),
                )
              : IconButton(
                  onPressed: _showFilter,
                  icon: Icon(Icons.filter_alt),
                ),
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

  Future<Null> _getbrands() async {
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
        ],
      );
      return;
    }

    Response response = await ApiHelper.getBrands(widget.token);

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
        ],
      );
      return;
    }

    setState(() {
      _brands = response.result;
      _brands2 = _brands;
    });
  }

  Widget _getContent() {
    return _brands2.length == 0 ? _noContent() : _getListView();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          _isFiltered
              ? 'No hay marcas con ese criterio de búsqueda'
              : 'No hay marcas registrados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getbrands,
      child: ListView(
        children: _brands2.map((e) {
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
                        Text(e.description, style: TextStyle(fontSize: 16)),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    SizedBox(height: 5),
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
          title: Text('Filtrar Marcas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Escriba las primeras letras de la Marca'),
              SizedBox(height: 10),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Criterio de búsqueda...',
                  labelText: 'Buscar',
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  _search = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(onPressed: () => _filter(), child: Text('Filtrar')),
          ],
        );
      },
    );
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
    });
    _brands2 = _brands;
  }

  _filter() {
    if (_search.isEmpty) {
      return;
    }
    List<Brand> filteredList = [];
    for (var brand in _brands) {
      if (brand.description.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(brand);
      }
    }

    setState(() {
      _brands2 = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  void _goAdd() async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => brandScreen(
          token: widget.token,
          brand: Brand(description: '', id: 0),
        ),
      ),
    );
    if (result == 'yes') {
      _getbrands();
    }
  }

  void _goEdit(Brand brand) async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => brandScreen(token: widget.token, brand: brand),
      ),
    );
    if (result == 'yes') {
      _getbrands();
    }
  }
}
