class CultivoEtapas{
  final int idCultivoTieneEtapas;
  final int idCultivo;
  final int idEtapa;
  final double kc;
  final int duracion;

  CultivoEtapas({this.idCultivoTieneEtapas, this.idCultivo, this.idEtapa, this.kc, this.duracion});

  Map<String, dynamic> toMap() {
    return {
      'idCultivoTieneEtapas': idCultivoTieneEtapas,
      'idCultivo': idCultivo,
      'idEtapa': idEtapa,
      'kc': kc,
      'duracion': duracion,
    };
  }

  factory CultivoEtapas.fromMap(Map<String, dynamic> map) => new CultivoEtapas(kc: map['kc']);
}