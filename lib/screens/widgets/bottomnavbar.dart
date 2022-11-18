import 'package:flutter/material.dart';
import 'package:scannerapp/global/const.dart';

import 'elevatedbutton.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  ///barra de navegación para la pantalla principal
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      notchMargin: 4,
      shape: const CircularNotchedRectangle(),
      color: kPColor,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //ordenar por fechapubl
            elevatedButton(1),
            const SizedBox(
              width: 80,
            ),
            //ordenar por nombre
            elevatedButton(2)
          ],
        ),
      ),
    );
  }
}
