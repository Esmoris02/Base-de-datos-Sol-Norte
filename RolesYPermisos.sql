USE master;
GO

--Creación de logins dentro para cada usuario individual
CREATE LOGIN login_adminClub
WITH PASSWORD = '#SN012025ad',
     CHECK_POLICY = ON;

CREATE LOGIN login_jefeDeTesoreria WITH PASSWORD = '#SN012025a'
	MUST_CHANGE, 
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_administrativoCobranza WITH PASSWORD = '#SN012025b'
	MUST_CHANGE, 
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_administrativoMorosidad WITH PASSWORD = '#SN012025c'
	MUST_CHANGE, 
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_administrativoFacturacion WITH PASSWORD = '#SN012025d'
	MUST_CHANGE, 
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_administrativoSocio WITH PASSWORD = '#SN012025e'
	MUST_CHANGE, 
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_socioWeb WITH PASSWORD = '#SN012025f'
	DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_presidente WITH PASSWORD = '#SN012025g'
	MUST_CHANGE, 
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_vicepresidente WITH PASSWORD = '#SN012025h'
	MUST_CHANGE, 
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_secretario WITH PASSWORD = '#SN012025i'
	MUST_CHANGE, 
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;

CREATE LOGIN login_vocales WITH PASSWORD = '#SN012025j'
	MUST_CHANGE, 
    DEFAULT_DATABASE = ClubSolNorte, 
    CHECK_POLICY = ON;



USE ClubSolNorte
GO

--Creación de roles dentro de ClubSolNorte
CREATE ROLE dbsl_Tesoreria;
CREATE ROLE dbsl_Socio;
CREATE ROLE dbsl_Autoridad;

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

-- Dando permisos a los roles
-- Tesorería puede leer y modificar facturas y cobros
GRANT SELECT, INSERT, UPDATE ON dbsl.Factura TO dbsl_Tesoreria;
GRANT SELECT, INSERT, UPDATE ON dbsl.Cobro TO dbsl_Tesoreria;
GRANT SELECT, UPDATE ON dbsl.MetodoPago TO dbsl_Tesoreria;

--Los socios solo pueden leer sus datos e inscripciones
GRANT SELECT ON dbsl.Socio TO dbsl_Socio;
GRANT SELECT ON dbsl.Inscripcion TO dbsl_Socio;

-- Las autoridades pueden leer toda la base pero no modificar nada
GRANT SELECT ON SCHEMA::dbsl TO dbsl_Autoridad;


