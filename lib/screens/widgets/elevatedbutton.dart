import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scannerapp/global/const.dart';

import '../../blocs/tabinfo_bloc.dart';
import '../../blocs/tabinfo_event.dart';

///botones switch con gestión de estados para el orden de los documentos publicados
Widget elevatedButton(int tabNum) => BlocBuilder<TabInfoBloc, int>(
      builder: (context, tabP) => Expanded(
        child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              fixedSize: const Size.fromHeight(30),
              backgroundColor: tabP == tabNum ? kSColor : kPColor,
            ),
            onPressed: () {
              tabNum == 1
                  ? context.read<TabInfoBloc>().add(GoUno())
                  : context.read<TabInfoBloc>().add(GoDos());
            },
            icon: tabNum == 1
                ? Icon(Icons.date_range,
                    color: tabP == tabNum ? kPColor : kSColor)
                : Icon(Icons.sort_by_alpha_rounded,
                    color: tabP == tabNum ? kPColor : kSColor),
            label: Text(
              tabNum == 1 ? "Ordenar \npor fecha" : "Ordenar\n A - Z",
              style: TextStyle(
                  color: tabP == tabNum ? kPColor : kSColor, fontSize: 12),
            )),
      ),
    );
