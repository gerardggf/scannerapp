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
import 'package:scannerapp/screens/widgets/appbar.dart';
import 'package:scannerapp/screens/widgets/seelectedimgs.dart';

import '../global/const.dart';

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
  bool publicando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          titulo: "Escanear documento",
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(kPadding),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 3, color: kPColor),
                          color: kSColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 3,
                            )
                          ],
                        ),
                        child: Column(children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.description, color: kPColor),
                              labelText: 'Nombre del documento',
                            ),
                            controller: cNombre,
                            //se valida que el texto tenga una longitud mínima y no sea nula
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
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
                            height: 12,
                          ),
                          //se muestra un círculo indicador de progreso en vez del botón de añadir imágenes si se está publicando un documento
                          if (publicando == true)
                            const CircularProgressIndicator(),
                          const SizedBox(
                            height: 12,
                          ),
                          if (publicando == false)
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                  minimumSize: const Size.fromHeight(45),
                                ),
                                onPressed: () {
                                  getImagenesLocal();
                                },
                                icon: const Icon(
                                  Icons.document_scanner,
                                  size: 35,
                                  color: kPColor,
                                ),
                                label: const Text(
                                  "Seleccionar imagen/imágenes",
                                  style: TextStyle(
                                      fontSize: kFontSize, color: kPColor),
                                )),
                          const SizedBox(
                            height: 10,
                          ),
                        ])),
                    const SizedBox(
                      height: 15,
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SelectedImgs(fotosDoc: fotosDoc)
                  ]),
                ),
              )),
        ),
        //botón flotante personalizado para publicar el documento
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: kPColor,
          onPressed: () {
            if (publicando == false) {
              publicarDoc();
            }
          },
          label: const Text(
            "Publicar documento",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          icon: const Icon(
            Icons.publish,
            color: kSColor,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }

  //función que valida que se haya pasado almenos una imagen y se cumplan los requisitos del nombre del documento para proceder a publicar el mismo
  void publicarDoc() {
    var isValid = _formKey.currentState!.validate();
    if (fotosDoc.isEmpty) {
      isValid = false;
      sSnackBar("No has seleccionado ninguna imagen.");
    }
    if (!isValid) return;
    setEscaneo().then(
      (value) {
        sSnackBar("Documento publicado correctamente.");
        Navigator.of(context).pop();
      },
    );
    sSnackBar("Se está publicando el documento.");
  }

  //función que muestra los mensajes pasados en un snackbar
  void sSnackBar(texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  //función en la que se obtienen las imagenes
  void getImagenesLocal() async {
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

  //función que mappea y sube los datos del documento escaneado a la Firebase Firestore
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

  //función que comprime la imagen a una calidad determinada para que no pesen tanto las imágenes
  Future comprimirFoto(String path, int quality) async {
    final newPath = p.join((await getTemporaryDirectory()).path,
        '${DateTime.now()}.${p.extension(path)}');

    final result = await FlutterImageCompress.compressAndGetFile(path, newPath,
        quality: quality);

    return result;
  }

  //función que sube cada una de las imágenes al Firebase Storage
  Future subirFoto() async {
    setState(() {
      publicando = true;
    });
    for (var fotoDoc in fotosDoc) {
      final path = 'escaneados/${fotoDoc.split('/').last}';
      var file2 = await comprimirFoto(fotoDoc, 70);

      final ref = FirebaseStorage.instance.ref().child(path);

      uploadtask = ref.putFile(file2);
      final snapshotF = await uploadtask!.whenComplete(() {});

      //se almacenan los links de cad aimagen en un array para ser subidos a la Firestore
      urlDownloadFoto.add(await snapshotF.ref.getDownloadURL());
    }
    setState(() {
      publicando = false;
    });
  }
}
