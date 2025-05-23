---------INSERTAR CATEGORIA SOCIO-------------

-- Menor: 0 a 12 años
EXEC dbsl.InsertarCategoriaSocio 'Infantil', 0, 12

-- Cadete: 13 a 17 años
EXEC dbsl.InsertarCategoriaSocio 'Cadete', 13, 17

-- Mayor: mayor a 18 años
EXEC dbsl.InsertarCategoriaSocio 'Adulto', 18, 64



---------INSERTAR GRUPO FAMILIAR-------------
EXEC dbsl.insertarGrupoFamiliar 'Laura González', 30111222

EXEC dbsl.insertarGrupoFamiliar 'Carlos Pérez', 28444555

EXEC dbsl.insertarGrupoFamiliar 'Verónica Díaz', 32500321

EXEC dbsl.insertarGrupoFamiliar 'Juan Romero', 30005678

EXEC dbsl.insertarGrupoFamiliar 'Marcelo González', 30111222

---------INSERTAR SOCIO-------------
-- Socio Menor
EXEC dbsl.InsertarSocio
    1001, 'Activo', 'Martina', 'López', '44123456', '2015-05-10',
    '1134567890', '1122334455', 'marti.lopez@gmail.com', 'OSDE', '123456789',
    1, 1

-- Socio Cadete
EXEC dbsl.InsertarSocio
    1002, 'Activo', 'Bruno', 'Martínez', '43111222', '2010-11-25',
    '1145678912', '1133224455', 'bruno.martinez@gmail.com', 'Swiss Medical', '987654321',
    2, 2

-- Socio Mayor
EXEC dbsl.InsertarSocio
    1003, 'Activo', 'Lucía', 'Pérez', '40123456', '1990-03-18',
    '1123456789', '1109876543', 'lucia.perez@gmail.com', 'Galeno', '1122334455',
    3, 3;


-- Socio inactivo
EXEC dbsl.InsertarSocio
    1005, 'Inactivo', 'Ana', 'Fernández', '38999888', '1985-02-15',
    '1161234567', '1145678912', 'ana.fer@gmail.com', 'OSDE', '4455667788',
    3, 2; 

EXEC dbsl.InsertarSocio
    2001,'Activo','Mariano','Ledesma','40112233','1995-04-18',
	'1144556677','1133221100','mariano.ledesma@gmail.com','OSDE','123456789',3,NULL;

--------------INSERTAR SOCIO --------------
EXEC dbsl.insertarUsuario 'admin1', 'activo', CONVERT(VARBINARY(256), 'Admin123!'), 'administrador', '2024-12-31', NULL

EXEC dbsl.insertarUsuario 'profe.futbol', 'activo', CONVERT(VARBINARY(256), 'Futbol2024'), 'profesor', '2024-12-31', NULL

EXEC dbsl.insertarUsuario 'lucia.perez', 'activo', CONVERT(VARBINARY(256), 'LuciaPass1'), 'socio', '2024-12-31', 1003

EXEC dbsl.insertarUsuario 'juan.romero', 'inactivo', CONVERT(VARBINARY(256), 'Romero123'), 'socio', '2024-12-31', 1004

EXEC dbsl.insertarUsuario 'bruno.m', 'activo', CONVERT(VARBINARY(256), 'Cadete321'), 'socio', '2024-12-31', 1002

-------------INSERTAR ACTIVIDAD--------------
EXEC dbsl.InsertarActividad 'activo', 'Fútbol 11', 2500

EXEC dbsl.InsertarActividad 'activo', 'Natación', 3000

EXEC dbsl.InsertarActividad 'activo', 'Zumba', 1800

EXEC dbsl.InsertarActividad 'activo', 'Gimnasio Funcional', 2200

EXEC dbsl.InsertarActividad 'inactivo', 'Tenis', 2000


-------------INSERTAR CLASE---------------------
EXEC dbsl.InsertarClase 'activo', 'Lunes', '09:00', 'Adulto', 1

EXEC dbsl.InsertarClase 'activo', 'Martes', '10:30', 'Cadete', 2

EXEC dbsl.InsertarClase 'activo', 'Miercoles', '11:00', 'Menor', 3

EXEC dbsl.InsertarClase 'inactivo', 'Jueves', '15:00', 'Adulto', 1

EXEC dbsl.InsertarClase 'activo', 'Viernes', '20:00', 'Cadete', 2

