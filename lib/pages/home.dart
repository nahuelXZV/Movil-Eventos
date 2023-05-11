import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../model/direccion.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<List<String>> _images = [];
  List<String> _eventos = [];

  Future<void> _getImages() async {
    final prefs = await SharedPreferences.getInstance();
    final user = jsonDecode(prefs.getString("user")!);
    // print(user['id']);

    // Realizar la solicitud HTTP a la API
    var url =
        Uri.parse('${Direccion().servidor}compra/by/usuario/${user['id']}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // Obtener la lista de URL de imágenes del JSON y actualizar el estado
      List<List<String>> imagesLocal = [];
      List<String> eventos = [];

      // ignore: unused_local_variable
      for (var compra in data) {
        eventos.add(compra['evento']['nombre']);
        List<String> fotos = [];
        for (var foto in compra['fotos']) {
          fotos.add(foto['fotoEvento']['dirFotoCompresa']);
        }
        imagesLocal.add(fotos);
      }
      if (imagesLocal.isEmpty) {
        imagesLocal.add([
          'https://img.freepik.com/vector-gratis/elegante-fondo-blanco-lineas-brillantes_1017-17580.jpg?w=360',
          'https://img.freepik.com/vector-gratis/elegante-fondo-blanco-lineas-brillantes_1017-17580.jpg?w=360'
        ]);
        eventos.add('No tienes fotos');
      }

      setState(() {
        _images = imagesLocal;
        _eventos = eventos;
      });
    } else {
      print('Error al obtener las imágenes: ${response.statusCode}');
    }
  }

  Future<void> _cerrar(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");
    await prefs.remove("accessToken");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyApp(prefs: prefs),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Llamar a la función para obtener las imágenes cuando se inicia el widget
    _getImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Tus Recuerdos', style: TextStyle(fontSize: 30)),
          backgroundColor: Colors.teal[300],
          actions: [
            IconButton(
              onPressed: () {
                _cerrar(context);
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: ListView(
          children: [
            // mensaje que diga galeria de fotos
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Galeria de fotos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            // mensaje pequeoño que diga presiona la imagen para guardarla
            // un espacio
            const SizedBox(
              height: 20,
            ),

            // Mostrar cada imagen en un contenedor
            for (var i = 0; i < _eventos.length; i++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      _eventos[i].capitalize(),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images[i].length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 300,
                          child: Card(
                            child: Image.network(_images[i][index]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
          ],
        ));
  }
}
