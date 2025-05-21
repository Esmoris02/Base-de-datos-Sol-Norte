create database ClubSolNorte
go
use ClubSolNorte
go
create schema dbsl
--data base sol norte
go
CREATE TABLE CategoriaSocio (
    id_categoria INT PRIMARY KEY,
    nombre VARCHAR(50),
    edad_desde INT,
    edad_hasta INT
);
go