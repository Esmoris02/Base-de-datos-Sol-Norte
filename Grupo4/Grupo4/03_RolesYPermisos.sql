USE master;
GO

--Creación de logins dentro para cada usuario individual
CREATE LOGIN login_adminClub
WITH PASSWORD = '#SN012025ad',
     CHECK_POLICY = ON;


CREATE LOGIN login_jefeDeTesoreria 
WITH PASSWORD = '#SN012025a',
     DEFAULT_DATABASE = ClubSolNorte,
     CHECK_POLICY = ON;

CREATE LOGIN login_administrativoCobranza
WITH PASSWORD = '#SN012025b',
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_administrativoMorosidad 
WITH PASSWORD = '#SN012025c',
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_administrativoFacturacion
WITH PASSWORD = '#SN012025d',
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_administrativoSocio 
WITH PASSWORD = '#SN012025e',
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_socioWeb
WITH PASSWORD = '#SN012025f',
	DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_presidente
WITH PASSWORD = '#SN012025g', 
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_vicepresidente
WITH PASSWORD = '#SN012025h',
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_secretario
WITH PASSWORD = '#SN012025i',
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_vocales
WITH PASSWORD = '#SN012025j',
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;


GO
USE ClubSolNorte
GO

--Creación de roles dentro de ClubSolNorte
CREATE ROLE dbsl_Tesoreria;
GO
CREATE ROLE dbsl_Socio;
GO
CREATE ROLE dbsl_Autoridad;
GO

--Creación de usuarios para cada login
CREATE USER adminClub FOR LOGIN login_adminClub;

CREATE USER jefeDeTesoreria FOR LOGIN login_jefeDeTesoreria;
CREATE USER administrativoCobranza FOR LOGIN login_administrativoCobranza;
CREATE USER administrativoMorosidad FOR LOGIN login_administrativoMorosidad;
CREATE USER administrativoFacturacion FOR LOGIN login_administrativoFacturacion;

CREATE USER administrativoSocio FOR LOGIN login_administrativoSocio;
CREATE USER socioWeb FOR LOGIN login_socioWeb;

CREATE USER presidente FOR LOGIN login_presidente;
CREATE USER vicepresidente FOR LOGIN login_vicepresidente;
CREATE USER secretario FOR LOGIN login_secretario;
CREATE USER vocales FOR LOGIN login_vocales;
GO

--Añadiendo los usuarios a los roles
ALTER ROLE db_owner ADD MEMBER adminClub;

ALTER ROLE dbsl_Tesoreria ADD MEMBER jefeDeTesoreria;
ALTER ROLE dbsl_Tesoreria ADD MEMBER administrativoCobranza;
ALTER ROLE dbsl_Tesoreria ADD MEMBER administrativoMorosidad;
ALTER ROLE dbsl_Tesoreria ADD MEMBER administrativoFacturacion;


ALTER ROLE dbsl_Socio ADD MEMBER administrativoSocio;
ALTER ROLE dbsl_Socio ADD MEMBER socioWeb;

ALTER ROLE dbsl_Autoridad ADD MEMBER presidente;
ALTER ROLE dbsl_Autoridad ADD MEMBER vicepresidente;
ALTER ROLE dbsl_Autoridad ADD MEMBER secretario;
ALTER ROLE dbsl_Autoridad ADD MEMBER vocales;
GO
-- Dando permisos a los roles
-- Tesorería puede leer y modificar facturas y cobros
GRANT SELECT, INSERT, UPDATE ON dbsl.Factura TO dbsl_Tesoreria;
GRANT SELECT, INSERT, UPDATE ON dbsl.Cobro TO dbsl_Tesoreria;
GRANT SELECT, UPDATE ON dbsl.MetodoPago TO dbsl_Tesoreria;
GO
--Los socios solo pueden leer sus datos e inscripciones
GRANT SELECT ON dbsl.Socio TO dbsl_Socio;
GRANT SELECT ON dbsl.Inscripcion TO dbsl_Socio;
GO
-- Las autoridades pueden leer toda la base pero no modificar nada
GRANT SELECT ON SCHEMA::dbsl TO dbsl_Autoridad;
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'SN_Master16625';
GO
CREATE CERTIFICATE Cert_ClubSolNorte
WITH SUBJECT = 'Certificado para encriptación de datos sensibles de empleados';
GO

CREATE SYMMETRIC KEY SN_DatosSensibles
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE Cert_ClubSolNorte;
GO
ALTER TABLE dbsl.Usuario 
ADD Direccion VARBINARY(256),
	FecNac VARBINARY(256);
GO

CREATE OR ALTER PROCEDURE dbsl.insertarUsuario
	@Usuario VARCHAR(50),
	@Estado VARCHAR(15),
	@Contrasenia VARCHAR(50),
	@Rol VARCHAR(50),
	@FecVig DATE,
	@Direccion VARCHAR(100),
	@FecNac DATE,
	@NroSocio INT = NULL
AS
BEGIN
 
	IF (LEN(TRIM(@Usuario)) = 0 OR EXISTS (SELECT 1 FROM dbsl.Usuario WHERE Usuario = @Usuario))
	BEGIN 
		RAISERROR ('nombre de usuario incorrecto o Usuario ya existente.',16,1)
		RETURN
	END
 
	IF @Estado NOT IN ('activo','inactivo')
	BEGIN 
		RAISERROR ('Estado incorrecto. Establece "activo" o "inactivo"',16,1)
		RETURN
	END
 
	IF @Rol NOT IN ('administrador','profesor','socio')
    BEGIN
        RAISERROR('El rol ingresado no es válido. Debe ser: "administrador","profesor" o "socio"', 16, 1)
        RETURN
    END
 
	IF (@FecVig IS NULL OR @FecVig >= GETDATE() OR @FecVig < '1900-01-01' OR @FecVig > GETDATE())
	BEGIN
		RAISERROR('La fecha no puede ser nula, mayor a la actual o menor al año 1900.', 16, 1)
		RETURN
	END
 
	IF @NroSocio IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbsl.Socio WHERE NroSocio = @NroSocio)
		BEGIN
			RAISERROR('El socio asignado no existe.', 16, 1)
			RETURN
		END
	IF @Direccion IS NULL
		BEGIN
			RAISERROR('La direccion no puede ser nula.', 16, 1)
			RETURN
		END
	IF @FecNac IS NULL OR @FecNac >= GETDATE()
		BEGIN
			RAISERROR('La fecha de nacimiento no puede ser nula, mayor o igual a la actual.', 16, 1)
			RETURN
		END

	OPEN SYMMETRIC KEY SN_DatosSensibles DECRYPTION BY CERTIFICATE Cert_ClubSolNorte;

   
    DECLARE @ContraseniaEncriptada VARBINARY(256) = ENCRYPTBYKEY(KEY_GUID('SN_DatosSensibles'), @Contrasenia);
	DECLARE @DireccionEncriptada VARBINARY(256) = ENCRYPTBYKEY(KEY_GUID('SN_DatosSensibles'), @Direccion);
	DECLARE @FecNacEncriptada VARBINARY(256) = ENCRYPTBYKEY(KEY_GUID('SN_DatosSensibles'), CONVERT(NVARCHAR(30),@FecNac));

    CLOSE SYMMETRIC KEY SN_DatosSensibles;
 
	INSERT INTO dbsl.Usuario(Usuario,Estado,Contrasenia,Rol,FecVig,NroSocio,Direccion,FecNac)
	VALUES (@Usuario, @Estado, @ContraseniaEncriptada, @Rol, @FecVig, @NroSocio, @DireccionEncriptada, @FecNacEncriptada)
END
GO

EXEC dbsl.insertarUsuario 
    @Usuario = 'admin1',
    @Estado = 'activo',
    @Contrasenia = 'AdminPass123',
    @Rol = 'administrador',
    @FecVig = '2025-06-01',
    @Direccion = 'Av. Siempre Viva 123',
    @FecNac = '1990-04-10',
    @NroSocio = NULL;

EXEC dbsl.insertarUsuario 
    @Usuario = 'profesor_maria',
    @Estado = 'activo',
    @Contrasenia = 'ClaseFuerte456',
    @Rol = 'profesor',
    @FecVig = '2025-06-01',
    @Direccion = 'Calle 9 de Julio 200',
    @FecNac = '1985-11-15',
    @NroSocio = NULL;

EXEC dbsl.insertarUsuario 
    @Usuario = 'socio_juan',
    @Estado = 'activo',
    @Contrasenia = 'Socio2025',
    @Rol = 'socio',
    @FecVig = '2025-06-01',
    @Direccion = 'Ruta 3 Km 15',
    @FecNac = '2002-03-12',
    @NroSocio = NULL;

EXEC dbsl.insertarUsuario 
    @Usuario = 'socio_ana',
    @Estado = 'activo',
    @Contrasenia = 'AnaClave789',
    @Rol = 'socio',
    @FecVig = '2025-06-01',
    @Direccion = 'Av. Mitre 456',
    @FecNac = '2006-08-05',
    @NroSocio = NULL;

EXEC dbsl.insertarUsuario 
    @Usuario = 'admin2',
    @Estado = 'inactivo',
    @Contrasenia = 'NoDisponible1',
    @Rol = 'administrador',
    @FecVig = '2024-12-15',
    @Direccion = 'Diagonal Norte 10',
    @FecNac = '1980-02-20',
    @NroSocio = NULL;

EXEC dbsl.insertarUsuario 
    @Usuario = 'profe_jose',
    @Estado = 'activo',
    @Contrasenia = 'Clase123!',
    @Rol = 'profesor',
    @FecVig = '2025-01-01',
    @Direccion = 'Santa Fe 1050',
    @FecNac = '1992-07-30',
    @NroSocio = NULL;

EXEC dbsl.insertarUsuario 
    @Usuario = 'socio_lucia',
    @Estado = 'activo',
    @Contrasenia = 'LuciaSegura',
    @Rol = 'socio',
    @FecVig = '2025-06-01',
    @Direccion = 'Belgrano 300',
    @FecNac = '2010-09-12',
    @NroSocio = NULL;
GO


OPEN SYMMETRIC KEY SN_DatosSensibles
DECRYPTION BY CERTIFICATE Cert_ClubSolNorte;

SELECT Usuario,
       CONVERT(VARCHAR, DecryptByKey(Direccion)) AS DireccionDesencriptado,
	   CONVERT(DATE, CONVERT(NVARCHAR(30), DECRYPTBYKEY(FecNac))) AS FechaNacimiento
FROM dbsl.Usuario;

CLOSE SYMMETRIC KEY SN_DatosSensibles;
GO


SELECT Usuario,Direccion,FecNac
FROM dbsl.Usuario;



