import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:scannerapp/screens/scanner.dart';

import '../const.dart';
import '../obj/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("ScanerApp"),
          actions: [
            IconButton(
                onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ScannerScreen()),
                    ),
                icon: const Icon(
                  Icons.add,
                  size: kFontSize + 10,
                ))
          ],
        ),
        //se construye el body en función de los datos recibidos en "getEscaneados()"
        body: StreamBuilder(
            stream: getEscaneados(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Algo ha ido mal: ${snapshot.error}");
              } else if (snapshot.hasData) {
                final escaneados = snapshot.data!;
                if (escaneados.isEmpty) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(kPadding),
                    child: Text(
                      'No hay ningún documento escaneado. Pulsa en el símbolo de "+"" arriba a la derecha para crear uno.',
                      style: TextStyle(fontSize: kFontSize),
                    ),
                  ));
                } else {
                  return GridView.count(
                    crossAxisCount: 1,
                    crossAxisSpacing: 3.0,
                    childAspectRatio: 4,
                    mainAxisSpacing: 5.0,
                    children: escaneados.map(buildDocsEsc).toList(),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }

  //se construye el widget iterativo
  Widget buildDocsEsc(Escaneado escaneado) => GestureDetector(
        //para poder abrir un carrusel y ver todas las imágenes deslizando.
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(
                          escaneado.nombre,
                          style: const TextStyle(fontSize: 15),
                        ),
                        actions: [
                          //eliminar documento y diálogo de confirmación
                          IconButton(
                              onPressed: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text('Eliminar documento'),
                                      content: const Text(
                                          '¿Estás seguro que deseas eliminar este documento?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context, 'OK');
                                            deleteEscaneado(escaneado.urlFotos,
                                                    escaneado.id)
                                                .then((value) =>
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              "Documento eliminado correctamente")),
                                                    ));

                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Sí'),
                                        ),
                                      ],
                                    ),
                                  ),
                              icon: const Icon(Icons.delete))
                        ],
                      ),
                      body: GestureDetector(
                        child: CarouselSlider.builder(
                          options: CarouselOptions(
                            height: 800,
                            viewportFraction: 1,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                          ),
                          itemCount: escaneado.urlFotos.length,
                          itemBuilder: (BuildContext context, int itemIndex,
                                  int pageViewIndex) =>
                              Center(
                            child: Image.network(
                              escaneado.urlFotos[itemIndex],
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }));
        },
        //texto de cada item en la lista de documentos
        child: GridTile(
          header: GridTileBar(
              backgroundColor: Colors.white60,
              title: RichText(
                text: TextSpan(
                  text: escaneado.nombre,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: kFontSize),
                  children: <TextSpan>[
                    TextSpan(
                        text: "\t\t\t${escaneado.fechaPubl}",
                        style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: kFontSize / 1.7)),
                  ],
                ),
              )),
          //miniatura de cada item en la lista de documentos
          child: Image.network(
            escaneado.urlFotos[0] ?? "https://picsum.photos/250?image=9",
            width: 55,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      );

  //se obtiene la información de Firebase Firestore
  Stream<List<Escaneado>> getEscaneados() => FirebaseFirestore.instance
      .collection('escaneados')
      .orderBy("fechaPubl", descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Escaneado.fromJson(doc.data())).toList());

  //se eliminan los datos de la base de datos y las imagenes a partir de su enlace de descarga
  Future deleteEscaneado(List urlFotos, String id) async {
    for (var urlFoto in urlFotos) {
      await FirebaseStorage.instance.refFromURL(urlFoto).delete();
    }
    await FirebaseFirestore.instance.collection('escaneados').doc(id).delete();
  }
}
