import 'package:cloud_firestore/cloud_firestore.dart';
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
  Widget buildDocsEsc(Escaneado escaneado) => GridTile(
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
        child: Image.network(
          escaneado.urlFotos[0] ?? "https://picsum.photos/250?image=9",
          width: 55,
          height: 100,
          fit: BoxFit.cover,
        ),
      );

  //se obtiene la información de Firebase Firestore
  Stream<List<Escaneado>> getEscaneados() => FirebaseFirestore.instance
      .collection('escaneados')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Escaneado.fromJson(doc.data())).toList());
}
