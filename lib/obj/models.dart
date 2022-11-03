class Escaneado {
  String id;
  final String nombre;
  final List<dynamic> urlFotos;
  final String fechaPubl;

  Escaneado({
    this.id = "",
    required this.nombre,
    required this.urlFotos,
    required this.fechaPubl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'urlFotos': urlFotos,
        'fechaPubl': fechaPubl,
      };

  static Escaneado fromJson(Map<String, dynamic> json) => Escaneado(
        id: json['id'],
        nombre: json['nombre'],
        urlFotos: json['urlFotos'],
        fechaPubl: json['fechaPubl'],
      );
}
