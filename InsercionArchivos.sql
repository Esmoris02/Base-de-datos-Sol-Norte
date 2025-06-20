--Importar datos desde un archivo
--Primero creamos una tabla temporal para poder bajar todos los datos y luego almacenarlos en nuestras tablas permanentes
--teniendo en cuenta los duplicados, etc
USE ClubSolNorte
go


DROP TABLE dbsl.TemporalSocio

CREATE OR ALTER PROCEDURE dbsl.spImportarSocios
    @RutaArchivo NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON

    CREATE TABLE #TemporalSocio(
    NroSocio CHAR(7),
    Nombre VARCHAR(50),
    Apellido VARCHAR(50),
    Dni VARCHAR(20),
	Email VARCHAR(50),
    FechaNac VARCHAR(20),
    Telefono VARCHAR(20),
    TelefonoEmergencia VARCHAR(20),
    ObraSocial VARCHAR(50),
    NumeroObraSocial VARCHAR(50),
	ContactoObraSocial VARCHAR(30)
)

    -- Importar datos del archivo CSV 

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
    BULK INSERT #TemporalSocio
    FROM ''' + @RutaArchivo + '''
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        ROWTERMINATOR = ''\n'',
        CODEPAGE = ''65001'',
        FORMAT = ''CSV''
    );'

    EXEC sp_executesql @sql
		--Insertar en la tabla Grupo Familiar los socios responsables:
	INSERT INTO dbsl.GrupoFamiliar (ResponsableNombre, Dni)
	SELECT DISTINCT
		 TS.Nombre,
		 TS.Dni
	FROM #TemporalSocio TS
	WHERE NOT EXISTS (
    SELECT 1 FROM dbsl.GrupoFamiliar GF WHERE GF.Dni = TS.Dni
	)

    --Insertar socios (evitar duplicados)
    INSERT INTO dbsl.Socio (
			NroSocio,
            Nombre,
            Apellido,
            Dni,
            FechaNac,
            Telefono,
            TelefonoEmergencia,
            Email,
            ObraSocial,
            NumeroObraSocial
		
			)
    SELECT
		CAST(SUBSTRING(NroSocio, 4, 4) AS INT),  --castea el nro de socio que venia como un varchar, toma 4 caracteres a partir de la posici�n 4 y lo toma como un INT
		Nombre,
		Apellido,
		Dni,
		TRY_CONVERT(DATE, LTRIM(RTRIM(FechaNac)), 103),    --Limpia espacios en blanco y convierte la fecha en formato DATE, aaaa mm dd
        Telefono,  
        TelefonoEmergencia,
        Email,
        ObraSocial,
        NumeroObraSocial
		
    FROM #TemporalSocio TS
    WHERE NOT EXISTS (
        SELECT 1 FROM dbsl.Socio S  WHERE S.NroSocio = CAST(SUBSTRING(TS.NroSocio, 4, 4) AS INT)
    )
	UPDATE S
	SET S.idGrupoFamiliar = GF.idGrupo
	FROM dbsl.Socio S
	INNER JOIN dbsl.GrupoFamiliar GF 
		ON GF.Dni = S.Dni
	WHERE S.idGrupoFamiliar IS NULL;

	SELECT * FROM dbsl.Socio S ORDER BY idGrupoFamiliar
	SELECT * FROM dbsl.GrupoFamiliar G

    PRINT 'Importaci�n completada correctamente.'

	DROP TABLE #TemporalSocio
END

EXEC dbsl.spImportarSocios 'C:\ARCHIVOS\Responsables_de_pago.csv'
--EXEC dbsl.spImportarSocios 'C:\Users\leand\Desktop\TPI-2025-1C\csv\Responsables_de_pago.csv'
--EXEC dbsl.spImportarSocios 'C:\Users\Usuario\Desktop\Responsables_de_pago.csv'


SELECT * FROM dbsl.Socio
SELECT * FROM dbsl.GrupoFamiliar
DELETE FROM dbsl.Socio


CREATE OR ALTER PROCEDURE dbsl.spImportarGrupoFamiliar
    @RutaArchivo NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON

	CREATE TABLE #TemporalGrupoFamiliar
(
	NroSocio VARCHAR(50),
    ResponsableNombre VARCHAR(50),
	Nombre VARCHAR(20),
	Apellido VARCHAR(20),
    Dni VARCHAR(20),
	Email VARCHAR(30),
	FechaNac VARCHAR(20),
	Telefono VARCHAR(20),
    TelefonoEmergencia VARCHAR(20),
    ObraSocial VARCHAR(50),
    NumeroObraSocial VARCHAR(60),
	ContactoObraSocial VARCHAR(30)
)


    -- Importar datos del archivo CSV 

    DECLARE @sql NVARCHAR(MAX)
    SET @sql = '
    BULK INSERT #TemporalGrupoFamiliar
    FROM ''' + @RutaArchivo + '''
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        ROWTERMINATOR = ''\n'',
        CODEPAGE = ''1252'',
        FORMAT = ''CSV''
    );'

    EXEC sp_executesql @sql

    --Insertar socios (evitar duplicados)
    INSERT INTO dbsl.Socio (
		NroSocio,
		Nombre,
		Apellido,
		Dni,
		FechaNac,
		Telefono,
		TelefonoEmergencia,
		Email,
		ObraSocial,
		NumeroObraSocial
	)
	SELECT
    CAST(SUBSTRING(TG.NroSocio, 4, 4) AS INT),
    TG.Nombre,
    TG.Apellido,
    TG.Dni,
    TRY_CONVERT(DATE, LTRIM(RTRIM(TG.FechaNac)), 103),
    TG.Telefono,
    TG.TelefonoEmergencia,
    TG.Email,
    TG.ObraSocial,
    TG.NumeroObraSocial
	FROM #TemporalGrupoFamiliar TG
	WHERE NOT EXISTS (
    SELECT 1 FROM dbsl.Socio S
    WHERE S.NroSocio = CAST(SUBSTRING(TG.NroSocio, 4, 4) AS INT)
	);
	UPDATE S
	SET S.idGrupoFamiliar = GF.idGrupo
	FROM dbsl.Socio S
	INNER JOIN #TemporalGrupoFamiliar TG
		ON S.NroSocio = CAST(SUBSTRING(TG.NroSocio, 4, 4) AS INT)
	INNER JOIN dbsl.Socio SR -- socio responsable
		ON SR.NroSocio = TRY_CAST(SUBSTRING(TG.ResponsableNombre, 4, 4) AS INT)
	INNER JOIN dbsl.GrupoFamiliar GF
		ON GF.Dni = SR.Dni
	WHERE S.idGrupoFamiliar IS NULL;
	
	SELECT * FROM dbsl.Socio S ORDER BY S.idGrupoFamiliar

    PRINT 'Importacion completada correctamente.'

	DROP TABLE #TemporalGrupoFamiliar
END

EXEC dbsl.spImportarGrupoFamiliar 'C:\ARCHIVOS\Grupo_familiar .csv'
--EXEC dbsl.spImportarGrupoFamiliar 'C:\Users\leand\Desktop\TPI-2025-1C\csv\Grupo_familiar.csv'
--EXEC dbsl.spImportarGrupoFamiliar 'C:\Users\Usuario\Desktop\Grupo_familiar.csv'
select * from dbsl.Socio

----------------------------Carga Categoria de socio-----------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE dbsl.CargarEditarCategoriaSocio(@NombreCategoria varchar(50), @EdadDesde INT,@EdadHasta INT, @Costo INT,@VigenteHasta VARCHAR(15),@Accion CHAR)
AS
BEGIN
	if @accion = 'c'
		BEGIN
			INSERT INTO dbsl.CategoriaSocio(NombreCategoria,EdadDesde,EdadHasta,Costo,VigenteHasta)
			VALUES(@NombreCategoria,
			@EdadDesde,
			@EdadHasta,
			@Costo,
			@VigenteHasta)
		END
	else if @Accion = 'e'
		BEGIN
			UPDATE dbsl.CategoriaSocio
			SET Costo = @Costo
			WHERE NombreCategoria = @NombreCategoria
		END
	else
		BEGIN
			print 'El ultimo parametro debe ser "e" para editar algun valor o "c" para crear uno nuevo"'
		END

END
GO

EXEC dbsl.CargarEditarCategoriaSocio 'Menor',0,12,10000,'31/05/2025','c'
EXEC dbsl.CargarEditarCategoriaSocio 'Cadete',13,17,15000,'31/05/2025','c'
EXEC dbsl.CargarEditarCategoriaSocio 'Mayor',18,99,25000,'31/05/2025','c'

SELECT * FROM dbsl.CategoriaSocio	
 

----------------------------Carga Actividades-----------------------------------------------------------------------------------------------


CREATE OR ALTER PROCEDURE dbsl.CargarEditarActividad (@Estado VARCHAR(15),@nombreActividad VARCHAR(50),@costo INT,@accion CHAR)
AS
BEGIN
	
	if @accion = 'c'
		BEGIN

		INSERT INTO dbsl.Actividad(Estado,NombreActividad,Costo)
		VALUES(
			@Estado,
			@nombreActividad,
			@costo
			)
	END
	else if @accion = 'e'
		BEGIN
		UPDATE dbsl.Actividad
		SET Costo = @costo
		WHERE NombreActividad = @nombreActividad
	END
	else
		BEGIN
		PRINT 'El ultimo parametro debe ser "e" para editar algun valor o "c" para crear uno nuevo"'
	END
END
GO

EXEC dbsl.CargarEditarActividad '31/05/2025','Futsal', 25000,'c'
EXEC dbsl.CargarEditarActividad '31/05/2025','V�ley', 30000,'c'
EXEC dbsl.CargarEditarActividad '31/05/2025','Taekwondo', 25000,'c'
EXEC dbsl.CargarEditarActividad '31/05/2025','Baile art�stico', 30000,'c'
EXEC dbsl.CargarEditarActividad '31/05/2025','Nataci�n', 45000,'c'
EXEC dbsl.CargarEditarActividad '31/05/2025','Ajedrez', 2000,'c'

SELECT * FROM dbsl.Actividad
SELECT * FROM dbsl.PresentismoClases

---------------------------Cargar Lluvia-----------------------------------------------------------------------------------
CREATE VIEW dbsl.VLluviaDia AS
	SELECT
			fecha,
			CASE
				WHEN SUM(CASE WHEN Precipitacion > 0 THEN 1 ELSE 0 END) > 0 THEN 1
			ELSE 0
			END AS llovio
	FROM dbsl.Lluvia
	WHERE hora BETWEEN '08:00:00' AND '20:00:00'
	GROUP BY fecha

SELECT*FROM dbsl.Lluvia
SELECT*FROM dbsl.PiletaVerano

CREATE OR ALTER PROCEDURE dbsl.ActualizarLluviaDesdeArchivo
    @RutaArchivo NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON

    -- Crear tabla temporal para importar los datos del CSV
    CREATE TABLE #TempLluvia (
        time VARCHAR(20),
        temperatura FLOAT,
        lluvia FLOAT,
        humedad INT,
        viento FLOAT
    )

    -- Importar desde archivo CSV ( fila 3)
	DECLARE @sql NVARCHAR(MAX)
    SET @sql = '
    BULK INSERT #TempLluvia
    FROM ''' + @RutaArchivo + '''
    WITH (
        FORMAT = ''CSV'',
        FIRSTROW = 5,
        FIELDTERMINATOR = '','',
        ROWTERMINATOR = ''\n'',
        CODEPAGE = ''1252''
    );'

	EXEC sp_executesql @sql

    -- Insertar los datos en la tabla Lluvia
    INSERT INTO dbsl.Lluvia (fecha, hora, Precipitacion)
    SELECT
        CAST(LEFT(time, 10) AS DATE),
        CAST(SUBSTRING(time, 12, 5) + ':00' AS TIME),
        Precipitacion
    FROM #TempLluvia


	UPDATE PV
	SET PV.Lluvia = V.llovio
	FROM dbsl.PiletaVerano PV
	JOIN dbsl.VLluviaDia V ON PV.Fecha = V.fecha

	 DROP TABLE #TempLluvia
END

EXEC  dbsl.ActualizarLluviaDesdeArchivo 'C:\ARCHIVOS\open-meteo-buenosaires_2025.csv'
--EXEC dbsl.ActualizarLluviaDesdeArchivo 'C:\Users\leand\Desktop\TPI-2025-1C\open-meteo-buenosaires_2025.csv'

------------------------------------CARGAR PiletaVerano------------------------------------------------------------------------------------------------

CREATE PROCEDURE dbsl.CrearTablaTemporalTarifaPileta
AS
BEGIN
	CREATE TABLE #TemporalTarifaPileta (
    TipoDePase VARCHAR(20),
    VigenteHasta DATE,
    CostoSocioAdulto INT,
    CostoInvitadoAdulto INT,
    CostoSocioMenor INT,
    CostoInvitadoMenor INT
	)

	INSERT INTO #TemporalTarifaPileta
	VALUES
	('D�a', '2025-02-28', 25000, 30000, 15000, 2000),
	('Temporada', '2025-02-28', 2000000, 0, 1200000, 0),
	('Mes', '2025-02-28', 625000, 0, 375000, 0)

	DROP TABLE #TemporalTarifaPileta

END



CREATE OR ALTER PROCEDURE dbsl.spCargarPiletaVerano
AS
BEGIN
    SET NOCOUNT ON

	CREATE TABLE #TemporalTarifaPileta (
    TipoDePase VARCHAR(20),
    VigenteHasta DATE,
    CostoSocioAdulto INT,
    CostoInvitadoAdulto INT,
    CostoSocioMenor INT,
    CostoInvitadoMenor INT
	)

	INSERT INTO #TemporalTarifaPileta
	VALUES
	('D�a', '2025-02-28', 25000, 30000, 15000, 2000),
	('Temporada', '2025-02-28', 2000000, 0, 1200000, 0),
	('Mes', '2025-02-28', 625000, 0, 375000, 0)

    DECLARE 
        @fecha DATE = '2024-12-01',
        @fin DATE = '2025-02-28';

    WHILE @fecha <= @fin
    BEGIN
        -- D�a-------------------------------------
        INSERT INTO dbsl.PiletaVerano(Fecha, TipoDePase, CostoSocioAdulto, CostoInvitadoAdulto, CostoSocioMenor, CostoInvitadoMenor)
        SELECT @fecha, TipoDePase, CostoSocioAdulto, CostoInvitadoAdulto, CostoSocioMenor, CostoInvitadoMenor
        FROM #TemporalTarifaPileta
        WHERE TipoDePase = 'D�a';

        -- Temporada--------------------------
        INSERT INTO dbsl.PiletaVerano(Fecha, TipoDePase, CostoSocioAdulto, CostoInvitadoAdulto, CostoSocioMenor, CostoInvitadoMenor)
        SELECT @fecha, TipoDePase, CostoSocioAdulto, CostoInvitadoAdulto, CostoSocioMenor, CostoInvitadoMenor
        FROM #TemporalTarifaPileta
        WHERE TipoDePase = 'Temporada';

        -- Mes------------------------
        INSERT INTO dbsl.PiletaVerano(Fecha, TipoDePase, CostoSocioAdulto, CostoInvitadoAdulto, CostoSocioMenor, CostoInvitadoMenor)
        SELECT @fecha, TipoDePase, CostoSocioAdulto, CostoInvitadoAdulto, CostoSocioMenor, CostoInvitadoMenor
        FROM #TemporalTarifaPileta
        WHERE TipoDePase = 'Mes';

        SET @fecha = DATEADD(DAY, 1, @fecha);
    END

    PRINT 'Carga de PiletaVerano completada correctamente.'

	
END

--Ejecutar los dos al mismo tiempo
--EXEC dbsl.CrearTablaTemporalTarifaPileta
EXEC dbsl.spCargarPiletaVerano

SELECT * from dbsl.PiletaVerano


CREATE OR ALTER PROCEDURE dbsl.spImportarPresentismo
    @RutaArchivo NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON

	CREATE  TABLE #TemporalPresentismo
(
	NroSocio VARCHAR(50),
    Actividad VARCHAR(50),
	FechaDeAsistencia VARCHAR(50),
	Asistencia VARCHAR(20),
	Profesor VARCHAR(50),
	Nada1 VARCHAR(50) NULL,
	Nada2 VARCHAR(50) NULL,
	Nada3 VARCHAR(50) NULL,
	Nada4 VARCHAR(50) NULL

)

    BEGIN TRY
       
        -- Armar BULK INSERT din�mico
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = '
        BULK INSERT #TemporalPresentismo
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',  
            CODEPAGE = ''1252'',     
			TABLOCK

        );';

        EXEC sp_executesql @sql;

        -- Insertar en tabla final
        INSERT INTO dbsl.PresentismoClases (
            NombreActividad,
            NroSocio,
            Fecha,
            Asistencia
        )
        SELECT
            TP.Actividad,
            TRY_CAST(SUBSTRING(TP.NroSocio, 4, 4) AS INT),
            TRY_CONVERT(DATE, LTRIM(RTRIM(TP.FechaDeAsistencia)), 103),
            LEFT(RTRIM(TP.Asistencia), 1)
        FROM #TemporalPresentismo TP;
		SELECT * FROM #TemporalPresentismo
        PRINT 'Importaci�n exitosa.';

    END TRY
    BEGIN CATCH
        PRINT 'Ocurri� un error durante la importaci�n.';
        PRINT ERROR_MESSAGE();
    END CATCH

	UPDATE P
	SET P.idActividad = A.idActividad
	FROM dbsl.PresentismoClases P
	JOIN dbsl.Actividad A ON P.NombreActividad = A.NombreActividad

	UPDATE 

	DROP TABLE #TemporalPresentismo
END

EXEC dbsl.spImportarPresentismo 'C:\ARCHIVOS\presentismo_actividades .csv'
--EXEC dbsl.spImportarPresentismo 'C:\Users\Usuario\Desktop\presentismo_actividades.csv'

SELECT * FROM dbsl.PresentismoClases

CREATE OR ALTER PROCEDURE dbsl.spActualizaCategoriaSocio
AS
BEGIN

	-- Socios con fecha de nacimiento
	UPDATE S
	SET S.idCategoria = C.idCategoria
	FROM dbsl.Socio S
	JOIN dbsl.CategoriaSocio C
    ON DATEDIFF(YEAR, S.FechaNac, GETDATE()) BETWEEN C.EdadDesde AND C.EdadHasta
	WHERE S.FechaNac IS NOT NULL;

-- Socios sin fecha de nacimiento (asumidos como Mayores)
	UPDATE S
	SET S.idCategoria = C.idCategoria
	FROM dbsl.Socio S
	JOIN dbsl.CategoriaSocio C ON C.NombreCategoria = 'Mayor'
	WHERE S.FechaNac IS NULL;

END
EXEC dbsl.spActualizaCategoriaSocio

SELECT * from dbsl.PresentismoClases
SELECT * FROM dbsl.Actividad
SELECT * from dbsl.Socio
SELECT * FROM dbsl.Clase
SELECT * FROM dbsl.Inscripcion

CREATE OR ALTER PROCEDURE dbsl.spImportarClases
    @RutaArchivo NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON

	CREATE  TABLE #TemporalClases
(
	Estado VARCHAR(50),
	Horario VARCHAR(50),
	Dia VARCHAR(50),
	Categoria VARCHAR(50),
	idActividad VARCHAR(50)
	
)

        -- Armar BULK INSERT din�mico
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = '
        BULK INSERT #TemporalClases
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',  
            CODEPAGE = ''65001'',      
			TABLOCK

        );';

        EXEC sp_executesql @sql;

        -- Insertar en tabla final
        INSERT INTO dbsl.Clase (
            Estado,
            Horario,
            Dia,
            Categoria,
			idActividad
        )
        SELECT
            TC.Estado,
            TC.Horario,
            TC.Dia,
            TC.Categoria,
			TC.idActividad
        FROM #TemporalClases TC;
		SELECT * FROM #TemporalClases
        PRINT 'Importaci�n exitosa.'

		DROP TABLE #TemporalClases

END

EXEC dbsl.spImportarClases 'C:\ARCHIVOS\Clases_Club.csv'
--EXEC dbsl.spImportarClases 'C:\Users\Usuario\Desktop\Clases_Club.csv'

SELECT * FROM dbsl.Cobro  
SELECT * FROM dbsl.Clase
SELECT * FROM dbsl.Colonia 
SELECT * FROM dbsl.PresentismoClases
SELECT * FROM dbsl.Actividad
SELECT * FROM dbsl.Socio
SELECT * FROM dbsl.CategoriaSocio
SELECT * FROM dbsl.Inscripcion  
SELECT * FROM dbsl.Invitado
drop table dbsl.Clase

------REPORTE 3 NO TOCAR
SELECT 
    CS.NombreCategoria,
    P.NombreActividad,
    COUNT(DISTINCT P.NroSocio) AS CantidadSociosConFaltas,
    COUNT(*) AS TotalInasistencias
FROM dbsl.PresentismoClases P
JOIN dbsl.Socio S ON P.NroSocio = S.NroSocio
JOIN dbsl.CategoriaSocio CS ON S.idCategoria = CS.idCategoria
WHERE P.Asistencia = 'A'
GROUP BY 
    CS.NombreCategoria,
    P.NombreActividad
ORDER BY 
    TotalInasistencias DESC;

------REPORTE 3 NO TOCAR