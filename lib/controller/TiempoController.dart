import 'dart:convert';

import 'package:HidroCrop/dao/Tiempo.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';


class TiempoController{
  static Logger logger = new Logger();

  static Future<Tiempo> fetchTiempo(http.Client client, double lat, double lon) async{
    logger.i('START fetchTiempo - client: $client, lat: $lat, lon: $lon');
    String _apiKey = '5d2cceaadf6641d29cf5cbbc946b314b';
    String hoy = DateTime.now().year.toString() + '-' + DateTime.now().month.toString() + '-' + DateTime.now().day.toString();
    String manana = DateTime.now().year.toString() + '-' + DateTime.now().month.toString() + '-' + (DateTime.now().add(new Duration(days: 1)).day.toString());
    final response = await client.get('https://api.weatherbit.io/v2.0/history/daily?lat=$lat&lon=$lon&start_date=$hoy&end_date=$manana&key=$_apiKey');
    logger.i('END fetchTiempo');
    return parseJson(response.body);
  }

  static Tiempo parseJson(String response) {
    logger.i('START parseJson');
    Map map = json.decode(response.toString());
    var tiempo = new Tiempo.fromJson(map);
    logger.i('END parseJson');
    return tiempo;
  }
}