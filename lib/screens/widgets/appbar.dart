import 'package:flutter/material.dart';
import 'package:scannerapp/global/const.dart';

class CustomAppBar extends StatefulWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String titulo;

  ///Appbar para la pantalla principal y la pantalla de creación de nuevo documento
  CustomAppBar({super.key, required this.titulo})
      : preferredSize = const Size.fromHeight(alturaAppBar);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
        color: kSColor,
      ),
      toolbarHeight: alturaAppBar,
      title: Center(
          child: Text(widget.titulo,
              style: const TextStyle(
                  fontSize: kFontSize + 5,
                  fontWeight: FontWeight.bold,
                  color: kSColor))),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Colors.red, Colors.orange]),
        ),
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(20),
      )),
    );
  }
}
