--Categoria socio
CREATE PROCEDURE dbsl.InsertarCategoriaSocio(
	@NombreCategoria VARCHAR(50),
	@EdadDesde INT,
	@EdadHasta INT
)
AS
BEGIN
	IF (LEN(TRIM(@NombreCategoria)) = 0)
	BEGIN 
		RAISERROR ('El nombre de la categoria no es correcto',16,1)
		RETURN
	END
 
	IF (@EdadDesde < 0 OR @EdadHasta IS NULL OR @EdadHasta < 0 OR @EdadDesde > @EdadHasta)
	BEGIN 
		RAISERROR ('La edad ingresada no es correcta',16,1)
		RETURN
	END
 
	  -- Verificar si ya existe una Categoria con ese nombre
    IF EXISTS (SELECT 1 FROM dbsl.CategoriaSocio WHERE NombreCategoria = @NombreCategoria)
    BEGIN
        RAISERROR('El Nombre de Categoria ya existe.', 16, 1)
        RETURN
    END
 
	INSERT INTO dbsl.CategoriaSocio(NombreCategoria,EdadDesde,EdadHasta)
	VALUES (@NombreCategoria,@EdadDesde,@EdadHasta)
 
END
GO
--Grupo Familiar
CREATE PROCEDURE dbs1.insertarGrupoFamiliar(@ResponsableNombre VARCHAR(50), @DNI INT)
AS
BEGIN
	IF(LEN(@ResponsableNombre)=0 OR LEN(@DNI)<=0 OR LEN(@DNI)<6 OR @DNI IS NULL)
	BEGIN 
		RAISERROR ('Informacion ingresada incorrecta',16,1)
		RETURN
	END
 
	 -- Verificar si ya existe ese responsable en otro grupo familiar
    IF EXISTS (SELECT 1 FROM dbsl.GrupoFamiliar WHERE dni = @DNI)
    BEGIN
        RAISERROR('Ya existe un responsable con ese DNI en otro grupo familiar', 16, 1)
        RETURN
    END
 
	INSERT INTO dbsl.GrupoFamiliar(ResponsableNombre, Dni)
	VALUES (@ResponsableNombre, @Dni)
END
 go
-----Socio
CREATE PROCEDURE dbsl.InsertarSocio(
	@NroSocio INT,--
	@Estado VARCHAR(15),--
	@Nombre VARCHAR(50),--
	@Apellido VARCHAR(50),--
	@Dni VARCHAR(20),--
	@FechaNac DATE,--
	@Telefono VARCHAR(20),--
	@TelefonoEmergencia VARCHAR(20),--
	@Email VARCHAR(50),--x
	@ObraSocial VARCHAR(50),--
	@NumeroObraSocial VARCHAR(50),--
	@idCategoria INT,--
	@idGrupoFamiliar INT--
)
AS
BEGIN
	IF(@NroSocio is NULL OR @NroSocio<0)
	BEGIN
		RAISERROR('Nro de socio Invalido', 16, 1)
		RETURN
	END
 
	IF (LEN(TRIM(@Estado)) = 0 OR LEN(TRIM(@Nombre)) = 0 OR LEN(TRIM(@Apellido)) = 0
		OR LEN(TRIM(@Dni)) < 6 OR LEN(TRIM(@Dni)) > 8 OR LEN(TRIM(@Telefono)) != 10 
		OR LEN(TRIM(@TelefonoEmergencia)) != 10 
		)
	BEGIN 
		RAISERROR ('Estado, Nombre, Apellido, DNI, Telefono o Telefono de emergencia incorrectos',16,1)
		RETURN
	END
 
	IF (LEN(TRIM(@ObraSocial)) = 0 OR LEN(TRIM(@NumeroObraSocial)) = 0 
		)
	BEGIN 
		RAISERROR ('Nombre o numero de obra social incorrectos',16,1)
		RETURN
	END
 
	IF (@FechaNac IS NULL OR @FechaNac >= GETDATE() OR @FechaNac < '1900-01-01' OR @FechaNac > GETDATE())
	BEGIN
		RAISERROR('La fecha no puede ser nula, mayor a la actual o menor al año 1900.', 16, 1)
		RETURN
	END
 
	IF (CHARINDEX('@gmail.com', @Email) != 1 OR CHARINDEX('@outlook.com', @Email) > 1 OR 
	CHARINDEX('@hotmail.com', @Email) != 1 OR CHARINDEX('@yahoo.com', @Email) != 1)
		BEGIN
			RAISERROR('El correo electrónico debe ser válido (falta "@" o "." o tipo de correo).', 16, 1)
			RETURN
		END
 
 
	IF EXISTS (SELECT 1 FROM dbsl.Socio WHERE NroSocio = @NroSocio)
	BEGIN
		RAISERROR('Ya existe un socio con ese número.', 16, 1)
		RETURN
	END
 
	IF NOT EXISTS (SELECT 1 FROM dbsl.CategoriaSocio WHERE idCategoria = @idCategoria)
	BEGIN
		RAISERROR('Categoría de socio no válida.', 16, 1)
		RETURN
	END
 
	IF NOT EXISTS (SELECT 1 FROM dbsl.GrupoFamiliar WHERE idGrupo = @idGrupoFamiliar)
	BEGIN
		RAISERROR('Grupo familiar no válido.', 16, 1)
		RETURN
	END
 
	INSERT INTO dbsl.Socio (NroSocio, Estado, Nombre, Apellido, Dni, FechaNac, Telefono, TelefonoEmergencia, Email, ObraSocial, NumeroObraSocial, idCategoria, idGrupoFamiliar)
	VALUES (@NroSocio, @Estado, @Nombre, @Apellido, @Dni, @FechaNac, @Telefono, @TelefonoEmergencia, @Email, @ObraSocial, @NumeroObraSocial, @idCategoria, @idGrupoFamiliar)
END
GO
--Usuario----------------------------
CREATE PROCEDURE dbsl.insertarUsuario
	@Usuario VARCHAR(50),
	@Estado VARCHAR(15),
	@Contrasenia VARBINARY(256),
	@Rol VARCHAR(50),
	@FecVig DATE,
	@NroSocio INT = NULL
AS
BEGIN
 
	DECLARE @contraseniaEncriptada VARBINARY(256) = ENCRYPTBYPASSPHRASE('claveSecreta', @Contrasenia)
	IF (LEN(TRIM(@Usuario)) = 0 OR EXISTS (SELECT 1 FROM dbsl.Usuario WHERE Usuario = @Usuario))
	BEGIN 
		RAISERROR ('nombre de usuario incorrecto o Usuario ya existente.',16,1)
		RETURN
	END
 
	IF @Estado NOT IN ('activo,inactivo')
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
 
	INSERT INTO dbsl.Usuario(Usuario,Estado,Contrasenia,Rol,FecVig,NroSocio)
	VALUES (@Usuario, @Estado, @contraseniaEncriptada, @Rol, @FecVig, @NroSocio)
END
GO
--Actividad
CREATE PROCEDURE dbsl.InsertarActividad
    @Estado VARCHAR(15),
	@NombreActividad VARCHAR(50),
    @Costo INT
AS
BEGIN
    IF LEN(@NombreActividad) <= 0
    BEGIN
        RAISERROR('El nombre de la actividad no puede estar vacío o ser muy corto.', 16, 1);
        RETURN;
    END
 
    IF @Costo IS NULL OR @Costo < 0
    BEGIN
        RAISERROR('El costo de la actividad no es válido.', 16, 1);
        RETURN;
    END
 
	IF @Estado NOT IN ('activo,inactivo')
	BEGIN 
		RAISERROR ('Estado incorrecto. Establece "activo" o "inactivo"',16,1)
		RETURN
	END
 
    INSERT INTO dbsl.Actividad (NombreActividad, Costo, Estado)
    VALUES (@NombreActividad, @Costo, @Estado);
END
GO
--Clase
CREATE PROCEDURE dbsl.InsertarClase
	@Estado VARCHAR(15),
	@Dia VARCHAR (20),
	@Horario TIME,
    @Categoria VARCHAR(50),
    @idActividad INT
AS
BEGIN
	IF (@Horario IS NULL or (@Horario < '08:00' OR @Horario > '22:00') 
		OR DATEPART(MINUTE, @Horario) % 30 != 0)
		BEGIN
			RAISERROR('Ingresa un horario valido entre las 08:00 y 22:00 en intervalos de 30 min', 16, 1);
			RETURN;
		END
 
	IF (@Dia NOT IN ('Lunes','Martes','Miercoles','Jueves','Viernes','Sabado'))
		BEGIN
			RAISERROR('Ingresa un dia valido.', 16, 1);
			RETURN;
		END
 
	IF(@Horario = (SELECT 1 FROM dbsl.Clase WHERE Horario = @Horario) AND 
		@idActividad = (SELECT 1 FROM dbsl.Actividad WHERE idActividad = @idActividad) AND
		@Dia = (SELECT 1 FROM dbsl.Clase WHERE Dia = @Dia)
		)
		BEGIN
			RAISERROR('Ya hay un horario para esa actividad en ese dia.', 16, 1);
			RETURN;
		END
 
	IF(@Categoria NOT IN ('Menor','Cadete','Adulto'))
		BEGIN
			RAISERROR('Categoria invalida. Ingresa "Menor", "Cadete" o "Adulto"', 16, 1);
			RETURN;
		END
 
    IF NOT EXISTS (SELECT 1 FROM dbsl.Actividad WHERE idActividad = @idActividad)
    BEGIN
        RAISERROR('La actividad especificada no existe.', 16, 1);
        RETURN;
    END
 
 
    INSERT INTO dbsl.Clase (Horario, Categoria, idActividad, Estado)
    VALUES (@Horario, @Categoria, @idActividad, @Estado);
END
GO
--PiletaVerano
CREATE PROCEDURE dbsl.insertarPiletaVerano
	@Fecha DATE
AS
BEGIN
	IF @Fecha IS NULL 
		BEGIN
			RAISERROR('La fecha no puede ser nula', 16, 1)
			RETURN
		END

	IF @Fecha < GETDATE() 
		BEGIN
			RAISERROR('La fecha no puede ser menor a la actual', 16, 1)
			RETURN
		END

	IF EXISTS (SELECT 1 FROM dbsl.PiletaVerano WHERE Fecha = @Fecha)
		BEGIN
			RAISERROR('Ya hay datos de pileta cargados para esa fecha.', 16, 1)
			RETURN
		END
 
	INSERT INTO dbsl.PiletaVerano (Fecha)
	VALUES (@Fecha)
		
END
GO
 --Invitado
CREATE PROCEDURE dbsl.insertarInvitado
	@Nombre VARCHAR(50),
	@Apellido VARCHAR(50),
	@FechaInvitado DATE,
	@idInscripcion INT,
	@idPileta INT
AS
BEGIN

	IF ((LEN(TRIM(@Nombre))) = 0 OR LEN(TRIM(@Apellido)) = 0)
		BEGIN
			RAISERROR('Ingrese nuevamente los datos para nombre y apellido', 16, 1)
			RETURN
		END

	IF @FechaInvitado IS NULL 
		BEGIN
			RAISERROR('La fecha no puede ser nula', 16, 1)
			RETURN
		END

	IF @FechaInvitado < GETDATE() 
		BEGIN
			RAISERROR('La fecha no puede ser menor a la actual', 16, 1)
			RETURN
		END

	IF NOT EXISTS (SELECT 1 FROM dbsl.Inscripcion WHERE idInscripcion = @idInscripcion)
		BEGIN
			RAISERROR('La inscripcion no existe.', 16, 1)
			RETURN
		END
	IF NOT EXISTS (SELECT 1 FROM dbsl.PiletaVerano WHERE idPileta = @idPileta)
		BEGIN
			RAISERROR('La fecha de pileta no existe.', 16, 1)
			RETURN
		END
 
	INSERT INTO dbsl.Invitado (Nombre, Apellido, FechaInvitado, idInscripcion, idPileta)
	VALUES (@Nombre, @Apellido, @FechaInvitado, @idInscripcion, @idPileta)
END
GO
 --Metodo de Pago
CREATE PROCEDURE dbsl.insertarMetodoPago
	@Descripcion VARCHAR(50)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM dbsl.MetodoPago WHERE Descripcion = @Descripcion)
		BEGIN
			RAISERROR('Metodo de pago ya existe.', 16, 1)
			RETURN
		END
	INSERT INTO dbsl.MetodoPago VALUES (@Descripcion)
END
GO
 --Factura
CREATE PROCEDURE dbsl.insertarFactura
	@FechaEmision DATE,
	@Estado VARCHAR(20),
	@idInscripcion INT
AS
BEGIN
	
	IF NOT EXISTS (SELECT 1 FROM dbsl.Inscripcion WHERE idInscripcion = @idInscripcion)
		BEGIN
			RAISERROR('La inscripcion asociada no existe.', 16, 1)
			RETURN
		END

	DECLARE @FechaVencimiento DATE = DATEADD(DAY, 5, @FechaEmision)
    DECLARE @FechaSegundoVencimiento DATE = DATEADD(DAY, 5, @FechaVencimiento)

	INSERT INTO dbsl.Factura (FechaEmision, FechaVencimiento, FechaSegundoVencimiento, Estado, Total, idInscripcion)
	VALUES (@FechaEmision, @FechaVencimiento, @FechaSegundoVencimiento, @Estado, @Total, @idInscripcion)
END
GO
 --Cobro
CREATE PROCEDURE dbsl.insertarCobro
	@Monto INT,
	--@Fecha DATE, --LE PONGO LA FECHA DEL DIA EN QUE LO PAGA EN REALIDAD, ENTONCES SE LO DECLARO
	@MontoReembolso INT = 0,
	@SaldoFavor INT = 0,
	@idMetodoPago INT,
	@idFactura INT
AS
BEGIN
DECLARE @Fecha DATE = GETDATE()

	IF NOT EXISTS (SELECT 1 FROM dbsl.MetodoPago WHERE idMetodoPago = @idMetodoPago)
		BEGIN
			RAISERROR('Metodo de pago inexistente.', 16, 1)
			RETURN
		END
	IF NOT EXISTS (SELECT 1 FROM dbsl.Factura WHERE idFactura = @idFactura)
		BEGIN
			RAISERROR('Factura no existente.', 16, 1)
			RETURN
		END


	INSERT INTO dbsl.Cobro (Monto, Fecha, Reembolso, MontoReembolso, SaldoFavor, idMetodoPago, idFactura)
	VALUES (@Monto, @Fecha ,  @MontoReembolso, @SaldoFavor, @idMetodoPago, @idFactura)
END
GO
 --Detalle Factura
CREATE PROCEDURE dbsl.insertarDetalleFactura
	@TipoItem VARCHAR(50),
	@Descripcion VARCHAR(50),
	@Monto INT,
	@idFactura INT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM dbsl.Factura WHERE idFactura = @idFactura)
		BEGIN
			RAISERROR('Factura no existente.', 16, 1)
			RETURN
		END

    -- Validar campos obligatorios
    IF (@TipoItem IS NULL OR TRIM(@TipoItem) = '')
    BEGIN
        RAISERROR('El tipo de ítem no puede ser nulo ni vacío.', 16, 1)
        RETURN
    END

    IF (@Descripcion IS NULL OR TRIM(@Descripcion) = '')
    BEGIN
        RAISERROR('La descripción no puede ser nula ni vacía.', 16, 1)
        RETURN
    END

    IF (@Monto IS NULL OR @Monto <= 0)
    BEGIN
        RAISERROR('El monto debe ser mayor a cero.', 16, 1)
        RETURN
    END

	INSERT INTO dbsl.DetalleFactura (TipoItem, Descripcion, Monto, idFactura)
	VALUES (@TipoItem, @Descripcion, @Monto, @idFactura)
END
GO
--SUM
CREATE PROCEDURE dbsl.InsertarSum(
	@Descripcion VARCHAR(100),
	@Precio INT
)
AS
BEGIN
	IF (@Precio <= 0)
	BEGIN
        RAISERROR('El precio debe ser mayor a 0', 16, 1)
        RETURN
    END

	IF(LEN(@Descripcion)<5 OR LEN(@Descripcion)>=100)
	 BEGIN
        RAISERROR('Descripcion invalida. Minimo de 5 y maximo de 100', 16, 1)
        RETURN
    END
	 
    INSERT INTO dbsl.Suum (Descripcion, Precio)
    VALUES (@Descripcion, @Precio)
END		
GO
--Reserva
CREATE PROCEDURE dbsl.InsertarReserva(
    @Fecha DATE,  
    @Turno TIME
)
AS
BEGIN
DECLARE @Estado VARCHAR(15)
DECLARE @idSum INT=1      
	IF EXISTS (
        SELECT 1 FROM dbsl.Reserva
        WHERE Fecha = @Fecha
          AND Horario = @Turno
    )
		 BEGIN
			RAISERROR('Ese turno ya está reservado', 16, 1)
			RETURN
		END
	ELSE
		BEGIN 
			SET @Estado = 'Reservado'
		END
	
    INSERT INTO dbsl.Reserva (Fecha, Turno, Estado,idSum)
    VALUES (@Fecha, @Turno, @Estado,@idSum)
END
GO
--Inscripcion
CREATE PROCEDURE dbsl.InsertarInscripcion
    @NroSocio INT,
    @idClase INT,
    @FechaIn DATE,
    @idReserva INT = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbsl.Socio WHERE NroSocio = @NroSocio)
    BEGIN
        RAISERROR('El socio no existe.', 16, 1)
        RETURN
    END
 
    IF NOT EXISTS (SELECT 1 FROM dbsl.Clase WHERE idClase = @idClase)
    BEGIN
        RAISERROR('La clase no existe.', 16, 1)
        RETURN
    END
 
    IF @idReserva IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbsl.Reserva WHERE idReserva = @idReserva)
    BEGIN
        RAISERROR('La reserva especificada no existe.', 16, 1)
        RETURN
    END
 
    INSERT INTO dbsl.Inscripcion (NroSocio, idClase, FechaIn, idReserva)
    VALUES (@NroSocio, @idClase, @FechaIn, @idReserva)
END
GO

----Borrados logicos------------------------------------------------------------------------------------------------------------
--dbsl.Socio – Para mantener trazabilidad histórica y no perder información de inscripciones pasadas.
 
--dbsl.Usuario – Para deshabilitar el acceso sin perder su historial.
 
--dbsl.Actividad – Para conservar actividades que ya no se ofrecen.
 
--dbsl.Clase – Si se deja de dictar una clase, puede desactivarse.
 
--dbsl.Reserva – Por razones de trazabilidad de uso del SUM.
 
--dbsl.Inscripcion – Para saber qué inscripciones existieron, aunque ya no estén vigentes.
 
CREATE PROCEDURE dbsl.borrarLogicoSocio
    @NroSocio INT
AS
BEGIN
    -- Verifica existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.Socio WHERE NroSocio = @NroSocio)
    BEGIN
        RAISERROR('No existe el socio con ese número.', 16, 1)
        RETURN
    END
 
    -- Marca como borrado
    UPDATE dbsl.Socio
    SET Estado = 'Borrado'
    WHERE NroSocio = @NroSocio
 
END
GO
 
CREATE PROCEDURE dbsl.borrarLogicoUsuario
    @Usuario VARCHAR(50)
AS
BEGIN
    -- Verifica existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.Usuario WHERE Usuario = @Usuario)
    BEGIN
        RAISERROR('No existe un ese usuario', 16, 1)
        RETURN
    END
 
    -- Marca como borrado
    UPDATE dbsl.Usuario
    SET Estado = 'Borrado'
    WHERE Usuario = @Usuario
 
END
GO
 
CREATE PROCEDURE dbsl.borrarLogicoActividad
    @idActividad INT
AS
BEGIN
    -- Verifica existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.Actividad WHERE idActividad = @idActividad)
    BEGIN
        RAISERROR('No existe actividad con ese id.', 16, 1)
        RETURN
    END
 
    -- Marca como borrado
    UPDATE dbsl.Actividad
    SET Estado = 'Borrado'
    WHERE idActividad = @idActividad
 
END
GO
 
CREATE PROCEDURE dbsl.borrarLogicoClase
    @idClase INT
AS
BEGIN
    -- Verifica existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.Clase WHERE idClase = @idClase)
    BEGIN
        RAISERROR('No existe clase con esa id', 16, 1)
        RETURN
    END
 
    -- Marca como borrado
    UPDATE dbsl.Clase
    SET Estado = 'Borrado'
    WHERE idClase = @idClase
 
END
GO
 
CREATE PROCEDURE dbsl.borrarLogicoReserva
    @idReserva INT
AS
BEGIN
    -- Verifica existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.Clase WHERE idClase = @idClase)
    BEGIN
        RAISERROR('No existe reserva con ese número.', 16, 1)
        RETURN
    END
 
    -- Marca como borrado
    UPDATE dbsl.Reserva
    SET Estado = 'Borrado'
    WHERE idReserva = @idReserva
 
END
GO
 
CREATE PROCEDURE dbsl.borrarLogicoInscripcion
    @idInscripcion INT
AS
BEGIN
    -- Verifica existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.Clase WHERE idInscripcion = @idInscripcion)
    BEGIN
        RAISERROR('No existe inscripcion con id', 16, 1)
        RETURN
    END
 
    -- Marca como borrado
    UPDATE dbsl.Inscripcion
    SET Estado = 'Borrado'
    WHERE idInscripcion = @idInscripcion
 
END
GO