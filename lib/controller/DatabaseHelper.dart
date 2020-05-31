import 'dart:async';

import 'package:HidroCrop/dao/Campo.dart';
import 'package:HidroCrop/dao/Cultivo.dart';
import 'package:HidroCrop/dao/CultivoEtapas.dart';
import 'package:HidroCrop/dao/Etapa.dart';
import 'package:HidroCrop/dao/HorasDiurnasMensuales.dart';
import 'package:HidroCrop/dao/Riego.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static Logger logger = new Logger();

  final _databaseName = 'HidroCrop.db';
  static Database db;

  static Future<bool> iniciarBD() async {
    logger.i('START iniciarBD');
    if (db == null) {
      db = await _configBD();
    }
    return db.isOpen;
  }

  static Future<Database> _configBD() async {
    String createEtapa = await rootBundle.loadString('sql/createEtapa.sql');
    String createCultivo = await rootBundle.loadString('sql/createCultivo.sql');
    String createRiego = await rootBundle.loadString('sql/createRiego.sql');
    String createCultivoEtapas =
    await rootBundle.loadString('sql/createCultivoEtapas.sql');
    String createCampo = await rootBundle.loadString('sql/createCampo.sql');
    String createHorasDiurnasMensuales =
    await rootBundle.loadString('sql/createHorasDiurnasMensuales.sql');
    String insertCultivo = await rootBundle.loadString('sql/insertCultivo.sql');
    String insertEtapa = await rootBundle.loadString('sql/insertEtapa.sql');
    String insertCultivoEtapa =
    await rootBundle.loadString('sql/insertCultivoEtapa.sql');
    String insertRiego = await rootBundle.loadString('sql/insertRiego.sql');
    String insertCampo = await rootBundle.loadString('sql/insertCampo.sql');
    String insertHorasDiurnasMensuales =
    await rootBundle.loadString('sql/insertHorasDiurnasMensuales.sql');
    final database = openDatabase(
      join(await getDatabasesPath(), 'HidroCrop.db'),
      onCreate: (db, version) {
        db.execute(createEtapa);
        db.execute(createCultivo);
        db.execute(createRiego);
        db.execute(createCultivoEtapas);
        db.execute(createCampo);
        db.execute(createHorasDiurnasMensuales);
        db.rawInsert(insertCultivo);
        db.rawInsert(insertEtapa);
        db.rawInsert(insertCultivoEtapa);
        db.rawInsert(insertRiego);
        db.rawInsert(insertCampo);
        db.rawInsert(insertHorasDiurnasMensuales);
      },
      version: 1,
    );
    logger.i('END iniciarBD');
    return database;
  }

  static Future<void> insertCampo(Campo campo) async {
    logger.i('insertCampo - campo: $campo');
    //Introduce un campo en la base de datos
    return await db.insert(
      'Campo',
      campo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteCampo(int id) async {
    logger.i('deleteCampo - id: $id');
    return await db.delete(
      'CAMPO',
      where: "idCampo = ?",
      whereArgs: [id],
    );

  }

  static Future<List<Campo>> listaCampos() async {
    logger.i('listaCampos');
    final List<Map<String, dynamic>> mapa = await db.query('CAMPO');
    return List.generate(mapa.length, (i) {
      return Campo(
        idCampo: mapa[i]['idCampo'],
        nombre: mapa[i]['nombre'],
        longitud: mapa[i]['longitud'],
        latitud: mapa[i]['latitud'],
        fecha_siembra: mapa[i]['fecha_siembra'],
        eficiencia: mapa[i]['eficiencia'],
        idRiego: mapa[i]['idRiego'],
        idCultivo: mapa[i]['idCultivo'],
      );
    });
  }

  static Future<List<Cultivo>> listaCultivos() async {
    logger.i('listaCultivos');
    final List<Map<String, dynamic>> mapa = await db.query('CULTIVO');
    return List.generate(mapa.length, (i) {
      return Cultivo(
        idCultivo: mapa[i]['idCultivo'],
        tipo: mapa[i]['tipo'],
        fecha_siembra_minima: mapa[i]['fecha_siembra_minima'],
        fecha_siembra_maxima: mapa[i]['fecha_siembra_maxima'],
      );
    });
  }

  static Future<List<Riego>> listaRiegos() async {
    logger.i('listaRiegos');
    final List<Map<String, dynamic>> mapa = await db.query('RIEGO');
    return List.generate(mapa.length, (i) {
      return Riego(
        idRiego: mapa[i]['idRiego'],
        tipo: mapa[i]['tipo'],
        eficiencia_minima: mapa[i]['eficiencia_minima'],
        eficiencia_maxima: mapa[i]['eficiencia_maxima'],
      );
    });
  }

  static Future<List<Riego>> listaEficiencias(String id) async {
    logger.i('listaEficiencias - id: $id');
    final List<Map<String, dynamic>> mapa = await db.rawQuery(
        'SELECT eficiencia_minima, eficiencia_maxima from RIEGO where id = ' +
            id +
            ";");
    return List.generate(mapa.length, (i) {
      return Riego(
        eficiencia_minima: mapa[i]['eficiencia_minima'],
        eficiencia_maxima: mapa[i]['eficiencia_maxima'],
      );
    });
  }

  static Future<List<Etapa>> listaEtapas() async {
    logger.i('listaEtapas');
    final List<Map<String, dynamic>> mapa = await db.query('ETAPA');
    return List.generate(mapa.length, (i) {
      return Etapa(
        idEtapa: mapa[i]['idEtapa'],
        nombre: mapa[i]['nombre'],
      );
    });
  }

  static Future<List<CultivoEtapas>> listaCultivoEtapas() async {
    logger.i('listaCultivosEtapas');
    final List<Map<String, dynamic>> mapa =
    await db.query('CULTIVO_TIENE_ETAPAS');
    return List.generate(mapa.length, (i) {
      return CultivoEtapas(
        idCultivoTieneEtapas: mapa[i]['idCultivoTieneEtapas'],
        idCultivo: mapa[i]['idCultivo'],
        idEtapa: mapa[i]['idEtapa'],
        kc: mapa[i]['kc'],
        duracion: mapa[i]['duracion'],
      );
    });
  }

  static Future<double> getKc(int idCultivo, idEtapa) async {
    logger.i('getKc - idCultivo: $idCultivo, idEtapa: $idEtapa');
    final List<Map> results = await db.query('CULTIVO_TIENE_ETAPAS',
    columns: ['kc'],
    where: 'idCultivo = ? and idEtapa = ?',
    whereArgs: [idCultivo, idEtapa]);
    if (results.length > 0) {
      CultivoEtapas cultivoEtapas = new CultivoEtapas.fromMap(results.first);
      return cultivoEtapas.kc;
    }
    return null;
  }
  static Future<List<CultivoEtapas>> listaCultivosEtapasFromIdCultivo(
      int idCultivo) async {
    logger.i('listaCultivosEtapasFromIdCultivo - idCultivo: $idCultivo');
    final List<Map<String, dynamic>> mapa = await db.query(
        'CULTIVO_TIENE_ETAPAS',
        where: 'idCultivo = ?',
        whereArgs: [idCultivo]);
    return List.generate(mapa.length, (i) {
      return CultivoEtapas(
        idCultivoTieneEtapas: mapa[i]['idCultivoTieneEtapas'],
        idCultivo: mapa[i]['idCultivo'],
        idEtapa: mapa[i]['idEtapa'],
        kc: mapa[i]['kc'],
        duracion: mapa[i]['duracion'],
      );
    });
  }

  Future<void> updateCampo(Campo campo) async {
    logger.i('updateCampo');
    // Actualiza el Campo dado
    await db.update(
      'CAMPO',
      campo.toMap(),
      where: "idCampo = ?",
      whereArgs: [campo.idCampo],
    );
  }

  static Future<int> getIdCultivo(String tipo) async {
    logger.i('getIdCultivo - tipo: $tipo');
    List<Map> results = await db.query('Cultivo',
        columns: ['idCultivo'], where: 'tipo = ?', whereArgs: [tipo]);
    if (results.length > 0) {
      Cultivo cultivo = new Cultivo.fromMap(results.first);
      return cultivo.idCultivo;
    }
    return null;
  }

  static Future<int> getIdRiego(String tipo) async {
    logger.i('getIdRiego - tipo: $tipo');
    List<Map> results = await db.query('Riego',
        columns: ['idRiego'], where: 'tipo = ?', whereArgs: [tipo]);
    if (results.length > 0) {
      Riego riego = new Riego.fromMap(results.first);
      return riego.idRiego;
    }
    return null;
  }

  static Future<double> getPorcentajeHorasDiurnasMensuales(int mes,
      double latitud) async {
    logger.i('getPorcentajeHorasDiurnasMensuales - mes: $mes, latitud: $latitud');
    double latitudEfectiva = 0;

    if (latitud >= 0) {
      latitudEfectiva = 0.0;
      if (latitud > 5.0) {
        latitudEfectiva = 5.0;
      }  if (latitud >= 10.0) {
        latitudEfectiva = 10.0;
      }  if (latitud >= 15.0) {
        latitudEfectiva = 15.0;
      }  if (latitud >= 20.0) {
        latitudEfectiva = 20.0;
      }  if (latitud >= 25.0) {
        latitudEfectiva = 25.0;
      }  if (latitud >= 30.0) {
        latitudEfectiva = 30.0;
      }  if (latitud >= 35.0) {
        latitudEfectiva = 35.0;
      }  if (latitud >= 40.0) {
        latitudEfectiva = 40.0;
      }  if (latitud >= 42.0) {
        latitudEfectiva = 42.0;
      }  if (latitud >= 44.0) {
        latitudEfectiva = 44.0;
      }  if (latitud >= 46.0) {
        latitudEfectiva = 46.0;
      }  if (latitud >= 48.0) {
        latitudEfectiva = 48.0;
      }  if (latitud >= 50.0) {
        latitudEfectiva = 50.0;
      }  if (latitud >= 52.0) {
        latitudEfectiva = 52.0;
      }  if (latitud >= 54.0) {
        latitudEfectiva = 54.0;
      }  if (latitud >= 56.0) {
        latitudEfectiva = 56.0;
      }  if (latitud >= 58.0) {
        latitudEfectiva = 58.0;
      }  if (latitud >= 60.0) {
        latitudEfectiva = 60.0;
      }
    } else {
      latitudEfectiva = 0.0;
      if (latitud <= -5.0) {
        latitudEfectiva = -5.0;
      } else if (latitud <= -10.0) {
        latitudEfectiva = -10.0;
      } else if (latitud <= -15.0) {
        latitudEfectiva = -15.0;
      } else if (latitud <= -20.0) {
        latitudEfectiva = -20.0;
      } else if (latitud <= -25.0) {
        latitudEfectiva = -25.0;
      } else if (latitud <= -30.0) {
        latitudEfectiva = -30.0;
      } else if (latitud <= -35.0) {
        latitudEfectiva = -35.0;
      } else if (latitud <= -40.0) {
        latitudEfectiva = -40.0;
      } else if (latitud <= -42.0) {
        latitudEfectiva = -42.0;
      } else if (latitud <= -44.0) {
        latitudEfectiva = -44.0;
      } else if (latitud <= -46.0) {
        latitudEfectiva = -46.0;
      } else if (latitud <= -48.0) {
        latitudEfectiva = -48.0;
      } else if (latitud <= -50.0) {
        latitudEfectiva = -50.0;
      } else if (latitud <= -52.0) {
        latitudEfectiva = -52.0;
      } else if (latitud <= -54.0) {
        latitudEfectiva = -54.0;
      } else if (latitud <= -56.0) {
        latitudEfectiva = -56.0;
      } else if (latitud <= -58.0) {
        latitudEfectiva = -58.0;
      } else if (latitud <= -60.0) {
        latitudEfectiva = -60.0;
      }
    }

    List<Map> results = await db.query('HORAS_DIURNAS_MENSUALES',
        where: 'latitud = ? AND mes = ?', whereArgs: [latitudEfectiva, mes]);

    if (results.length > 0) {
      HorasDiurnasMensuales hdm =
      new HorasDiurnasMensuales.fromMap(results.first);
      return hdm.porcentajeHoras;
    }
    return null;
  }
}
