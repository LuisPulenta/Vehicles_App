import 'dart:convert';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicles_app/helpers/constants.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/screens/home_screen.dart';
import 'package:vehicles_app/screens/recover_password_screen.dart';
import 'package:vehicles_app/screens/register_user_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = 'luis@yopmail.com';
  String _emailError = '';
  bool _emailShowError = false;

  String _password = '123456';
  String _passwordError = '';
  bool _passwordShowError = false;

  bool _rememberme = true;

  bool _passwordShow = false;

  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE4D359),
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  _showLogo(),
                  SizedBox(
                    height: 40,
                  ),
                  _showEmail(),
                  _showPassword(),
                  _showRememberme(),
                  _showForgotPassword(),
                  _showButtons(),
                ],
              ),
            ),
          ),
          _showLoader
              ? LoaderComponent(
                  text: 'Por favor espere...',
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return Image(
      image: AssetImage('assets/logo.png'),
      width: 300,
      fit: BoxFit.fill,
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: 'Ingresa tu Email...',
            labelText: 'Email',
            errorText: _emailShowError ? _emailError : null,
            prefixIcon: Icon(Icons.alternate_email),
            suffixIcon: Icon(Icons.email),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _email = value;
          print(_email);
        },
      ),
    );
  }

  Widget _showPassword() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: 'Ingresa tu Contraseña...',
            labelText: 'Contraseña',
            errorText: _passwordShowError ? _passwordError : null,
            prefixIcon: Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: _passwordShow
                  ? Icon(Icons.visibility)
                  : Icon(Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _passwordShow = !_passwordShow;
                });
              },
            ),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          _password = value;
        },
      ),
    );
  }

  _showRememberme() {
    return CheckboxListTile(
      title: Text('Recordarme:'),
      value: _rememberme,
      onChanged: (value) {
        setState(() {
          _rememberme = value!;
        });
      },
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _showLoginButton(),
              SizedBox(
                width: 20,
              ),
              _showRegisterButton(),
            ],
          ),
          _showGoogleLoginButton(),
          _showFacebookLoginButton(),
        ],
      ),
    );
  }

  void _login() async {
    setState(() {
      _passwordShow = false;
    });

    if (!validateFields()) {
      return;
    }

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

    Map<String, dynamic> request = {
      'userName': _email,
      'password': _password,
    };

    var url = Uri.parse('${Constants.apiUrl}/api/Account/CreateToken');
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode(request),
    );

    setState(() {
      _showLoader = false;
    });

    if (response.statusCode >= 400) {
      setState(() {
        _emailShowError = true;
        _emailError = 'Email o Contraseña no válidos';
        _passwordShowError = true;
        _passwordError = 'Email o Contraseña no válidos';
      });
      return;
    }

    var body = response.body;
    if (_rememberme) {
      _storeUser(body);
    }

    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  token: token,
                )));
  }

  bool validateFields() {
    bool isValid = true;

    if (_email.isEmpty) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar tu Email';
    } else if (!EmailValidator.validate(_email)) {
      isValid = false;
      _emailShowError = true;
      _emailError = 'Debes ingresar un Email válido';
    } else {
      _emailShowError = false;
    }

    if (_password.isEmpty) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'Debes ingresar tu Contraseña';
    } else if (_password.length < 6) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = 'La Contraseña debe tener al menos 6 caracteres';
    } else {
      _passwordShowError = false;
    }

    setState(() {});

    return isValid;
  }

  Widget _showLoginButton() {
    return Expanded(
      child: ElevatedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.login),
            Text('Iniciar sesión'),
          ],
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Color(0xFF120E43);
          }),
        ),
        onPressed: () => _login(),
      ),
    );
  }

  Widget _showRegisterButton() {
    return Expanded(
      child: ElevatedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.person_add),
            Text('Nuevo usuario'),
          ],
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Colors.purple;
          }),
        ),
        onPressed: () => _register(),
      ),
    );
  }

  void _register() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterUserScreen()));
  }

  void _storeUser(String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', true);
    await prefs.setString('userBody', body);
  }

  Widget _showForgotPassword() {
    return InkWell(
      onTap: () => _goForgotPassword(),
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Text(
          '¿Has olvidado tu contraseña?',
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  void _goForgotPassword() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => RecoverPasswordScreen()));
  }

  Widget _showGoogleLoginButton() {
    return Row(
      children: <Widget>[
        Expanded(
            child: ElevatedButton.icon(
                onPressed: () => _loginGoogle(),
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.red,
                ),
                label: Text('Iniciar sesión con Google'),
                style: ElevatedButton.styleFrom(
                    primary: Colors.white, onPrimary: Colors.black)))
      ],
    );
  }

  void _loginGoogle() async {
    var googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    var user = await googleSignIn.signIn();
    print(user);
  }

  Widget _showFacebookLoginButton() {
    return Row(
      children: <Widget>[
        Expanded(
            child: ElevatedButton.icon(
                onPressed: () => _loginFacebook(),
                icon: FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Colors.white,
                ),
                label: Text('Iniciar sesión con Facebook'),
                style: ElevatedButton.styleFrom(
                    primary: Color(0xff3B5998), onPrimary: Colors.white)))
      ],
    );
  }

  void _loginFacebook() async {
    await FacebookAuth.i.logOut();
    var result = await FacebookAuth.i.login(
      permissions: ["public_profile", "email"],
    );

    print(result.message);
    var a = 1;

    if (result.status == LoginStatus.success) {
      final requestData = await FacebookAuth.i.getUserData(
        fields:
            "email, name,picture.width(800).heigth(800), first_name, last_name",
      );
      print(requestData);
    }
  }
}
