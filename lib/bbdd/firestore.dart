import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/escaneado.dart';

class FirestoreBBDD {
  //se recuperan todos los datos de la base de datos
  Stream<List<Escaneado>> getEscaneados(ordenarPor) => FirebaseFirestore
      .instance
      .collection('escaneados')
      .orderBy(ordenarPor, descending: ordenarPor == "fechaPubl" ? true : false)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Escaneado.fromJson(doc.data())).toList());

  //se eliminan los datos de la base de datos a partir de la id pasada y de su/s respectiva/s imagene/s a partir de su/s enlace/s de descarga
  deleteEscaneado(List urlFotos, String id) {
    for (var urlFoto in urlFotos) {
      FirebaseStorage.instance.refFromURL(urlFoto).delete();
    }
    FirebaseFirestore.instance.collection('escaneados').doc(id).delete();
  }
}
