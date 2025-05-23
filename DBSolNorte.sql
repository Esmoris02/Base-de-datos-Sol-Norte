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
    EdadHasta INT
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
    Estado VARCHAR(15),
    Fecha DATE,
    Turno VARCHAR(20),
    idSum INT,
    FOREIGN KEY (idSum) REFERENCES dbsl.Suum(idSum)
);
 
CREATE TABLE dbsl.Inscripcion (
    idInscripcion INT IDENTITY(1,1) PRIMARY KEY,
    NroSocio INT,
    idClase INT,
    FechaIn DATE,
    idReserva INT,
    FOREIGN KEY (NroSocio) REFERENCES dbsl.Socio(NroSocio),
    FOREIGN KEY (idClase) REFERENCES dbsl.Clase(idClase),
    FOREIGN KEY (idReserva) REFERENCES dbsl.Reserva(idReserva)
);
 
CREATE TABLE dbsl.PiletaVerano(
    idPileta INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE,
    CostoSocio INT DEFAULT 1500,
    CostoInvitado INT DEFAULT 3000,
    Lluvia BIT NOT NULL DEFAULT 0
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
    idInscripcion INT,
    FOREIGN KEY (idInscripcion) REFERENCES dbsl.Inscripcion(idInscripcion)
);
 
CREATE TABLE dbsl.Cobro (
    idCobro INT IDENTITY(1,1) PRIMARY KEY,
    Monto INT,
    Fecha DATE,
    Reembolso BIT NOT NULL DEFAULT 0,
    MontoReembolso INT,
    SaldoFavor INT,
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
 
CREATE TABLE dbsl.Colonia(
    idColonia INT IDENTITY(1,1),
    Nombre VARCHAR(20) DEFAULT 'Colonia',
    Costo INT DEFAULT 1000,
    fechaInicio VARCHAR(5) DEFAULT '21-12',
    fechaFin VARCHAR(5) DEFAULT '20-03',
    idInscripcion INT,
    CONSTRAINT PKColonia PRIMARY KEY(idColonia, idInscripcion),
    FOREIGN KEY (idInscripcion) REFERENCES dbsl.Inscripcion(idInscripcion)
);
 
--drop table dbsl.Colonia,dbsl.DetalleFactura,dbsl.Cobro,dbsl.Factura,dbsl.MetodoPago,dbsl.Invitado,dbsl.PiletaVerano,dbsl.Inscripcion,dbsl.Reserva,dbsl.Suum,dbsl.Clase,dbsl.Actividad,dbsl.Usuario,dbsl.Socio







