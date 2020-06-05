/**
 * Clase que define el objeto Etapa
 */

class Etapa{
  final int idEtapa;
  final String nombre;

  Etapa({this.idEtapa, this.nombre});

  Map<String, dynamic> toMap(){
    return {
      'idEtapa': idEtapa,
      'nombre': nombre,
    };
  }
}