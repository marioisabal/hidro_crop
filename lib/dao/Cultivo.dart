/**
 * Clase que define el objeto Cultivo
 */

class Cultivo{
  final int idCultivo;
  final String tipo;
  final String fecha_siembra_minima;
  final String fecha_siembra_maxima;

  Cultivo({this.idCultivo, this.tipo, this.fecha_siembra_minima, this.fecha_siembra_maxima});

  Map<String, dynamic> toMap() {
    return {
      'idCultivo': idCultivo,
      'tipo': tipo,
      'fecha_siembra_minima': fecha_siembra_minima,
      'fecha_siembra_maxima': fecha_siembra_maxima,
    };
  }

  factory Cultivo.fromMap(Map<String, dynamic> map) => new Cultivo(idCultivo: map['idCultivo']);
}