create database ClubSolNorte
go
use ClubSolNorte
go
create schema dbsl
--data base sol norte
go
CREATE TABLE dbsl.CategoriaSocio (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50),
    edad_desde INT,
    edad_hasta INT
);
go
--drop table dbsl.CategoriaSocio
CREATE TABLE dbsl.GrupoFamiliar (
    id_grupo INT IDENTITY(1,1) PRIMARY KEY,
    responsable_nombre VARCHAR(100),
    dni VARCHAR(20)
);
go
--drop table dbsl.GrupoFamiliar
CREATE TABLE dbsl.Socio (
    id_socio INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    dni VARCHAR(20),
    fecha_nac DATE,
    telefono VARCHAR(20),
    telefono_emergencia VARCHAR(20),
    obra_social VARCHAR(100),
    numero_obra_social VARCHAR(50),
    id_categoria INT,
    id_grupo_familiar INT,
    FOREIGN KEY (id_categoria) REFERENCES dbsl.CategoriaSocio(id_categoria),
    FOREIGN KEY (id_grupo_familiar) REFERENCES dbsl.GrupoFamiliar(id_grupo)
);
go
--drop table dbsl.Socio

CREATE TABLE dbsl.Usuario (
    id_usuario INT PRIMARY KEY,
    contrasenia VARCHAR(255) NOT NULL,
    rol VARCHAR(50),
    fec_vig DATE,
    id_socio INT,  -- puede ser NULL
    FOREIGN KEY (id_socio) REFERENCES dbsl.Socio(id_socio)
);
--drop table dbsl.Usuario
go
--drop table dbsl.Usuario
CREATE TABLE dbsl.Actividad (
    id_actividad INT IDENTITY(1,1) PRIMARY KEY,
    nombre_actividad VARCHAR(100),
    costo DECIMAL(10,2)
);
--drop table dbsl.Actividad
go 
CREATE TABLE dbsl.Clase (
    id_clase INT IDENTITY(1,1) PRIMARY KEY,
    id_actividad INT,
    horario TIME,
    categoria VARCHAR(50),
    FOREIGN KEY (id_actividad) REFERENCES dbsl.Actividad(id_actividad)
);
go
--drop table dbsl.Clase
CREATE TABLE dbsl.SUUM (
    id_sum INT IDENTITY(1,1) PRIMARY KEY,
    direccion VARCHAR(255),
    precio DECIMAL(10,2)
);
go
--drop table dbsl.SUUM

CREATE TABLE dbsl.Reserva (
    id_reserva INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE,
    horario TIME,
    id_sum INT
	FOREIGN KEY (id_sum) REFERENCES dbsl.SUUM(id_sum)
);
go
--drop table dbsl.Reserva
CREATE TABLE dbsl.Inscripcion (
    id_inscripcion INT IDENTITY(1,1) PRIMARY KEY,
    id_socio INT,
    id_clase INT,
    fecha DATE,
    id_reserva INT,
    FOREIGN KEY (id_socio) REFERENCES dbsl.Socio(id_socio),
    FOREIGN KEY (id_clase) REFERENCES dbsl.Clase(id_clase),
    FOREIGN KEY (id_reserva) REFERENCES dbsl.Reserva(id_reserva)
);
go
--drop table dbsl.Inscripcion
CREATE TABLE dbsl.Invitado (
    id_invitado INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    fecha_invitado DATE,
    id_inscripcion INT,
    id_actividad INT,
    FOREIGN KEY (id_inscripcion) REFERENCES dbsl.Inscripcion(id_inscripcion),
    FOREIGN KEY (id_actividad) REFERENCES dbsl.Actividad(id_actividad)
);
go
--drop table dbsl.Invitado
CREATE TABLE dbsl.MetodoPago (
    id_metodo_pago INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(100)
);
go
--drop table dbsl.MetodoPago
CREATE TABLE dbsl.Factura (
    id_factura INT IDENTITY(1,1) PRIMARY KEY,
    fecha_emision DATE,
    fecha_vencimiento DATE,
    fecha_segundo_vencimiento DATE,
    estado VARCHAR(20),  -- 'Pendiente', 'Pagada', 'Anulada'
    total DECIMAL(10,2),
    id_inscripcion INT,
    FOREIGN KEY (id_inscripcion) REFERENCES dbsl.Inscripcion(id_inscripcion)
);
go
--drop table dbsl.Factura
CREATE TABLE dbsl.Cobro (
    id_cobro INT IDENTITY(1,1) PRIMARY KEY,
    monto DECIMAL(10,2),
    metodo_pago INT,
    id_factura INT,
    fecha DATE,
    reembolso bit not null,
    monto_reembolso DECIMAL(10,2),
    FOREIGN KEY (metodo_pago) REFERENCES dbsl.MetodoPago(id_metodo_pago),
    FOREIGN KEY (id_factura) REFERENCES dbsl.Factura(id_factura)
);
go
--drop table dbsl.Cobro
CREATE TABLE dbsl.DetalleFactura (
    id_detalle INT IDENTITY(1,1) PRIMARY KEY,
    id_factura INT,
    tipo_item VARCHAR(50),
    descripcion TEXT,
    monto DECIMAL(10,2),
    FOREIGN KEY (id_factura) REFERENCES dbsl.Factura(id_factura)
);
--drop table dbsl.DetalleFactura









