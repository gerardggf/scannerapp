import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../const.dart';

void main() {
  runApp(const ScannerScreen());
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  List<String> fotosDoc = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {}
  final _formKey = GlobalKey<FormState>();

  var cNombre = TextEditingController();
  List<String> urlDownloadFoto = [];
  UploadTask? uploadtask;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Escanear documento"), actions: [
          IconButton(
              onPressed: () {
                //se aplican los requisitos para la valdiación (definidos más abajo)
                //de la misma forma, se comprueba que el array que contiene los links de las imágenes en el Firebase Storage, no sea nulo
                //...para que siempre haya mínimo una imagen que mostrar en la pantalla "home"
                var isValid = _formKey.currentState!.validate();
                if (fotosDoc.isEmpty) {
                  isValid = false;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("No has seleccionado ninguna imagen")));
                }
                if (!isValid) return;
                setEscaneo();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Documento correctamente publicado")),
                );
              },
              icon: const Icon(Icons.save))
        ]),
        body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(kPadding),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text("Nombre del documento:"),
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.description),
                          labelText: 'Nombre del documento',
                        ),
                        controller: cNombre,
                        //se valida que el texto tenga una longitud mínima y no sea nula
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 4) {
                            return 'El campo debe tener mínimo 4 caracteres.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      TextButton.icon(
                          style: TextButton.styleFrom(
                            minimumSize: const Size.fromHeight(45),
                          ),
                          onPressed: () {
                            onPressed();
                          },
                          icon: const Icon(
                            Icons.document_scanner,
                            size: 35,
                          ),
                          label: const Text(
                            "Añadir imágenes del documento",
                            style: TextStyle(fontSize: kFontSize),
                          )),
                      for (var foto in fotosDoc) Image.file(File(foto))
                    ],
                  ),
                ),
              )),
        ));
  }

  //se obtienen las imagenes
  void onPressed() async {
    List<String> fotos;
    try {
      fotos = await CunningDocumentScanner.getPictures() ?? [];
      if (!mounted) return;
      setState(() {
        fotosDoc = fotos;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  //mappea y sube los datos del documento escaneado a la Firebase Firestore
  Future setEscaneo() async {
    final docEscan = FirebaseFirestore.instance.collection('escaneados').doc();

    await subirFoto();
    final jsonEscan = {
      'id': docEscan.id,
      'nombre': cNombre.text,
      'urlFotos': urlDownloadFoto,
      'fechaPubl': DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()),
    };
    await docEscan.set(jsonEscan);
  }

  //comprime la imagen a una calidad determinada para que no pesen tanto las imágenes
  Future comprimirFoto(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,
        '${DateTime.now()}.${p.extension(path)}');

    final result = await FlutterImageCompress.compressAndGetFile(path, newPath,
        quality: quality);

    return result;
  }

  //cada una de las imágenes es subida al Firebase Storage
  Future subirFoto() async {
    for (var fotoDoc in fotosDoc) {
      final path = 'escaneados/${fotoDoc.split('/').last}';
      var file2 = await comprimirFoto(fotoDoc, 30);

      final ref = FirebaseStorage.instance.ref().child(path);

      uploadtask = ref.putFile(file2);
      final snapshotF = await uploadtask!.whenComplete(() {});

      //se almacenan los links de cad aimagen en un array para ser subidos a la Firestore
      urlDownloadFoto.add(await snapshotF.ref.getDownloadURL());
    }
  }
}
