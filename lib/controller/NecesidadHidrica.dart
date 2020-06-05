/**
 * Clase en la que se realizan los cálculos necesarios para obtener la
 * necesidd hídrica.
 */
import 'package:logger/logger.dart';

class NecesidadHidrica{

  static Logger logger = new Logger();

  static double calcularNecesidadHidrica(
      double p, double kc, double eficiencia, double tmedia, double pre) {
    logger.i('START calcularNecesidadHidrica - p: $p, kc: $kc, eficiencia: $eficiencia, tmedia: $tmedia, pre: $pre');
    double eto = calcularETo(p, tmedia);
    double et = calcularET(eto, kc);
    double pe = calcularPrecipitacionEfectica(pre);
    double nn = calcularNecesidadNeta(et, pe);
    double nt = calcularNecesidadTotal(nn, eficiencia);
    logger.i('END calcularNecesidadHidrica');
    return nt;
  }


  static calcularETo(double p, double t){
    double eto = p * (4.46 * t + 8.13);
    return eto;
  }

  static double calcularET(double eto, double kc){
    double et = eto * kc;
    return et;
  }

  static double calcularPrecipitacionEfectica(double p){
    double pe;
    if(p >= 75){
      pe = 0.8 * p - 25;
    } else {
      pe = 0.6 * p - 10;
    }
    return pe;
  }

  static double calcularNecesidadNeta(double et, double pe){
    double nn = et - pe;
    return nn;
  }

  static double calcularNecesidadTotal(double nn, double ea){
    double nt = nn/ea;
    return nt;
  }
}