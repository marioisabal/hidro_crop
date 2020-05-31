class HorasDiurnasMensuales{
  final int idHorasDiurnasMensuales;
  final double latitud;
  final int mes;
  final double porcentajeHoras;

  HorasDiurnasMensuales({this.idHorasDiurnasMensuales, this.latitud, this.mes, this.porcentajeHoras});

  factory HorasDiurnasMensuales.fromMap(Map<String, dynamic> map) => new HorasDiurnasMensuales(porcentajeHoras: map['porcentajeHoras']);

  Map<String, dynamic> toMap(){
    return {
      'idHorasDiurnasMensuales': idHorasDiurnasMensuales,
      'latitud': latitud,
      'mes': mes,
      'porcentajeHoras': porcentajeHoras
    };
  }
}