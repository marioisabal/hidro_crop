class Campo{
  final int idCampo;
  final String nombre;
  final double longitud;
  final double latitud;
  final String fecha_siembra;
  final double eficiencia;
  final int idRiego;
  final int idCultivo;

  Campo({this.idCampo, this.nombre, this.longitud, this.latitud, this.fecha_siembra, this.eficiencia, this.idRiego, this.idCultivo});

  Map<String, dynamic> toMap() {
    return {
      'idCampo': idCampo,
      'nombre': nombre,
      'longitud': longitud,
      'latitud': latitud,
      'fecha_siembra': fecha_siembra,
      'eficiencia': eficiencia,
      'idRiego': idRiego,
      'idCultivo': idCultivo,
    };
  }
}