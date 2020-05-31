import 'package:flutter/foundation.dart';

class Tiempo {
  String timezone;
  String state_code;
  String country_code;
  double lat;
  double lon;
  String city_name;
  String station_id;
  List<Data> data;
  List<String> sources;
  String city_id;

  Tiempo({this.timezone, this.state_code, this.country_code, this.lat, this.lon, this.city_name, this.station_id, this.data, this.sources, this.city_id});

  factory Tiempo.fromJson(Map<String, dynamic> parsedJson){
    var list = parsedJson['data'] as List;
    List<Data> dataList = list.map((i) => Data.fromJson(i)).toList();
    return Tiempo(
      timezone: parsedJson['timezone'],
      state_code: parsedJson['state_code'],
      country_code: parsedJson['country_code'],
      lat: parsedJson['lat'],
      lon: parsedJson['lon'],
      city_name: parsedJson['city_name'],
      station_id: parsedJson['station_id'],
      data: dataList,
      sources: List<String>.from(
          parsedJson['sources'].map((x) => x.toString())),
      city_id: parsedJson['city_id'],
    );
  }
}

class Data {
  double rh;
  double max_wind_spd_ts;
  double t_ghi;
  double max_wind_spd;
  double solar_rad;
  double wind_gust_spd;
  double max_temp_ts;
  double min_temp_ts;
  double clouds;
  double max_dni;
  double precip_gpm;
  double wind_spd;
  double slp;
  double ts;
  double max_ghi;
  double temp;
  double pres;
  double dni;
  double dewpt;
  double snow;
  double dhi;
  double precip;
  double wind_dir;
  double max_dhi;
  double ghi;
  double max_temp;
  double t_dni;
  double max_uv;
  double t_dhi;
  String datetime;
  double t_solar_rad;
  double min_temp;
  double max_wind_dir;
  double snow_depth;

  Data(
      {this.rh,
      this.max_wind_spd_ts,
      this.t_ghi,
      this.max_wind_spd,
      this.solar_rad,
      this.wind_gust_spd,
      this.max_temp_ts,
      this.min_temp_ts,
      this.clouds,
      this.max_dni,
      this.precip_gpm,
      this.wind_spd,
      this.slp,
      this.ts,
      this.max_ghi,
      this.temp,
      this.pres,
      this.dni,
      this.dewpt,
      this.snow,
      this.dhi,
      this.precip,
      this.wind_dir,
      this.max_dhi,
      this.ghi,
      this.max_temp,
      this.t_dni,
      this.max_uv,
      this.t_dhi,
      this.datetime,
      this.t_solar_rad,
      this.min_temp,
      this.max_wind_dir,
      this.snow_depth});

  factory Data.fromJson(Map<String, dynamic> parsedJson){
    String rh = parsedJson['rh'].toString();
    String max_wind_spd_ts = parsedJson['max_wind_spd_ts'].toString();
    String t_ghi = parsedJson['t_ghi'].toString();
    String max_wind_spd = parsedJson['max_wind_spd'].toString();
    String solar_rad = parsedJson['solar_rad'].toString();
    String wind_gust_spd = parsedJson['wind_gust_spd'].toString();
    String max_temps_ts = parsedJson['max_temp_ts'].toString();
    String min_temp_ts = parsedJson['min_temp_ts'].toString();
    String clouds = parsedJson['clouds'].toString();
    String max_dni = parsedJson['max_dni'].toString();
    String precip_gpm = parsedJson['precip_gpm'].toString();
    String wind_spd = parsedJson['wind_spd'].toString();
    String slp = parsedJson['slp'].toString();
    String ts = parsedJson['ts'].toString();
    String max_ghi = parsedJson['max_ghi'].toString();
    String temp = parsedJson['temp'].toString();
    String pres = parsedJson['pres'].toString();
    String dni = parsedJson['dni'].toString();
    String dewpt = parsedJson['dewpt'].toString();
    String snow = parsedJson['snow'].toString();
    String dhi = parsedJson['dhi'].toString();
    String precip = parsedJson['precip'].toString();
    String wind_dir = parsedJson['wind_dir'].toString();
    String max_dhi = parsedJson['max_dhi'].toString();
    String ghi = parsedJson['ghi'].toString();
    String max_temp = parsedJson['max_temp'].toString();
    String t_dni = parsedJson['t_dni'].toString();
    String max_uv = parsedJson['max_uv'].toString();
    String t_dhi = parsedJson['t_dhi'].toString();
    String t_solar_rad = parsedJson['t_solar_rad'].toString();
    String min_temp = parsedJson['min_temp'].toString();
    String max_wind_dir = parsedJson['max_wind_dir'].toString();
    String snow_depth = parsedJson['snow_depth'].toString();
    return Data(
      rh: double.parse(rh),
      max_wind_spd_ts: double.parse(max_wind_spd_ts),
      t_ghi: double.parse(t_ghi),
      max_wind_spd: double.parse(max_wind_spd),
      solar_rad: double.parse(solar_rad),
      wind_gust_spd: double.parse(wind_gust_spd),
      max_temp_ts: double.parse(max_temps_ts),
      min_temp_ts: double.parse(min_temp_ts),
      clouds: double.parse(clouds),
      max_dni: double.parse(max_dni),
      precip_gpm: double.parse(precip_gpm),
      wind_spd: double.parse(wind_spd),
      slp: double.parse(slp),
      ts: double.parse(ts),
      max_ghi: double.parse(max_ghi),
      temp: double.parse(temp),
      pres: double.parse(pres),
      dni: double.parse(dni),
      dewpt: double.parse(dewpt),
      snow: double.parse(snow),
      dhi: double.parse(dhi),
      precip: double.parse(precip),
      wind_dir: double.parse(wind_dir),
      max_dhi: double.parse(max_dhi),
      ghi: double.parse(ghi),
      max_temp: double.parse(max_temp),
      t_dni: double.parse(t_dni),
      max_uv: double.parse(max_uv),
      t_dhi: double.parse(t_dhi),
      datetime: parsedJson['datetime'],
      t_solar_rad: double.parse(t_solar_rad),
      min_temp: double.parse(min_temp),
      max_wind_dir: double.parse(max_wind_dir),
      snow_depth: snow_depth == null ? double.parse(snow_depth) : null,
    );
  }
}
