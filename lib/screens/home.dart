import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scannerapp/blocs/tabinfo_bloc.dart';
import 'package:scannerapp/screens/doc.dart';
import 'package:scannerapp/screens/scanner.dart';
import 'package:scannerapp/screens/widgets/appbar.dart';
import 'package:scannerapp/screens/widgets/bottomnavbar.dart';

import '../bbdd/firestore.dart';
import '../global/const.dart';
import '../models/escaneado.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final firestoreDB = FirestoreBBDD();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      //appbar
      appBar: CustomAppBar(titulo: "ScannerApp"),
      //se construye el body en función de los datos recibidos en "getEscaneados()"
      body: BlocBuilder<TabInfoBloc, int>(
          builder: (context, tabP) => StreamBuilder(
              stream:
                  firestoreDB.getEscaneados(tabP == 1 ? "fechaPubl" : "nombre"),
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
              })),
      //botón flotante
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (BuildContext context) => const ScannerScreen()));
        },
        child: const Icon(
          Icons.scanner_outlined,
          color: kSColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //nav bar inferior
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  //se construye el widget iterativo
  Widget buildDocsEsc(Escaneado escaneado) => GestureDetector(
      //para poder abrir un carrusel y ver todas las imágenes deslizando.
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                fullscreenDialog: true,
                builder: (BuildContext context) => DocScreen(
                      docId: escaneado.id,
                      nombre: escaneado.nombre,
                      urlFotos: escaneado.urlFotos,
                    )));
      },
      //texto de cada item en la lista de documentos
      child: Card(
          child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 3))
                ],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1, color: kPColor),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    escaneado.urlFotos[0],
                  ),
                ),
              ),
              child: ListTile(
                  title: Container(
                padding: const EdgeInsets.all(7.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), color: kPColor),
                child: RichText(
                  text: TextSpan(
                    text: escaneado.nombre,
                    style: const TextStyle(
                        color: kSColor,
                        fontWeight: FontWeight.bold,
                        fontSize: kFontSize),
                    children: <TextSpan>[
                      TextSpan(
                          text: "\t\t\t${escaneado.fechaPubl}",
                          style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: kSColor,
                              fontSize: kFontSize / 1.7)),
                    ],
                  ),
                ),
              )))));
}
