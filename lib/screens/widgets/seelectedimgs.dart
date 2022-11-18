import 'dart:io';
import 'package:flutter/material.dart';

class SelectedImgs extends StatefulWidget {
  final List<dynamic> fotosDoc;

  ///Imágenes que serán subidas para crear el nuevo documento
  const SelectedImgs({super.key, required this.fotosDoc});

  @override
  State<SelectedImgs> createState() => _SelectedImgsState();
}

class _SelectedImgsState extends State<SelectedImgs> {
  @override
  Widget build(BuildContext context) {
    return widget.fotosDoc.isEmpty
        ? const Center(
            child: Text(
              "Aquí se mostrarán las imágenes seleccionadas",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          )
        : SizedBox(
            height: 1000,
            child: GridView(
                scrollDirection: Axis.vertical,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
                children: [
                  for (var foto in widget.fotosDoc)
                    GridTile(child: Image.file(File(foto), fit: BoxFit.cover)),
                ]),
          );
  }
}
