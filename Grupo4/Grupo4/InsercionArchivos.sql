--Importar datos desde un archivo
--Primero creamos una tabla temporal para poder bajar todos los datos y luego almacenarlos en nuestras tablas permanentes
--teniendo en cuenta los duplicados, etc

------------------------------------------------------------------------------------------------------------------------------------------------
----																																		----
----										En este mismo query se encuentran los scripts pertenecientes									----
----										A la entrega 5 										----
----										Para importar los archivos, separamos el excel .xlsx en distintos .csv							----
----																																		----
------------------------------------------------------------------------------------------------------------------------------------------------

USE ClubSolNorte
go

--Para importar los socios del archivo "Responsables_de_pago.csv" Creeamos el siguiente SP
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
		CAST(SUBSTRING(NroSocio, 4, 4) AS INT),  --castea el nro de socio que venia como un varchar, toma 4 caracteres a partir de la posición 4 y lo toma como un INT
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

    PRINT 'Importación completada correctamente.'

	DROP TABLE #TemporalSocio
END
GO


EXEC dbsl.spImportarSocios 'La ruta de su archivo Responsables_de_pago.csv'
--EXEC dbsl.spImportarSocios 'C:\ARCHIVOS\Responsables_de_pago.csv'
--EXEC dbsl.spImportarSocios 'C:\Users\leand\Desktop\TPI-2025-1C\csv\Responsables_de_pago.csv'
--EXEC dbsl.spImportarSocios 'C:\Users\Usuario\Desktop\Responsables_de_pago.csv'

--Visualizar los resultados
SELECT * FROM dbsl.Socio
SELECT * FROM dbsl.GrupoFamiliar
DELETE FROM dbsl.Socio

--Para importar los socios del archivo "Grupo_familiar.csv" Creamos el siguiente SP

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

    --Insertar socios evitando duplicados
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

EXEC dbsl.spImportarGrupoFamiliar 'La ruta de su archivo Responsables_de_pago.csv'
--EXEC dbsl.spImportarGrupoFamiliar 'C:\ARCHIVOS\Grupo_familiar .csv'
--EXEC dbsl.spImportarGrupoFamiliar 'C:\Users\leand\Desktop\TPI-2025-1C\csv\Grupo_familiar.csv'
--EXEC dbsl.spImportarGrupoFamiliar 'C:\Users\Usuario\Desktop\Grupo_familiar.csv'

--Visualizar resultado
select * from dbsl.Socio

----------------------------Carga Categoria de socio-----------------------------------------------------------------------------------------------

--Como las tarifas estaban colocadas de forma desordenada dentro de un csv y eran pocos registros, decidimos agregarlas manualmente a traves de un SP
--Si queremos agregar un nuevo registro, el ultimo parametro debe ser "c" y si queremos editar alguna tarifa, el ultimo parametro debe ser "e".
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

--Como las tarifas estaban colocadas de forma desordenada dentro de un csv y eran pocos registros, decidimos agregarlas manualmente a traves de un SP
--Si queremos agregar un nuevo registro, el ultimo parametro debe ser "c" y si queremos editar alguna tarifa, el ultimo parametro debe ser "e".
CREATE OR ALTER PROCEDURE dbsl.CargarEditarActividad (@Estado VARCHAR(15),@nombreActividad VARCHAR(50),@costo INT,@accion CHAR)
AS
BEGIN

	SET NOCOUNT ON;
	
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
EXEC dbsl.CargarEditarActividad '31/05/2025','Vóley', 30000,'c'
EXEC dbsl.CargarEditarActividad '31/05/2025','Taekwondo', 25000,'c'
EXEC dbsl.CargarEditarActividad '31/05/2025','Baile artístico', 30000,'c'
EXEC dbsl.CargarEditarActividad '31/05/2025','Natación', 45000,'c'
EXEC dbsl.CargarEditarActividad '31/05/2025','Ajedrez', 2000,'c'

SELECT * FROM dbsl.Actividad


------------------------------------CARGAR PiletaVerano------------------------------------------------------------------------------------------------
--Cargamos cuales son las tarifas desde el inicio de la temporada de verano hasta su fin. 
--Pusimos todas y cada una de las fechas porque aprovechamos esta tabla para indicar tambien si
--Hubo lluvia para x fecha o no.

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
	('Día', '2025-02-28', 25000, 30000, 15000, 2000),
	('Temporada', '2025-02-28', 2000000, 0, 1200000, 0),
	('Mes', '2025-02-28', 625000, 0, 375000, 0)

    DECLARE 
        @fecha DATE = '2024-12-01',
        @fin DATE = '2025-02-28';

    WHILE @fecha <= @fin
    BEGIN
        -- Día-------------------------------------
        INSERT INTO dbsl.PiletaVerano(Fecha, TipoDePase, CostoSocioAdulto, CostoInvitadoAdulto, CostoSocioMenor, CostoInvitadoMenor)
        SELECT @fecha, TipoDePase, CostoSocioAdulto, CostoInvitadoAdulto, CostoSocioMenor, CostoInvitadoMenor
        FROM #TemporalTarifaPileta
        WHERE TipoDePase = 'Día';

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

EXEC dbsl.spCargarPiletaVerano

SELECT * from dbsl.PiletaVerano

---------------------------Cargar Archivos de clima 2024 y 2025-----------------------------------------------------------------------------------

--Importamos ambos archivos de lluvia al mismo tiempo, por eso, el segundo parametro puede ser nulo por si en algun futuro
--se quisiera importar uno solo.
--Tuivimos que eliminar las 3 primeras filas de los archivos porque tenian 6 columnas mientras que a partir de la fila 4, las
--filas eran de 5 columnas. Aunque haciamos el bulk insert con "FIRSTROW=5" para que saltee las filas que molestaban, siempre 
--habia un error "Cannot obtain the required interface ("IID_IColumnsInfo") from OLE DB provider "BULK""

CREATE OR ALTER PROCEDURE dbsl.spImportarLluvia
    @RutaArchivo NVARCHAR(300),
    @RutaArchivo2 NVARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #TempLluvia (
        FechaHora VARCHAR(50),
        Temperatura VARCHAR(20),
        Lluvia VARCHAR(20),
        Humedad VARCHAR(20),
        Viento VARCHAR(20)
    );

    BEGIN TRY
        --Primer archivo importado
        DECLARE @sql NVARCHAR(MAX) =
        N'
        BULK INSERT #TempLluvia
        FROM ''' + @RutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR  = ''0x0a'',
            CODEPAGE = ''65001'',
            TABLOCK
        );';
        EXEC sp_executesql @sql;

        
        INSERT INTO dbsl.Lluvia (Fecha, Hora, Lluvia)
        SELECT
            TRY_CAST(LEFT(FechaHora,10) AS date),
            TRY_CAST(SUBSTRING(FechaHora,12,5)+':00' AS time),
            TRY_CAST(Lluvia AS float)
        FROM #TempLluvia T
        WHERE Lluvia IS NOT NULL
          AND NOT EXISTS (-- Evito duplicados porque ambos archivos csv tienen fechas iguales desde el 1-1-2025 
              SELECT 1
              FROM dbsl.Lluvia L
              WHERE L.Fecha = TRY_CAST(LEFT(T.FechaHora,10) AS date)
                AND  L.Hora  = TRY_CAST(SUBSTRING(T.FechaHora,12,5)+':00' AS time)
          );

        -- Limpiar para segundo archivo
        DELETE FROM #TempLluvia;

        --------------------------------------------------SEGUNDO ARCHIVO ------------------------
        IF @RutaArchivo2 IS NOT NULL
        BEGIN
            SET @sql =
            N'
            BULK INSERT #TempLluvia
            FROM ''' + @RutaArchivo2 + '''
            WITH (
                FIRSTROW = 2,
                FIELDTERMINATOR = '','',
                ROWTERMINATOR  = ''0x0a'',
                CODEPAGE = ''65001'',
                TABLOCK
            );';
            EXEC sp_executesql @sql;

            -- Insertar sin duplicar
            INSERT INTO dbsl.Lluvia (Fecha, Hora, Lluvia)
            SELECT
                TRY_CAST(LEFT(FechaHora,10) AS date),
                TRY_CAST(SUBSTRING(FechaHora,12,5)+':00' AS time),
                TRY_CAST(Lluvia AS float)
            FROM #TempLluvia T
            WHERE Lluvia IS NOT NULL
              AND NOT EXISTS (-- Evito duplicados porque ambos archivos csv tienen fechas iguales desde el 1-1-2025 
                  SELECT 1
                  FROM dbsl.Lluvia L
                  WHERE L.Fecha = TRY_CAST(LEFT(T.FechaHora,10) AS date)
                    AND  L.Hora  = TRY_CAST(SUBSTRING(T.FechaHora,12,5)+':00' AS time)
              );
        END
	
     ------------------------ ACTUALIZAR PiletaVerano-------
	 --Atraves de la informacion recientemente importada de los csv, podemos actuzalizar que dias de la tabla "PiletaVerano" fueron de lluvia
	 --Para mas adelante poder trabajar con los reembolsos.
        UPDATE PV
        SET PV.Lluvia =
            CASE
                WHEN EXISTS (
                    SELECT 1
                    FROM dbsl.Lluvia L
                    WHERE L.Fecha = PV.Fecha
                      AND L.Hora BETWEEN '08:00:00' AND '20:00:00' --Solo nos importa si llovió en horario operativo del club.
                      AND L.Lluvia > 0
                )
                THEN 1
                ELSE 0
            END
        FROM dbsl.PiletaVerano PV;

        PRINT 'Importación y actualización de lluvia completadas correctamente.';
    END TRY
    BEGIN CATCH
        PRINT 'Ocurrió un error durante el proceso de importación.';
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO


--EXEC  dbsl.ActualizarLluviaDesdeArchivo 'C:\ARCHIVOS\open-meteo-buenosaires_2025.csv'

EXEC dbsl.spImportarLluvia
    'C:\Users\leand\Desktop\TPI-2025-1C\csv\open-meteo-buenosaires_2024.csv',
    'C:\Users\leand\Desktop\TPI-2025-1C\csv\open-meteo-buenosaires_2025.csv';

EXEC dbsl.spImportarLluvia
    'C:\ARCHIVOS\open-meteo-buenosaires_2024.csv',
    'C:\ARCHIVOS\open-meteo-buenosaires_2025.csv';

EXEC dbsl.spImportarLluvia
    'Coloque la ruta de su archivo 1',
    'Coloque la ruta de su archivo 2';



------------------------------------CARGAR Presentismo------------------------------------------------------------------------------------------------
--Importamos el archivo Presentismo_actividades y luego actualizamos el ID Actividad en la misma tabla relacionandola con la tabla
--actividades

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
       
        -- Armar BULK INSERT dinámico
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
        PRINT 'Importación exitosa.';

    END TRY
    BEGIN CATCH
        PRINT 'Ocurrió un error durante la importación.';
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

-----------------------------------------------CategoriaSocio------------------------------------------------------------
--Este procedure actualiza el campo ID CATEGORIA de la Tabla Socio, debido a que dentro de la Tabla Socio, los que venian
--del archivo Responsables no tenian fecha de nac, fueron tomados como mayores.


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



------------------------------------------IMPORTAR CLASES-------------------------------------------------------------------------
--Importamos el archivo Clases_Club, es un archivo propio que fue generado con la idea de poder testear todos los reportes
--y funcionalidades.

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

        -- Armar BULK INSERT dinámico
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
        PRINT 'Importación exitosa.'

		DROP TABLE #TemporalClases

END

EXEC dbsl.spImportarClases 'C:\ARCHIVOS\Clases_Club.csv'
--EXEC dbsl.spImportarClases 'C:\Users\Usuario\Desktop\Clases_Club.csv'


