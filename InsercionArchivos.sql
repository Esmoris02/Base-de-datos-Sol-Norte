--Importar datos desde un archivo
--Primero creamos una tabla temporal para poder bajar todos los datos y luego almacenarlos en nuestras tablas permanentes
--teniendo en cuenta los duplicados, etc

CREATE TABLE dbsl.TemporalSocio(
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

DROP TABLE dbsl.TemporalSocio

CREATE OR ALTER PROCEDURE dbsl.spImportarSocios
    @RutaArchivo NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON

    DELETE FROM dbsl.TemporalSocio; --Eliminamos el contenido de la tabla temporal

    -- Importar datos del archivo CSV 

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = '
    BULK INSERT dbsl.TemporalSocio
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
	FROM dbsl.TemporalSocio TS
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
    FROM dbsl.TemporalSocio TS
    WHERE NOT EXISTS (
        SELECT 1 FROM dbsl.Socio S  WHERE S.NroSocio = CAST(SUBSTRING(TS.NroSocio, 4, 4) AS INT)
    )

    PRINT 'Importación completada correctamente.'
END

EXEC dbsl.spImportarSocios 'C:\Users\leand\Desktop\TPI-2025-1C\csv\Responsables_de_pago.csv'

SELECT * FROM dbsl.Socio
SELECT * FROM dbsl.GrupoFamiliar
DELETE FROM dbsl.Socio

CREATE TABLE dbsl.TemporalGrupoFamiliar
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
DROP TABLE dbsl.TemporalGrupoFamiliar

CREATE OR ALTER PROCEDURE dbsl.spImportarGrupoFamiliar
    @RutaArchivo NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON

    DELETE FROM dbsl.TemporalGrupoFamiliar; --Eliminamos el contenido de la tabla temporal

    -- Importar datos del archivo CSV 

    DECLARE @sql NVARCHAR(MAX)
    SET @sql = '
    BULK INSERT dbsl.TemporalGrupoFamiliar
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
    FROM dbsl.TemporalGrupoFamiliar TG
    WHERE NOT EXISTS (
        SELECT 1 FROM dbsl.Socio S  WHERE  S.NroSocio = CAST(SUBSTRING(TG.NroSocio, 4, 4) AS INT)
    )

    PRINT 'Importación completada correctamente.'
END

EXEC dbsl.spImportarGrupoFamiliar 'C:\Users\leand\Desktop\TPI-2025-1C\csv\Grupo_familiar.csv'

select * from dbsl.Socio

----------------------------Carga Categoria de socio-----------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE dbsl.cargar_editar_CategoriaSocio(@NombreCategoria varchar(50), @EdadDesde INT,@EdadHasta INT, @Costo INT,@VigenteHasta VARCHAR(15),@Accion CHAR)
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

ALTER TABLE dbsl.CategoriaSocio
ADD VigenteHasta VARCHAR(15)

EXEC dbsl.cargar_editar_CategoriaSocio 'Menor',0,12,10000,'31/05/2025','c'
EXEC dbsl.cargar_editar_CategoriaSocio 'Cadete',13,17,15000,'31/05/2025','c'
EXEC dbsl.cargar_editar_CategoriaSocio 'Mayor',18,99,25000,'31/05/2025','c'

SELECT * FROM dbsl.CategoriaSocio	
 

----------------------------Carga Actividades-----------------------------------------------------------------------------------------------


CREATE OR ALTER PROCEDURE dbsl.cargar_editar_actividad (@Estado VARCHAR(15),@nombreActividad VARCHAR(50),@costo INT,@accion CHAR)
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
end
GO

exec dbsl.cargar_editar_actividad '31/05/2025','Futsal', 25000,'c'
exec dbsl.cargar_editar_actividad '31/05/2025','Voley', 30000,'c'
exec dbsl.cargar_editar_actividad '31/05/2025','Taekwondo', 25000,'c'
exec dbsl.cargar_editar_actividad '31/05/2025','Baile artistico', 30000,'c'
exec dbsl.cargar_editar_actividad '31/05/2025','Natacion', 45000,'c'
exec dbsl.cargar_editar_actividad '31/05/2025','Ajedrez', 2000,'c'

select* from dbsl.Actividad

select * from dbsl.PiletaVerano

----------------------------Carga Pileta Verano-----------------------------------------------------------------------------------------------
SELECT * FROM dbsl.PiletaVerano

