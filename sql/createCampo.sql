CREATE TABLE IF NOT EXISTS CAMPO (
	idCampo	INTEGER PRIMARY KEY AUTOINCREMENT,
	nombre	TEXT NOT NULL,
	longitud	REAL NOT NULL,
	latitud	REAL NOT NULL,
	fecha_siembra	TEXT NOT NULL,
	eficiencia REAL NOT NULL,
	idRiego	INTEGER NOT NULL,
	idCultivo	INTEGER NOT NULL,
	FOREIGN KEY(idRiego) REFERENCES RIEGO(idRiego),
	FOREIGN KEY(idCultivo) REFERENCES CULTIVO(idCultivo)
);