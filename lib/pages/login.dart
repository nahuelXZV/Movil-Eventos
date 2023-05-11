import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sw_eventos/main.dart';
import '../model/direccion.dart';

void main() {
  runApp(const login());
}

class login extends StatelessWidget {
  const login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Login",
      home: pageLogin(),
    );
  }
}

class pageLogin extends StatefulWidget {
  const pageLogin({Key? key}) : super(key: key);

  @override
  State<pageLogin> createState() => _pageLoginState();
}

class _pageLoginState extends State<pageLogin> {
  bool _loading = false;
  TextEditingController _email = TextEditingController(text: '');
  TextEditingController _password = TextEditingController(text: '');

  Future<void> _login() async {
    if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final tokenMobile = prefs.getString('tokenMobile');
      print(tokenMobile);
      var url =
          Uri.parse('${Direccion().servidor}login?tokenMobile=$tokenMobile');
      Map data = {
        'email': _email.text,
        'password': _password.text,
      };
      print(url.toString());
      var response = await http.post(url, body: data);
      if (response.statusCode == 201) {
        String body = utf8.decode(response.bodyBytes);
        final jsonData = jsonDecode(body);
        prefs.setString("accessToken", jsonData['accessToken']);
        final user = jsonEncode(jsonData['User']);
        prefs.setString("user", user);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MyApp(
                    prefs: prefs,
                  )),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Credenciales invalidas"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ingrese todos los campos"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Image(
                image: NetworkImage(
                    'https://t3.ftcdn.net/jpg/03/96/09/06/360_F_396090636_yrRjsKIxmh83BGMjQFgO163ip4m3jzsX.jpg'),
                width: 200,
                height: 200,
              ),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                controller: _email,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: Icon(Icons.remove_red_eye),
                ),
                controller: _password,
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(
                height: 5,
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient:
                      const LinearGradient(colors: [Colors.blue, Colors.green]),
                ),
                child: MaterialButton(
                  onPressed: () {
                    _login();
                  },
                  child: const Text(
                    "Iniciar sesión",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 30,
                color: Colors.black,
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
