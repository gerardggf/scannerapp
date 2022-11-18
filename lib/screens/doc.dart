import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:scannerapp/bbdd/firestore.dart';
import 'package:scannerapp/global/const.dart';

class DocScreen extends StatefulWidget {
  final String docId;
  final String nombre;
  final List<dynamic> urlFotos;

  ///pantalla que muestra el contenido del documento seleccionado
  const DocScreen(
      {super.key,
      required this.docId,
      required this.nombre,
      required this.urlFotos});

  @override
  State<DocScreen> createState() => _DocScreenState();
}

class _DocScreenState extends State<DocScreen> {
  final firestoreDB = FirestoreBBDD();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appbar propia
      appBar: AppBar(
        toolbarHeight: alturaAppBar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: kSColor,
        leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: kPColor, borderRadius: BorderRadius.circular(10)),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: kSColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )),
        title: Center(
          child: Text(
            widget.urlFotos.length == 1
                ? "${widget.nombre} \n(${widget.urlFotos.length} imagen)"
                : "${widget.nombre} \n(${widget.urlFotos.length} imágenes)",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: kPColor),
          ),
        ),
        actions: [
          //se elimina documento y diálogo de confirmación
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: kPColor, borderRadius: BorderRadius.circular(10)),
              child: IconButton(
                  onPressed: () => confirmDelete(),
                  icon: const Icon(
                    Icons.delete,
                    color: kSColor,
                  )),
            ),
          )
        ],
      ),
      body: GestureDetector(
        child: CarouselSlider.builder(
          options: CarouselOptions(
            height: 800,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: false,
            reverse: false,
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
          ),
          itemCount: widget.urlFotos.length,
          itemBuilder:
              (BuildContext context, int itemIndex, int pageViewIndex) =>
                  Center(
            child: Image.network(
              widget.urlFotos[itemIndex],
              fit: BoxFit.fill,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  //diálogo para confirmar la eliminación del documento seleccionado
  void confirmDelete() => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Eliminar documento'),
          content:
              const Text('¿Estás seguro que deseas eliminar este documento?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'OK');
                firestoreDB.deleteEscaneado(widget.urlFotos, widget.docId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Documento eliminado correctamente")),
                );

                Navigator.of(context).pop();
              },
              child: const Text('Sí'),
            ),
          ],
        ),
      );
}
