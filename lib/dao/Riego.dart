/**
 * Clase que define el objeto Riego
 */

class Riego{
  final int idRiego;
  final String tipo;
  final double eficiencia_minima;
  final double eficiencia_maxima;

  Riego({this.idRiego, this.tipo, this.eficiencia_minima, this.eficiencia_maxima});

  Map<String, dynamic> toMap(){
    return {
      'idRiego': idRiego,
      'tipo': tipo,
      'eficiencia_minima': eficiencia_minima,
      'eficiencia_maxima': eficiencia_maxima,
    };
  }

  factory Riego.fromMap(Map<String, dynamic> map) => new Riego(idRiego: map['idRiego']);

  static List<int> getEficiencia(int num, int max){
    List<int> lista = new List();
    for(int i = 0; i <= max; i++){
      lista.add(num);
      num++;
    }
    return lista;
  }
}