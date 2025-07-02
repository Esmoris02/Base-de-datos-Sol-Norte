--CREATE DATABASE ClubSolNorte
--GO
USE ClubSolNorte
GO
--CREATE SCHEMA dbsl
--data base sol norte
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.CategoriaSocio') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.CategoriaSocio (
    idCategoria INT IDENTITY(1,1) PRIMARY KEY,
    NombreCategoria VARCHAR(50),
    EdadDesde INT,
    EdadHasta INT,
	Costo INT,
	VigenteHasta VARCHAR(15)
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.GrupoFamiliar') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.GrupoFamiliar (
    idGrupo INT IDENTITY(1,1) PRIMARY KEY,
    ResponsableNombre VARCHAR(50),
    Dni VARCHAR(20)
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Socio') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Socio (
    NroSocio INT PRIMARY KEY,
    Estado VARCHAR(15),
    Nombre VARCHAR(50),
    Apellido VARCHAR(50),
    Dni VARCHAR(20),
    FechaNac DATE,
    Telefono VARCHAR(20),
    TelefonoEmergencia VARCHAR(20),
    Email VARCHAR(50),
    ObraSocial VARCHAR(50),
    NumeroObraSocial VARCHAR(50),
    idCategoria INT,
    idGrupoFamiliar INT,
	SaldoFavor INT DEFAULT 0,
    FOREIGN KEY (idCategoria) REFERENCES dbsl.CategoriaSocio(idCategoria),
    FOREIGN KEY (idGrupoFamiliar) REFERENCES dbsl.GrupoFamiliar(idGrupo)
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Usuario') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Usuario (
    Usuario VARCHAR(50) PRIMARY KEY,
    Estado VARCHAR(15),
    Contrasenia VARBINARY(256) NOT NULL,
    Rol VARCHAR(50),
    FecVig DATE,
    NroSocio INT,
    FOREIGN KEY (NroSocio) REFERENCES dbsl.Socio(NroSocio)
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Actividad') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Actividad (
    idActividad INT IDENTITY(1,1) PRIMARY KEY,
    Estado VARCHAR(15),
    NombreActividad VARCHAR(50),
    Costo INT
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Clase') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Clase (
    idClase INT IDENTITY(1,1) PRIMARY KEY,
    Estado VARCHAR(15),
    Horario TIME,
    Dia VARCHAR(20),
    Categoria VARCHAR(50),
    idActividad INT,
    FOREIGN KEY (idActividad) REFERENCES dbsl.Actividad(idActividad)
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Suum') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Suum (
    idSum INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion VARCHAR(100),
    Precio INT
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Reserva') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Reserva (
    idReserva INT IDENTITY(1,1) PRIMARY KEY,
    idSum INT,
    FechaReserva DATE,
    HoraInicio TIME,
    HoraFin TIME,
    FOREIGN KEY (idSum) REFERENCES dbsl.Suum(idSum)
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Colonia') 
                 AND type = 'U')
BEGIN
 CREATE TABLE dbsl.Colonia(
    idColonia INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(20),
	Descripcion VARCHAR(255),
    Costo INT ,
    fechaInicio Date,
    fechaFin Date
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Lluvia') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Lluvia(
	Fecha DATE,
	Hora TIME,
	Precipitacion DECIMAL (8,2)
	CONSTRAINT PKLluvia PRIMARY KEY (fecha, hora)
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.PiletaVerano') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.PiletaVerano(
    idPileta INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE,
	TipoDePase VARCHAR(20), -- Dia, mes , temporada
    CostoSocioAdulto INT,
    CostoInvitadoAdulto INT,
	CostoSocioMenor INT,
    CostoInvitadoMenor INT,
    Lluvia BIT NOT NULL DEFAULT 0
)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Invitado') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Invitado (
    idInvitado INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50),
    Apellido VARCHAR(50),
    FechaNacimiento DATE,
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Inscripcion') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Inscripcion (
    idInscripcion INT IDENTITY(1,1) PRIMARY KEY,
    NroSocio INT,
    idClase INT,
    FechaIn DATE,
    idReserva INT,
	idPileta INT,
	idColonia INT,
	idInvitado INT,
	Estado BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (NroSocio) REFERENCES dbsl.Socio(NroSocio),
    FOREIGN KEY (idClase) REFERENCES dbsl.Clase(idClase),
    FOREIGN KEY (idReserva) REFERENCES dbsl.Reserva(idReserva),
	FOREIGN KEY (idPileta) REFERENCES dbsl.PiletaVerano(idPileta),
	FOREIGN KEY (idColonia) REFERENCES dbsl.Colonia(idColonia),
	FOREIGN KEY (idInvitado) REFERENCES dbsl.Invitado(idInvitado)
);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.MetodoPago') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.MetodoPago (
    idMetodoPago INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion VARCHAR(50)
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Factura') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Factura (
    idFactura INT IDENTITY(1,1) PRIMARY KEY,
    FechaEmision DATE,
    FechaVencimiento DATE,
    FechaSegundoVencimiento DATE,
    Estado VARCHAR(20),
    Total INT,
	NroSocio INT
 
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Cobro') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Cobro (
    idCobro INT IDENTITY(1,1) PRIMARY KEY,
    Monto INT,
    FechaCobro DATE,
    idMetodoPago INT,
    idFactura INT,
    FOREIGN KEY (idMetodoPago) REFERENCES dbsl.MetodoPago(idMetodoPago),
    FOREIGN KEY (idFactura) REFERENCES dbsl.Factura(idFactura)
);
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.DetalleFactura') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.DetalleFactura (
    idDetalle INT IDENTITY(1,1) PRIMARY KEY,
    TipoItem VARCHAR(50),
    Descripcion VARCHAR(50),
    Monto INT,
    idFactura INT,
    idInscripcion INT,
    FOREIGN KEY (idFactura) REFERENCES dbsl.Factura(idFactura),
    FOREIGN KEY (idInscripcion) REFERENCES dbsl.Inscripcion(idInscripcion)
);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.Reembolso') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.Reembolso (
    idReembolso INT IDENTITY(1,1) PRIMARY KEY,
    idCobro INT NOT NULL,
    MetodoPago VARCHAR(50),
    Porcentaje DECIMAL(5,2) NOT NULL CHECK (Porcentaje > 0 AND Porcentaje <= 100),
    Monto INT NOT NULL,
    Motivo VARCHAR(255) NOT NULL,
    FechaReembolso DATE NOT NULL DEFAULT GETDATE(),
    PagoACuenta BIT NOT NULL DEFAULT 0,
    FOREIGN KEY (idCobro) REFERENCES dbsl.Cobro(idCobro),
);
END;
GO
IF NOT EXISTS (SELECT * FROM sys.objects 
               WHERE object_id = OBJECT_ID('dbsl.PresentismoClases') 
                 AND type = 'U')
BEGIN
CREATE TABLE dbsl.PresentismoClases(
	idPresentismo INT IDENTITY(1,1) PRIMARY KEY,
	NombreActividad VARCHAR(50),
	NroSocio INT,
	Fecha DATE,
	Asistencia CHAR(1) CHECK (Asistencia IN ('A','J','P')),
	idClase INT,
	FOREIGN KEY (idClase) REFERENCES dbsl.Clase(idClase),
);
END;
GO

--DROP TABLE dbsl.Reembolso;
--go
--DROP TABLE dbsl.DetalleFactura;
--go
--DROP TABLE dbsl.Cobro;
--go
--DROP TABLE dbsl.Factura;
--go
--DROP TABLE dbsl.MetodoPago;
--go
--DROP TABLE dbsl.Inscripcion;
--go
--DROP TABLE dbsl.PresentismoClases;
--go
--DROP TABLE dbsl.Invitado;
--go
--DROP TABLE dbsl.PiletaVerano;
--go
--DROP TABLE dbsl.Lluvia;
--go
--DROP TABLE dbsl.Colonia;
--go
--DROP TABLE dbsl.Reserva;
--go
--DROP TABLE dbsl.Suum;
--go
--DROP TABLE dbsl.Clase;
--go
--DROP TABLE dbsl.Actividad;
--go
--DROP TABLE dbsl.Usuario;
--go
--DROP TABLE dbsl.Socio;
--go
--DROP TABLE dbsl.GrupoFamiliar;
--go
--DROP TABLE dbsl.CategoriaSocio;
--go




