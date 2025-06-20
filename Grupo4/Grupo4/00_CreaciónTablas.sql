create database ClubSolNorte
go
use ClubSolNorte
go
create schema dbsl
--data base sol norte
go
CREATE TABLE dbsl.CategoriaSocio (
    idCategoria INT IDENTITY(1,1) PRIMARY KEY,
    NombreCategoria VARCHAR(50),
    EdadDesde INT,
    EdadHasta INT,
	Costo INT,
	VigenteHasta VARCHAR(15)
);
CREATE TABLE dbsl.GrupoFamiliar (
    idGrupo INT IDENTITY(1,1) PRIMARY KEY,
    ResponsableNombre VARCHAR(50),
    Dni VARCHAR(20)
);

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
	SaldoFavor INT,
    FOREIGN KEY (idCategoria) REFERENCES dbsl.CategoriaSocio(idCategoria),
    FOREIGN KEY (idGrupoFamiliar) REFERENCES dbsl.GrupoFamiliar(idGrupo)
);
 
CREATE TABLE dbsl.Usuario (
    Usuario VARCHAR(50) PRIMARY KEY,
    Estado VARCHAR(15),
    Contrasenia VARBINARY(256) NOT NULL,
    Rol VARCHAR(50),
    FecVig DATE,
    NroSocio INT,
    FOREIGN KEY (NroSocio) REFERENCES dbsl.Socio(NroSocio)
);
 
CREATE TABLE dbsl.Actividad (
    idActividad INT IDENTITY(1,1) PRIMARY KEY,
    Estado VARCHAR(15),
    NombreActividad VARCHAR(50),
    Costo INT
);
 
CREATE TABLE dbsl.Clase (
    idClase INT IDENTITY(1,1) PRIMARY KEY,
    Estado VARCHAR(15),
    Horario TIME,
    Dia VARCHAR(20),
    Categoria VARCHAR(50),
    idActividad INT,
    FOREIGN KEY (idActividad) REFERENCES dbsl.Actividad(idActividad)
);
 
CREATE TABLE dbsl.Suum (
    idSum INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion VARCHAR(100),
    Precio INT
);
 
CREATE TABLE dbsl.Reserva (
    idReserva INT IDENTITY(1,1) PRIMARY KEY,
    idSum INT,
    FechaReserva DATE,
    HoraInicio TIME,
    HoraFin TIME,
    FOREIGN KEY (idSum) REFERENCES dbsl.Suum(idSum)
);

 CREATE TABLE dbsl.Colonia(
    idColonia INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(20),
	Descripcion VARCHAR(255),
    Costo INT ,
    fechaInicio Date,
    fechaFin Date
);

CREATE TABLE dbsl.Lluvia(
	Fecha DATE,
	Hora TIME,
	Precipitacion FLOAT
	CONSTRAINT PKLluvia PRIMARY KEY (fecha, hora)
)

CREATE TABLE dbsl.PiletaVerano(
    idPileta INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE,
	TipoDePase VARCHAR(20), -- Dia, mes , temporada
    CostoSocioAdulto INT,
    CostoInvitadoAdulto INT,
	CostoSocioMenor INT,
    CostoInvitadoMenor INT,
    Lluvia BIT NOT NULL DEFAULT 0
);

CREATE TABLE dbsl.Inscripcion (
    idInscripcion INT IDENTITY(1,1) PRIMARY KEY,
    NroSocio INT,
    idClase INT,
    FechaIn DATE,
    idReserva INT,
	idPileta INT,
	idColonia INT,
    FOREIGN KEY (NroSocio) REFERENCES dbsl.Socio(NroSocio),
    FOREIGN KEY (idClase) REFERENCES dbsl.Clase(idClase),
    FOREIGN KEY (idReserva) REFERENCES dbsl.Reserva(idReserva),
	FOREIGN KEY (idPileta) REFERENCES dbsl.PiletaVerano(idPileta),
	FOREIGN KEY (idColonia) REFERENCES dbsl.Colonia(idColonia)
);
 
CREATE TABLE dbsl.Invitado (
    idInvitado INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(50),
    Apellido VARCHAR(50),
    FechaInvitado DATE,
    idInscripcion INT,
    idPileta INT,
    FOREIGN KEY (idInscripcion) REFERENCES dbsl.Inscripcion(idInscripcion),
    FOREIGN KEY (idPileta) REFERENCES dbsl.PiletaVerano(idPileta)
);
 
CREATE TABLE dbsl.MetodoPago (
    idMetodoPago INT IDENTITY(1,1) PRIMARY KEY,
    Descripcion VARCHAR(50)
);
 
CREATE TABLE dbsl.Factura (
    idFactura INT IDENTITY(1,1) PRIMARY KEY,
    FechaEmision DATE,
    FechaVencimiento DATE,
    FechaSegundoVencimiento DATE,
    Estado VARCHAR(20),
    Total INT,
	NroSocio INT
 
);
 
CREATE TABLE dbsl.Cobro (
    idCobro INT IDENTITY(1,1) PRIMARY KEY,
    Monto INT,
    Fecha DATE,
    Reembolso BIT NOT NULL DEFAULT 0,
    MontoReembolso INT,
    idMetodoPago INT,
    idFactura INT,
    FOREIGN KEY (idMetodoPago) REFERENCES dbsl.MetodoPago(idMetodoPago),
    FOREIGN KEY (idFactura) REFERENCES dbsl.Factura(idFactura)
);
 
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
CREATE TABLE dbsl.PresentismoClases(
	idPresentismo INT IDENTITY(1,1) PRIMARY KEY,
	idActividad INT,
	NombreActividad VARCHAR(50),
	NroSocio INT,
	Fecha DATE,
	Asistencia CHAR(1) CHECK (Asistencia IN ('A','J','P')),
	FOREIGN KEY (idActividad) REFERENCES dbsl.Actividad(idActividad)
);
ALTER TABLE dbsl.PresentismoClases ADD idClase INT FOREIGN KEY (idClase) REFERENCES dbsl.Clase(idClase)
 
drop table dbsl.Colonia
go
drop table dbsl.DetalleFactura
go
drop table dbsl.Cobro
go
drop table dbsl.Factura
go
drop table dbsl.MetodoPago
go
drop table dbsl.Invitado
go
drop table dbsl.Inscripcion
go
drop table dbsl.Reserva
go
drop table dbsl.Suum
go
drop table dbsl.Clase
go
drop table dbsl.Actividad
go
drop table dbsl.Usuario
go
drop table dbsl.Socio
go
drop table dbsl.Categoria
go
drop table dbsl.GrupoFamiliar
go
drop table dbsl.PresentismoClases
go
drop table dbsl.Categoria
drop table dbsl.Factura
drop table dbsl.Reembolso
drop table dbsl.Lluvia





