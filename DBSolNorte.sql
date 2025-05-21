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
go
--drop table dbsl.Usuario
CREATE TABLE dbsl.Actividad (
    id_actividad INT PRIMARY KEY,
    nombre_actividad VARCHAR(100),
    costo DECIMAL(10,2)
);
go 
--drop table dbsl.Usuario







