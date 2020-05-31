CREATE TABLE IF NOT EXISTS CULTIVO_TIENE_ETAPAS (
	idCultivoTieneEtapas	INTEGER PRIMARY KEY AUTOINCREMENT,
	idCultivo	INTEGER NOT NULL,
	idEtapa	INTEGER NOT NULL,
	kc	REAL NOT NULL,
	duracion	INTEGER NOT NULL,
	FOREIGN KEY(idEtapa) REFERENCES ETAPA(idEtapa),
	FOREIGN KEY(idCultivo) REFERENCES CULTIVO(idCultivo)
);