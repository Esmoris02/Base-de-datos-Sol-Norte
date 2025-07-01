
use ClubSolNorte
go
---------INSERTAR CATEGORIA SOCIO-------------

-- Menor: 0 a 12 años
--Se espera que se ingrese correctamente
--EXEC dbsl.InsertarCategoriaSocio 'Menor', 0, 12,100

-- Cadete: 13 a 17 años
--Se espera que se ingrese correctamente
--EXEC dbsl.InsertarCategoriaSocio 'Cadete', 13, 17,550

-- Mayor: mayor a 18 años
--Se espera que se ingrese correctamente
--EXEC dbsl.InsertarCategoriaSocio 'Adulto', 18, 64,10

--Error esperado: 'El nombre de la categoria no es correcto'
--EXEC dbsl.InsertarCategoriaSocio '', 18, 64

--Error esperado: 'La edad ingresada no es correcta'
--EXEC dbsl.InsertarCategoriaSocio 'Adulto', 0, 64,1

--Error esperado:'El Nombre de Categoria ya existe.'
--EXEC dbsl.InsertarCategoriaSocio 'Cadete', 13, 17,10
--select * from dbsl.CategoriaSocio
---------INSEERTAR SOCIO-------------
--Se espera que se inserte correctamente
EXEC dbsl.InsertarSocio
    1001, 'Activo', 'Martina', 'López', '44123456', '2002-05-10',
    '1134567890', '1122334455', 'marti.lopez@gmail.com', 'OSDE', '123456789',
    1, NULL
go
--Error esperado "Ya existe un socio con ese número." (si se utilizó el anterior SP)
--EXEC dbsl.InsertarSocio
--    1001, 'Activo', 'Martina', 'López', '44123456', '2015-05-10',
--    '1134567890', '1122334455', 'marti.lopez@gmail.com', 'OSDE', '123456789',
--    1, 1
----Error esperado "Categoría de socio no válida." (es negativa)
--EXEC dbsl.InsertarSocio
--    1001, 'Activo', 'Martina', 'López', '44123456', '2015-05-10',
--    '1134567890', '1122334455', 'marti.lopez@gmail.com', 'OSDE', '123456789',
--    -1, 1
----Error espeado "La fecha no puede ser nula, mayor a la actual o menor al año 1900"
--EXEC dbsl.InsertarSocio
--    1001, 'Activo', 'Martina', 'López', '44123456', '1800-05-10',
--    '1134567890', '1122334455', 'marti.lopez@gmail.com', 'OSDE', '123456789',
--    1, 1
----Error esperado "'Estado, Nombre, Apellido, DNI, Telefono o Telefono de emergencia incorrectos'" (El DNI es null)
--EXEC dbsl.InsertarSocio
--    1002, 'Activo', 'Bruno', 'Martínez', '', '2010-11-25',
--    '1145678912', '1133224455', 'bruno.martinez@gmail.com', 'Swiss Medical', '987654321',
--    2, 2
----Se espera una insercion correcta
--EXEC dbsl.InsertarSocio
--    1003, 'Activo', 'Lucía', 'Pérez', '40123456', '1990-03-18',
--    '1123456789', '1109876543', 'lucia.perez@gmail.com', 'Galeno', '1122334455',
--    3, NULL;
---- Error esperado "Nro de socio Invalido" (no puede ser nulo)
--EXEC dbsl.InsertarSocio
--    -1, 'Activo', 'Lucía', 'Pérez', '40123456', '1990-03-18',
--    '1123256789', '1109876543', 'lucia.perez@gmail.com', 'Galeno', '1122334455',
--    3, 3;
----Error esperado: Socio inactivo SIN OBRA SOCIAL
--EXEC dbsl.InsertarSocio
--    1005, 'Inactivo', 'Ana', 'Fernández', '38999888', '1985-02-15',
--    '1161234567', '1145678912', 'ana.fer@gmail.com', '', '4455667788',
--    3, 2; 
----Error esperado "El correo electrónico debe ser válido (falta "@" o "." o tipo de correo)"
--EXEC dbsl.InsertarSocio
--    2001,'Activo','Mariano','Ledesma','40112233','1995-04-18',
--	'1144556677','1133221100','','OSDE','123456789',3,NULL;

--select * from dbsl.Socio


--select * from dbsl.CategoriaSocio
---------INSERTAR GRUPO FAMILIAR-------------
--Se espera que se ingrese correctamente
--EXEC dbsl.insertarGrupoFamiliar 'Laura González', 30111222
----Se espera que se ingrese correctamente
--EXEC dbsl.insertarGrupoFamiliar 'Carlos Pérez', 34444555
----Se espera que se ingrese correctamente
--EXEC dbsl.insertarGrupoFamiliar 'Juan Romero', 42005678
----Error esperado:'Informacion ingresada incorrecta'
--EXEC dbsl.insertarGrupoFamiliar '', 45656668
----Error esperado: 'Ya existe un responsable con ese DNI en otro grupo familiar' 
--EXEC dbsl.insertarGrupoFamiliar 'Marcelo González', 30111222


--------------INSERTAR Usuario --------------
----Error esperado "El rol ingresado no es válido. Debe ser: "administrador","profesor" o "socio""
--EXEC dbsl.insertarUsuario 'admin1', 'activo', CONVERT(VARBINARY(256), 'Admin123!'), 'ministro', '2024-12-31', NULL
----Error esperado "La fecha no puede ser nula, mayor a la actual o menor al año 1900."
--EXEC dbsl.insertarUsuario 'profe.futbol', 'activo', CONVERT(VARBINARY(256), 'Futbol2024'), 'profesor', 'NULL', NULL
----Error esperado "El socio asignado no existe"
--EXEC dbsl.insertarUsuario 'lucia.perez', 'activo', CONVERT(VARBINARY(256), 'LuciaPass1'), 'socio', '2024-12-31', -1
----Error esperado: "Estado incorrecto. Establece "activo" o "inactivo""
--EXEC dbsl.insertarUsuario 'juan.romero', 'paz', CONVERT(VARBINARY(256), 'Romero123'), 'socio', '2024-12-31', 1004
----Se espera que se inserte correctamente
--EXEC dbsl.insertarUsuario 'bruno.m', 'activo', CONVERT(VARBINARY(256), 'Cadete321'), 'socio', '2024-12-31', 1002
----Error esperado "nombre de usuario incorrecto o Usuario ya existente"
--EXEC dbsl.insertarUsuario 'bruno.m', 'activo', CONVERT(VARBINARY(256), 'Cadete321'), 'socio', '2024-12-31', 1002


-------------INSERTAR ACTIVIDAD--------------
--Error esperado: "El nombre de la actividad no puede estar vacío o ser muy corto."
--EXEC dbsl.InsertarActividad 'activo', '', 2500
----Error esperado: "El costo de la actividad no es válido."
--EXEC dbsl.InsertarActividad 'activo', 'Natación', -3000
----Error Esperado: "Estado incorrecto. Establece "activo" o "inactivo""
--EXEC dbsl.InsertarActividad 'empty', 'Zumba', 1800
----Se espera que se inserte correctamente
--EXEC dbsl.InsertarActividad 'activo', 'Ajedrez', 2200
----Se espera que se inserte correctamente
--EXEC dbsl.InsertarActividad 'activo', 'Futsal', 2000

--select * from dbsl.Actividad
-------------INSERTAR CLASE---------------------
----Error esperado : "Ingresa un horario valido entre las 08:00 y 22:00 en intervalos de 30 min"
--EXEC dbsl.InsertarClase 'activo', 'Lunes', '03:00', 'Adulto', 1
----Se espera que se inserte correctamente
--EXEC dbsl.InsertarClase 'activo', 'Jueves', '10:30', 'Menor', 1;
--go
----Se espera que se inserte correctamente
--EXEC dbsl.InsertarClase 'activo', 'Miercoles', '11:00', 'Mayor', 1;
--go
----Error esperado:"Ya existe una clase para esa actividad, día y horario."
--EXEC dbsl.InsertarClase 'activo', 'Miercoles', '11:00', 'Menor', 3
----Error esperado "Estado incorrecto. Usa "activo" o "inactivo".
--EXEC dbsl.InsertarClase 'empty', 'Jueves', '15:00', 'Mayor', 1
----Se espera que se inserte correctamente
--EXEC dbsl.InsertarClase 'activo', 'Viernes', '20:00', 'Cadete', 2
----Error esperado "La actividad especificada no existe."
--EXEC dbsl.InsertarClase 'activo', 'Viernes', '20:00', 'Cadete', 99
----Error esperado: "Categoria invalida. Ingresa "Menor", "Cadete" o "Adulto"" (la categoria debe pertenecer a la especificada)
--EXEC dbsl.InsertarClase 'activo', 'Viernes', '20:00', 'Usuario', 2

--select * from dbsl.Clase
---------------INSERTAR COLONIA--------------------
EXEC dbsl.InsertarColonia 
    @Nombre = 'Colonia Enero',
    @Descripcion = 'Actividades recreativas para menores durante enero',
    @Costo = 28000,
    @fechaInicio = '2025-01-02',
    @fechaFin = '2025-01-31';
go
--select * from dbsl.Colonia
----------------INSERTAR SUM------------------------------
--Se espera que se ingrese correctamente
EXEC dbsl.InsertarSum @Descripcion = 'Sum quincho', @Precio = 150
----Error esperado:'El precio debe ser mayor a 0'
--EXEC dbsl.InsertarSum @Descripcion = 'Sum quincho', @Precio = 0
----Error esperado:'Descripcion invalida. Minimo de 5 y maximo de 100'
--EXEC dbsl.InsertarSum @Descripcion = 'abc', @Precio = 100

go
--select * from dbsl.Suum
----------------INSERTAR RESERVA--------------------------
--Se espera que se ingrese correctamente
EXEC dbsl.InsertarReserva @idSum = 1,@FechaReserva = '2025-12-28',@HoraInicio = '10:00',@HoraFin = '12:00';
go
--select* from dbsl.Reserva
--------------INSERTAR PILETVERANO-------------------
-- Valor del Mes
--EXEC dbsl.insertarPiletaVerano 
--    @Fecha = '2025-12-20',
--    @TipoDePase = 'Pase del Mes',
--    @CostoSocioAdulto = 1500,
--    @CostoInvitadoAdulto = 3000,
--    @CostoSocioMenor = 1000,
--    @CostoInvitadoMenor = 2000,
--    @Lluvia = 0;
--select * from dbsl.PiletaVerano
-- Valor de Temporada
--EXEC dbsl.insertarPiletaVerano '2025-12-21','Valor de Temporada',60000,0,50000,0,0
----------------INSERTAR INSCRIPCION-----------------------

-- Actividad
--EXEC dbsl.InsertarInscripcion @NroSocio = 1001, @idClase = 1, @FechaIn = '2025-12-20';
--go
EXEC dbsl.InsertarInscripcion @NroSocio = 1001, @idClase = 2, @FechaIn = '2025-12-20';
go
-- Reserva de SUM
EXEC dbsl.InsertarInscripcion @NroSocio = 1001, @idReserva = 1, @FechaIn = '2025-12-22';
go
-- Colonia
EXEC dbsl.InsertarInscripcion @NroSocio = 1001, @idColonia = 1, @FechaIn = '2025-12-26';
go
-- Pileta
EXEC dbsl.InsertarInscripcion @NroSocio = 1001, @idPileta = 1, @FechaIn = '2025-12-28';
go

--select * from dbsl.Inscripcion

--------------INSERTAR INVITADO------------------------
--Se espera que se ingrese correctamente
EXEC dbsl.insertarInvitado 'Matías', 'Fernández', '2019-06-01';

---- Error esperado: 'Ingrese nuevamente los datos para nombre y apellido'
--EXEC dbsl.insertarInvitado '', 'Rodríguez', '1999-06-01';

---- Error esperado: 'La fecha no puede ser nula'
--EXEC dbsl.insertarInvitado 'Carla', 'López', NULL;

---- Error esperado: 'La fecha no puede ser mayor a la actual'
--EXEC dbsl.insertarInvitado 'Diego', 'Sosa', '2027-12-01';

--select * from dbsl.Invitado
--------------------INSERTAR INSCRIPCION INVITADO --------------
EXEC dbsl.InsertarInscripcionInvitado @idInvitado = 1, @idPileta = 1, @NroSocio = 1001;
go
----------------INSERTAR METODO DE PAGO------------------
--Se espera que se ingrese correctamente
--EXEC dbsl.insertarMetodoPago @Descripcion = 'Tarjeta de Crédito'

----Error esperado:'Metodo de pago ya existe.'
--EXEC dbsl.insertarMetodoPago @Descripcion = 'Tarjeta de Crédito'

--select * from dbsl.MetodoPago

----------------INSERTAR GENERACION FACTURA---------------
--Se espera que se ingrese correctamente
EXEC dbsl.GenerarFactura 1001;
go
----Error esperado: 'El ID de socio debe ser un número positivo.'
--EXEC dbsl.GenerarFactura 0
----Error esperado: 'El ID de socio debe ser un número positivo.'
--EXEC dbsl.GenerarFactura -5;

--SELECT * FROM dbsl.Factura;
--SELECT * FROM dbsl.DetalleFactura;

--DELETE FROM dbsl.DetalleFactura;
--DELETE FROM dbsl.Factura;
------------------GENERAR FACTURA INVITADO---------------
--EXEC dbsl.GenerarFacturaInvitado @idInscripcion = 6;
----------------INSERTAR COBRO----------------------------
----Se espera que se ingrese correctamente
--EXEC dbsl.insertarCobro @idFactura=1,@idMetodoPago=1;
----Se espera que se ingrese correctamente
--EXEC dbsl.insertarCobro @idFactura=2,@idMetodoPago=1;
----Error esperado:'Metodo de pago inexistente.'
--EXEC dbsl.insertarCobro  @idFactura=3,@idMetodoPago=9;

--select * from dbsl.Cobro
--delete from dbsl.Cobro
------Insertar Reembolso ------
-- Reembolso directo al mismo medio de pago del cobro
--EXEC dbsl.InsertarReembolso @idCobro = 1,@NroSocio=1001,@Porcentaje = 60,@Motivo = 'Reintegro por lluvia',@PagoACuenta = 0;
---- Reembolso como saldo a favor
--EXEC dbsl.InsertarReembolso @idCobro = 1,@NroSocio=1001,@Porcentaje = 100,@Motivo = 'Suspensión por fuerza mayor',@PagoACuenta = 1;
--select * from dbsl.Reembolso
--delete from dbsl.Reembolso


