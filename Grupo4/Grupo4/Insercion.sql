
use ClubSolNorte
go
--Categoria socio
IF OBJECT_ID('dbsl.InsertarCategoriaSocio','P') IS NOT NULL
DROP PROCEDURE dbsl.InsertarCategoriaSocio
GO
CREATE or alter PROCEDURE dbsl.InsertarCategoriaSocio(
	@NombreCategoria VARCHAR(50),
	@EdadDesde INT,
	@EdadHasta INT,
	@Costo INT
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

	IF (@Costo < 0)
	BEGIN 
		RAISERROR ('El costo no puede ser negativo',16,1)
		RETURN
	END
 
	  -- Verificar si ya existe una Categoria con ese nombre
    IF EXISTS (SELECT 1 FROM dbsl.CategoriaSocio WHERE NombreCategoria = @NombreCategoria)
    BEGIN
        RAISERROR('El Nombre de Categoria ya existe.', 16, 1)
        RETURN
    END
 
	INSERT INTO dbsl.CategoriaSocio(NombreCategoria,EdadDesde,EdadHasta,Costo)
	VALUES (@NombreCategoria,@EdadDesde,@EdadHasta,@Costo)
 
END
GO
--Grupo Familiar-------------------------------------------------

IF OBJECT_ID('dbs1.insertarGrupoFamiliar','P') IS NOT NULL
DROP PROCEDURE dbsl.insertarGrupoFamiliar
GO
CREATE PROCEDURE dbsl.insertarGrupoFamiliar(
@ResponsableNombre VARCHAR(50), 
@DNI VARCHAR(20)
)
AS
BEGIN
	IF(LEN(TRIM(@ResponsableNombre))=0 OR LEN(@DNI)<=0 OR LEN(@DNI)<6 OR LEN(@DNI)<6 OR @DNI IS NULL)
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

--Socio-------------------------------------------------

IF OBJECT_ID('dbsl.InsertarSocio','P') IS NOT NULL
DROP PROCEDURE dbsl.InsertarSocio
GO
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
	@idGrupoFamiliar INT--puede ser NULL
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
 
	IF (@Email NOT LIKE '%@%.%' OR LEN(@Email) < 5)
	BEGIN
		RAISERROR('El correo electrónico ingresado no es válido.', 16, 1)
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

    DECLARE @Edad INT = DATEDIFF(YEAR, @FechaNac, GETDATE()) 
        - CASE 
			WHEN DATEADD(YEAR, DATEDIFF(YEAR, @FechaNac, GETDATE()), @FechaNac) > GETDATE() THEN 1 ELSE 0 
		  END

    IF (@Edad < 18)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbsl.GrupoFamiliar WHERE idGrupo = @idGrupoFamiliar)
        BEGIN
            RAISERROR('El socio es menor de edad y debe tener un grupo familiar válido.', 16, 1)
            RETURN
        END
    END
    ELSE
    BEGIN
        -- Socios mayores de edad NO deben estar asociados a un grupo familiar
        IF (@idGrupoFamiliar IS NOT NULL)
        BEGIN
            RAISERROR('Los socios mayores de edad no deben tener grupo familiar.', 16, 1)
            RETURN
        END
    END

    -- Inserción final
    INSERT INTO dbsl.Socio (NroSocio, Estado, Nombre, Apellido, Dni, FechaNac,Telefono, TelefonoEmergencia, Email,ObraSocial, NumeroObraSocial, idCategoria, idGrupoFamiliar, SaldoFavor)
    VALUES (@NroSocio, @Estado, @Nombre, @Apellido, @Dni, @FechaNac,@Telefono, @TelefonoEmergencia, @Email,@ObraSocial, @NumeroObraSocial, @idCategoria, @idGrupoFamiliar,0)
END
GO

--Usuario-------------------------------------------------

IF OBJECT_ID('dbsl.insertarUsuario','P') IS NOT NULL
DROP PROCEDURE dbsl.insertarUsuario
GO
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
 
	IF @Estado NOT IN ('activo','inactivo')
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

--Actividad-------------------------------------------------

IF OBJECT_ID('dbsl.InsertarActividad','P') IS NOT NULL
DROP PROCEDURE dbsl.InsertarActividad
GO
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
 
	IF @Estado NOT IN ('activo','inactivo')
	BEGIN 
		RAISERROR ('Estado incorrecto. Establece "activo" o "inactivo"',16,1)
		RETURN
	END
 
    INSERT INTO dbsl.Actividad (NombreActividad, Costo, Estado)
    VALUES (@NombreActividad, @Costo, @Estado);
END
GO

--Clase-------------------------------------------------
IF OBJECT_ID('dbsl.InsertarClase','P') IS NOT NULL
DROP PROCEDURE dbsl.InsertarClase
GO
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
			RAISERROR('Ingresa un horario valido entre las 08:00 y 22:00 en intervalos de 30 min', 16, 1)
			RETURN
		END
 
	IF (@Dia NOT IN ('Lunes','Martes','Miercoles','Jueves','Viernes','Sabado'))
		BEGIN
			RAISERROR('Ingresa un dia valido.', 16, 1)
			RETURN
		END

	   
    IF (@Estado NOT IN ('activo', 'inactivo'))
    BEGIN
        RAISERROR('Estado incorrecto. Usa "activo" o "inactivo".', 16, 1)
        RETURN
    END
 
 
	IF(@Categoria NOT IN ('Menor','Cadete','Adulto'))
		BEGIN
			RAISERROR('Categoria invalida. Ingresa "Menor", "Cadete" o "Adulto"', 16, 1)
			RETURN;
		END
 
    IF NOT EXISTS (SELECT 1 FROM dbsl.Actividad WHERE idActividad = @idActividad)
    BEGIN
        RAISERROR('La actividad especificada no existe.', 16, 1)
        RETURN
    END

    IF EXISTS (
        SELECT 1 FROM dbsl.Clase
        WHERE idActividad = @idActividad AND Dia = @Dia AND Horario = @Horario
    )
    BEGIN
        RAISERROR('Ya existe una clase para esa actividad, día y horario.', 16, 1)
        RETURN
    END
 
 
    INSERT INTO dbsl.Clase (Dia,Horario, Categoria, idActividad, Estado)
    VALUES (@Dia,@Horario, @Categoria, @idActividad, @Estado)
END
GO

--PiletaVerano-------------------------------------------------

IF OBJECT_ID('dbsl.insertarPiletaVerano', 'P') IS NOT NULL
DROP PROCEDURE dbsl.insertarPiletaVerano;
GO

CREATE PROCEDURE dbsl.insertarPiletaVerano
    @Fecha DATE,
    @TipoDePase VARCHAR(20),
    @CostoSocioAdulto INT,
    @CostoInvitadoAdulto INT,
    @CostoSocioMenor INT,
    @CostoInvitadoMenor INT,
    @Lluvia BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
	 -- Validación de tipo de pase
    IF @TipoDePase NOT IN ('Pase del Día', 'Pase del Mes', 'Pase de Temporada')
    BEGIN
        RAISERROR('El tipo de pase debe ser: Pase del Día, Pase del Mes o Pase de Temporada.', 16, 1)
        RETURN
    END
    -- Validacion de la fecha
    IF @Fecha IS NULL OR @Fecha < CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR('La fecha debe ser válida y no menor a hoy.', 16, 1)
        RETURN
    END

    INSERT INTO dbsl.PiletaVerano (
        Fecha, TipoDePase, 
        CostoSocioAdulto, CostoInvitadoAdulto,
        CostoSocioMenor, CostoInvitadoMenor,
        Lluvia
    )
    VALUES (
        @Fecha, @TipoDePase, 
        @CostoSocioAdulto, @CostoInvitadoAdulto,
        @CostoSocioMenor, @CostoInvitadoMenor,
        @Lluvia
    );
END
GO

 --Invitado-------------------------------------------------

 IF OBJECT_ID('dbsl.insertarInvitado','P') IS NOT NULL
DROP PROCEDURE dbsl.insertarInvitado
GO
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

 --Metodo de Pago-------------------------------------------------

IF OBJECT_ID('dbsl.insertarMetodoPago','P') IS NOT NULL
DROP PROCEDURE dbsl.insertarMetodoPago
GO
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

 --Factura-------------------------------------------------
 --Nos encontramos en la duda de si debiamos crear un procedure para el llenado de esta tabla debido a que sus
 --datos son calculados en base a datos de otras tablas.
IF OBJECT_ID('dbsl.insertarFactura','P') IS NOT NULL
DROP PROCEDURE dbsl.insertarFactura
GO
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
------- Reembolso---------
IF OBJECT_ID('dbsl.InsertarReembolso', 'P') IS NOT NULL
DROP PROCEDURE dbsl.InsertarReembolso;
GO

CREATE PROCEDURE dbsl.InsertarReembolso
    @idCobro INT,
    @NroSocio INT,
    @Porcentaje DECIMAL(5,2),
    @Motivo VARCHAR(255),
    @PagoACuenta BIT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF @Porcentaje <= 0 OR @Porcentaje > 100
    BEGIN
        RAISERROR('El porcentaje debe estar entre 0 y 100.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbsl.Cobro WHERE idCobro = @idCobro)
    BEGIN
        RAISERROR('El cobro indicado no existe.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbsl.Socio WHERE NroSocio = @NroSocio)
    BEGIN
        RAISERROR('El socio indicado no existe.', 16, 1);
        RETURN;
    END

    DECLARE @MontoCobrado INT,
            @MontoReembolso INT,
            @MetodoPago VARCHAR(50);

    -- Obtener monto y método de pago desde el cobro
    SELECT 
        @MontoCobrado = C.Monto,
        @MetodoPago = MP.Descripcion
    FROM dbsl.Cobro C
    JOIN dbsl.MetodoPago MP ON C.idMetodoPago = MP.idMetodoPago
    WHERE C.idCobro = @idCobro;

    IF @MontoCobrado IS NULL
    BEGIN
        RAISERROR('No se pudo obtener el monto del cobro.', 16, 1);
        RETURN;
    END

    SET @MontoReembolso = CAST(@MontoCobrado * (@Porcentaje / 100.0) AS INT);

    -- Si es pago a cuenta, registrar texto personalizado
    IF @PagoACuenta = 1
        SET @MetodoPago = 'Pago a cuenta';
	
	DECLARE @TotalReembolsado INT = (
    SELECT ISNULL(SUM(Monto), 0)
    FROM dbsl.Reembolso
    WHERE idCobro = @idCobro
	);

	IF (@TotalReembolsado + @MontoReembolso) > @MontoCobrado
	BEGIN
		RAISERROR('La suma de los reembolsos supera el monto del cobro original.', 16, 1);
		RETURN;
	END
    -- Insertar reembolso
    INSERT INTO dbsl.Reembolso (
        idCobro, MetodoPago, Porcentaje, Monto, Motivo, PagoACuenta
    )
    VALUES (
        @idCobro, @MetodoPago, @Porcentaje, @MontoReembolso, @Motivo, @PagoACuenta
    );

    -- Si es pago a cuenta, actualizar saldo del socio
    IF @PagoACuenta = 1
    BEGIN
        UPDATE dbsl.Socio
        SET SaldoFavor = ISNULL(SaldoFavor, 0) + @MontoReembolso
        WHERE NroSocio = @NroSocio;
    END
END;
GO
--Cobro-------------------------------------------------

IF OBJECT_ID('dbsl.insertarCobro','P') IS NOT NULL
DROP PROCEDURE dbsl.insertarCobro
GO

CREATE PROCEDURE dbsl.insertarCobro
    @idFactura INT,
    @idMetodoPago INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia de factura
    IF NOT EXISTS (SELECT 1 FROM dbsl.Factura WHERE idFactura = @idFactura)
    BEGIN
        RAISERROR('La factura no existe.', 16, 1);
        RETURN;
    END

    -- Validar existencia del método de pago
    IF NOT EXISTS (SELECT 1 FROM dbsl.MetodoPago WHERE idMetodoPago = @idMetodoPago)
    BEGIN
        RAISERROR('El método de pago especificado no existe.', 16, 1);
        RETURN;
    END

    DECLARE @estado VARCHAR(20), 
            @fechaSegundoVencimiento DATE, 
            @fechaActual DATE = GETDATE(), 
            @total INT;

    SELECT 
        @estado = Estado,
        @fechaSegundoVencimiento = FechaSegundoVencimiento
    FROM dbsl.Factura
    WHERE idFactura = @idFactura;

    IF @estado = 'Pagada'
    BEGIN
        RAISERROR('La factura ya fue pagada.', 16, 1);
        RETURN;
    END

    -- Aplicar recargo si se pasó del segundo vencimiento
    IF @fechaActual > @fechaSegundoVencimiento
    BEGIN
        DECLARE @recargo INT;
        SELECT @recargo = CAST(SUM(monto) * 0.10 AS INT)
        FROM dbsl.DetalleFactura
        WHERE idFactura = @idFactura;

        INSERT INTO dbsl.DetalleFactura (tipoItem, descripcion, monto, idFactura)
        VALUES ('Recargo', '10% por pago fuera de término', @recargo, @idFactura);

        -- Actualizar total
        UPDATE dbsl.Factura
        SET Total = (
            SELECT SUM(monto)
            FROM dbsl.DetalleFactura
            WHERE idFactura = @idFactura
        )
        WHERE idFactura = @idFactura;
    END

    -- Obtener el total actualizado
    SELECT @total = Total FROM dbsl.Factura WHERE idFactura = @idFactura;

    -- Registrar el cobro
    INSERT INTO dbsl.Cobro (FechaCobro, idMetodoPago, Monto, idFactura)
    VALUES (@fechaActual, @idMetodoPago, @total, @idFactura);

    -- Marcar factura como pagada
    UPDATE dbsl.Factura
    SET Estado = 'Pagada'
    WHERE idFactura = @idFactura;
END;
GO

 --Detalle Factura-------------------------------------------------

IF OBJECT_ID('dbsl.insertarDetalleFactura','P') IS NOT NULL
DROP PROCEDURE dbsl.insertarDetalleFactura
GO
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

--SUM-------------------------------------------------

IF OBJECT_ID('dbsl.InsertarSum','P') IS NOT NULL
DROP PROCEDURE dbsl.InsertarSum
GO
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

--Reserva-------------------------------------------------

IF OBJECT_ID('dbsl.InsertarReserva', 'P') IS NOT NULL
DROP PROCEDURE dbsl.InsertarReserva;
GO

CREATE PROCEDURE dbsl.InsertarReserva
    @idSum INT,
    @FechaReserva DATE,
    @HoraInicio TIME,
    @HoraFin TIME
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar existencia del SUM
    IF NOT EXISTS (SELECT 1 FROM dbsl.Suum WHERE idSum = @idSum)
    BEGIN
        RAISERROR('El SUM indicado no existe.', 16, 1)
        RETURN;
    END

    -- Validar fechas y horas
    IF @FechaReserva IS NULL OR @FechaReserva < CAST(GETDATE() AS DATE)
    BEGIN
        RAISERROR('La fecha de reserva debe ser igual o posterior a hoy.', 16, 1)
        RETURN;
    END

    IF @HoraInicio IS NULL OR @HoraFin IS NULL OR @HoraInicio >= @HoraFin
    BEGIN
        RAISERROR('La hora de inicio debe ser anterior a la hora de fin.', 16, 1)
        RETURN;
    END

    -- Validar que no haya superposición con otras reservas del mismo SUM
    IF EXISTS (
        SELECT 1
        FROM dbsl.Reserva
        WHERE idSum = @idSum
          AND FechaReserva = @FechaReserva
          AND (
                (@HoraInicio < HoraFin AND @HoraFin > HoraInicio)
             )
    )
    BEGIN
        RAISERROR('El SUM ya está reservado en ese rango horario.', 16, 1)
        RETURN;
    END

    -- Insertar reserva
    INSERT INTO dbsl.Reserva (idSum, FechaReserva, HoraInicio, HoraFin)
    VALUES (@idSum, @FechaReserva, @HoraInicio, @HoraFin);
END
GO

----Colonia------
IF OBJECT_ID('dbsl.InsertarColonia', 'P') IS NOT NULL
DROP PROCEDURE dbsl.InsertarColonia;
GO

CREATE PROCEDURE dbsl.InsertarColonia
    @Nombre VARCHAR(20),
    @Descripcion VARCHAR(255),
    @Costo INT,
    @fechaInicio DATE,
    @fechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validaciones básicas
    IF LEN(@Nombre) < 3
    BEGIN
        RAISERROR('El nombre de la colonia debe tener al menos 3 caracteres.', 16, 1);
        RETURN;
    END

    IF @Costo <= 0
    BEGIN
        RAISERROR('El costo debe ser un valor positivo.', 16, 1);
        RETURN;
    END

    IF @fechaInicio IS NULL OR @fechaFin IS NULL
    BEGIN
        RAISERROR('Las fechas de inicio y fin no pueden ser nulas.', 16, 1);
        RETURN;
    END

    IF @fechaInicio > @fechaFin
    BEGIN
        RAISERROR('La fecha de inicio no puede ser posterior a la fecha de fin.', 16, 1);
        RETURN;
    END

    -- Inserción
    INSERT INTO dbsl.Colonia (Nombre, Descripcion, Costo, fechaInicio, fechaFin)
    VALUES (@Nombre, @Descripcion, @Costo, @fechaInicio, @fechaFin);
END
GO
--Inscripcion-------------------------------------------------

IF OBJECT_ID('dbsl.InsertarInscripcion','P') IS NOT NULL
DROP PROCEDURE dbsl.InsertarInscripcion
GO
CREATE PROCEDURE dbsl.InsertarInscripcion
    @NroSocio INT,
    @idClase INT = NULL,
    @idReserva INT = NULL,
    @idPileta INT = NULL,
	@idColonia INT = NULL,
    @FechaIn DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el socio exista
    IF NOT EXISTS (SELECT 1 FROM dbsl.Socio WHERE NroSocio = @NroSocio)
    BEGIN
        RAISERROR('El socio no existe.', 16, 1);
        RETURN;
    END

    -- Validar que solo se asigne un tipo de Item a la inscripcion
    DECLARE @CantidadTipos INT = 
        ISNULL(IIF(@idClase IS NOT NULL, 1, 0), 0) +
        ISNULL(IIF(@idReserva IS NOT NULL, 1, 0), 0) +
        ISNULL(IIF(@idPileta IS NOT NULL, 1, 0), 0) +
		ISNULL(IIF(@idColonia IS NOT NULL, 1, 0), 0);

    IF @CantidadTipos <> 1
    BEGIN
        RAISERROR('Debe especificar exactamente uno entre: Clase, Reserva ,Pileta o Colonia.', 16, 1);
        RETURN;
    END

    -- Validar que esxiste la clase a la que me quiero anotar
    IF @idClase IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbsl.Clase WHERE idClase = @idClase)
    BEGIN
        RAISERROR('La clase indicada no existe.', 16, 1);
        RETURN;
    END
	-- Valida, si me quiero anotar a la reserva, que exista
    IF @idReserva IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbsl.Reserva WHERE idReserva = @idReserva)
    BEGIN
        RAISERROR('La reserva indicada no existe.', 16, 1);
        RETURN;
    END
	-- Valida, si me quiero anotar a la pileta, que exista
    IF @idPileta IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbsl.PiletaVerano WHERE idPileta = @idPileta)
    BEGIN
        RAISERROR('La pileta indicada no existe.', 16, 1);
        RETURN;
    END
	 IF @idColonia IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbsl.Colonia WHERE idColonia = @idColonia)
    BEGIN
        RAISERROR('La colonia no existe.', 16, 1);
        RETURN;
    END

    -- Insertar inscripción
    INSERT INTO dbsl.Inscripcion (NroSocio, idClase, idReserva, idPileta,idColonia, FechaIn)
    VALUES (@NroSocio, @idClase, @idReserva, @idPileta,@idColonia, @FechaIn);
END
GO

--Generacion de Factura--------------------
--Nota: Al generar una factura, se inclulle en el detalle factura que estan en inscripción. A excepción de las clases de las
--actividades, solo se incluirá los items en la primera factura generada, ej: si yo genero una reserva para el sum, se registrará 
--en la primera factura generada de ese socio después de la inscripción. Si se genera otra, esta no aparecerá. Si quiero otra reserva, 
--deveré realizar otra inscripción. Las actividades se consideran como una "subscripción mensual", y se incluiran enncada factura generada
-- mientras exista esa inscripción
IF OBJECT_ID('dbsl.GenerarFactura','P') IS NOT NULL
DROP PROCEDURE dbsl.GenerarFactura
GO

CREATE PROCEDURE dbsl.GenerarFactura
    @idSocio INT
AS
BEGIN
    SET NOCOUNT ON;

    IF (@idSocio IS NULL OR @idSocio <= 0)
    BEGIN
        RAISERROR('El ID de socio debe ser un número positivo.', 16, 1)
        RETURN
    END

    IF NOT EXISTS (SELECT 1 FROM dbsl.Socio WHERE NroSocio = @idSocio)
    BEGIN
        RAISERROR('No se encontró un socio con ese ID.', 16, 1)
        RETURN
    END

    DECLARE @FechaActual DATE = GETDATE()
    DECLARE @FechaVencimiento DATE = DATEADD(DAY, 5, @FechaActual)
    DECLARE @FechaSegundoVencimiento DATE = DATEADD(DAY, 10, @FechaActual)
    DECLARE @idFactura INT
    DECLARE @Total INT = 0

    -- 1. Crear la factura base
    INSERT INTO dbsl.Factura (
        FechaEmision, FechaVencimiento, FechaSegundoVencimiento, Estado, Total, NroSocio
    )
    VALUES (
        @FechaActual, @FechaVencimiento, @FechaSegundoVencimiento, 'Pendiente', 0, @idSocio
    )

    SET @idFactura = SCOPE_IDENTITY();

    -- 2. Actividades
    INSERT INTO dbsl.DetalleFactura (tipoItem, descripcion, monto, idFactura,idInscripcion)
    SELECT 
        'Actividad',
        'Inscripción a actividad: ' + A.NombreActividad,
        A.Costo,
        @idFactura,
		IA.idInscripcion
    FROM dbsl.Inscripcion IA
    INNER JOIN dbsl.Clase C ON IA.idClase = C.idClase
    INNER JOIN dbsl.Actividad A ON C.idActividad = A.idActividad
    WHERE IA.NroSocio = @idSocio;

    -- 3. Colonia
    INSERT INTO dbsl.DetalleFactura (tipoItem, descripcion, monto, idFactura,idInscripcion)
	SELECT 
		'Colonia',
		C.Descripcion,
		C.Costo,
		@idFactura,
		I.idInscripcion
	FROM dbsl.Inscripcion I
	JOIN dbsl.Colonia C ON I.idColonia = C.idColonia
	WHERE I.NroSocio = @idSocio AND I.idColonia IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM dbsl.DetalleFactura DF
      WHERE DF.idInscripcion = I.idInscripcion
  );

    -- 4. SUM
    INSERT INTO dbsl.DetalleFactura (tipoItem, descripcion, monto, idFactura,idInscripcion)
    SELECT 
        'SUM',
        'Reserva de SUM',
        S.Precio,
        @idFactura,
		I.idInscripcion
    FROM dbsl.Inscripcion I
    INNER JOIN dbsl.Reserva R ON I.idReserva = R.idReserva
    INNER JOIN dbsl.Suum S ON R.idSum = S.idSum
    WHERE I.NroSocio = @idSocio AND NOT EXISTS (
      SELECT 1 FROM dbsl.DetalleFactura DF
      WHERE DF.idInscripcion = I.idInscripcion
  );
	-- 5. Membresía
	INSERT INTO dbsl.DetalleFactura (tipoItem, descripcion, monto, idFactura)
	SELECT 
		'Membresía',
		'Cuota mensual por categoría: ' + cs.NombreCategoria,
		cs.Costo,
		@idFactura
	FROM dbsl.Socio s
	JOIN dbsl.CategoriaSocio cs ON s.idCategoria = cs.idCategoria
	WHERE s.NroSocio = @idSocio;
	-- 6. Pileta de Verano
	INSERT INTO dbsl.DetalleFactura (tipoItem, descripcion, monto, idFactura,idInscripcion)
	SELECT 
		'Pileta',
		'Pase a pileta: ' + pv.TipoDePase + ' (' + FORMAT(pv.Fecha, 'dd/MM/yyyy') + ')',
		CASE 
			WHEN cs.NombreCategoria = 'Menor' THEN pv.CostoSocioMenor
			ELSE pv.CostoSocioAdulto
		END,
		@idFactura,
		I.idInscripcion
	FROM dbsl.Inscripcion I
	JOIN dbsl.PiletaVerano pv ON I.idPileta = pv.idPileta
	JOIN dbsl.Socio s ON I.NroSocio = s.NroSocio
	JOIN dbsl.CategoriaSocio cs ON s.idCategoria = cs.idCategoria
	WHERE I.NroSocio = @idSocio AND I.idPileta IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM dbsl.DetalleFactura DF
      WHERE DF.idInscripcion = I.idInscripcion
  );

	-- DESCUENTO Multiples Actividades
	DECLARE @CantidadActividades INT;
	SELECT @CantidadActividades = COUNT(*)
	FROM dbsl.Inscripcion I
	INNER JOIN dbsl.Clase C ON I.idClase = C.idClase
	WHERE I.NroSocio = @idSocio;

	IF @CantidadActividades > 1
	BEGIN
		DECLARE @DescuentoActividades INT;
		SELECT @DescuentoActividades = CAST(SUM(Monto) * 0.10 AS INT)
		FROM dbsl.DetalleFactura
		WHERE idFactura = @idFactura AND tipoItem = 'Actividad';

		INSERT INTO dbsl.DetalleFactura (tipoItem, descripcion, monto, idFactura)
		VALUES ('Descuento', '10% por múltiples actividades', -@DescuentoActividades, @idFactura);
	END

	-- DESCUENTO grupo familiar
	DECLARE @idGrupoFamiliar INT;
	SELECT @idGrupoFamiliar = idGrupoFamiliar FROM dbsl.Socio WHERE NroSocio = @idSocio;

	IF @idGrupoFamiliar IS NOT NULL
	BEGIN
		DECLARE @CantidadEnGrupo INT;
		SELECT @CantidadEnGrupo = COUNT(*) 
		FROM dbsl.Socio 
		WHERE idGrupoFamiliar = @idGrupoFamiliar;

		IF @CantidadEnGrupo > 1
		BEGIN
			DECLARE @DescuentoFamiliar INT;
			SELECT @DescuentoFamiliar = CAST(SUM(Monto) * 0.15 AS INT)
			FROM dbsl.DetalleFactura
			WHERE idFactura = @idFactura AND tipoItem <> 'Actividad';

			INSERT INTO dbsl.DetalleFactura (tipoItem, descripcion, monto, idFactura)
			VALUES ('Descuento', '15% por grupo familiar', -@DescuentoFamiliar, @idFactura);
		END
	END
    -- 6. Total
    UPDATE dbsl.Factura
    SET Total = (
        SELECT SUM(Monto)
        FROM dbsl.DetalleFactura
        WHERE idFactura = @idFactura
    )
    WHERE idFactura = @idFactura;
END;
GO
-------Insertar metodo de pago
IF OBJECT_ID('dbsl.InsertarMetodoPago', 'P') IS NOT NULL
DROP PROCEDURE dbsl.InsertarMetodoPago;
GO

CREATE PROCEDURE dbsl.InsertarMetodoPago
    @Descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar entrada
    IF @Descripcion IS NULL OR LTRIM(RTRIM(@Descripcion)) = ''
    BEGIN
        RAISERROR('La descripción del método de pago no puede estar vacía.', 16, 1);
        RETURN;
    END

    -- Verificar si ya existe
    IF EXISTS (
        SELECT 1
        FROM dbsl.MetodoPago
        WHERE UPPER(Descripcion) = UPPER(@Descripcion)
    )
    BEGIN
        RAISERROR('Ese método de pago ya está registrado.', 16, 1);
        RETURN;
    END

    -- Insertar
    INSERT INTO dbsl.MetodoPago (Descripcion)
    VALUES (@Descripcion);
END;
GO

----Borrados logicos------------------------------------------------------------------------------------------------------------
--dbsl.Socio – Para mantener trazabilidad histórica y no perder información de inscripciones pasadas.
 
--dbsl.Usuario – Para deshabilitar el acceso sin perder su historial.
 
--dbsl.Actividad – Para conservar actividades que ya no se ofrecen.
 
--dbsl.Clase – Si se deja de dictar una clase, puede desactivarse.
 
--dbsl.Reserva – Por razones de trazabilidad de uso del SUM.
 
--dbsl.Inscripcion – Para saber qué inscripciones existieron, aunque ya no estén vigentes.

--BORRAR SOCIO------------------------------

IF OBJECT_ID('dbsl.borrarLogicoSocio','P') IS NOT NULL
DROP PROCEDURE dbsl.borrarLogicoSocio
GO 
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

--BORRAR Usuario------------------------------
IF OBJECT_ID('dbsl.borrarLogicoUsuario','P') IS NOT NULL
DROP PROCEDURE dbsl.borrarLogicoUsuario
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

--BORRAR Actividad------------------------------

IF OBJECT_ID('dbsl.borrarLogicoActividad','P') IS NOT NULL
DROP PROCEDURE dbsl.borrarLogicoActividad
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

--BORRAR Clase------------------------------

IF OBJECT_ID('dbsl.borrarLogicoClase','P') IS NOT NULL
DROP PROCEDURE dbsl.borrarLogicoClase
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

--BORRAR Reserva------------------------------

IF OBJECT_ID('dbsl.borrarLogicoReserva','P') IS NOT NULL
DROP PROCEDURE dbsl.borrarLogicoReserva
GO
CREATE PROCEDURE dbsl.borrarLogicoReserva
    @idReserva INT
AS
BEGIN
    -- Verifica existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.Reserva WHERE idReserva = @idReserva)
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

--BORRAR Inscripcion------------------------------

IF OBJECT_ID('dbsl.borrarLogicoInscripcion','P') IS NOT NULL
DROP PROCEDURE dbsl.borrarLogicoInscripcion
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

--------------------------------Borrado fisico de registro
--dbsl.CategoriaSocio – Se puede borrar siempre que no haya socios asociados.

--dbsl.GrupoFamiliar – Igual que arriba.

--dbsl.Suum – Se puede eliminar si no tiene reservas asociadas.

--dbsl.MetodoPago – Siempre que no esté usado en Cobro.

--dbsl.Factura, dbsl.Cobro, dbsl.DetalleFactura – En la vida real esto sería lógico por temas contables, pero según el ejercicio, puede ser físico si no hay dependencia.

--dbsl.PiletaVerano e dbsl.Invitado – Se pueden eliminar registros viejos si ya no son necesarios.
-----------------------------------------------------------

--BORRAR Categoria de socio-----------------------------

IF OBJECT_ID('dbsl.eliminarCategoriaSocio','P') IS NOT NULL
DROP PROCEDURE dbsl.eliminarCategoriaSocio
GO
CREATE PROCEDURE dbsl.eliminarCategoriaSocio
    @idCategoria INT
AS
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.CategoriaSocio WHERE idCategoria = @idCategoria)
    BEGIN
        RAISERROR('La categoria de socio no existe', 16, 1)
        RETURN
    END

    -- Eliminar el registro
    DELETE FROM dbsl.CategoriaSocio
    WHERE idCategoria = @idCategoria

END
GO

--BORRAR Grupo Familiar------------------------------

IF OBJECT_ID('dbsl.eliminarGrupoFamiliar','P') IS NOT NULL
DROP PROCEDURE dbsl.eliminarGrupoFamiliar
GO
CREATE PROCEDURE dbsl.eliminarGrupoFamiliar
    @idGrupo INT
AS
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.CategoriaSocio WHERE idGrupo = @idGrupo)
    BEGIN
        RAISERROR('El grupo no existe', 16, 1)
        RETURN
    END

    -- Eliminar el registro
    DELETE FROM dbsl.GrupoFamiliar
    WHERE idGrupo = @idGrupo

END
go

--BORRAR SUM------------------------------

IF OBJECT_ID('dbsl.eliminarSum','P') IS NOT NULL
DROP PROCEDURE dbsl.eliminarSum
GO
CREATE PROCEDURE dbsl.eliminarSum
    @idSum INT
AS
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.CategoriaSocio WHERE idSum = @idSum)
    BEGIN
        RAISERROR('El sum indicado no existe', 16, 1)
        RETURN
    END

    -- Eliminar el registro
    DELETE FROM dbsl.SUUM
    WHERE idSum = @idSum

END
GO

--BORRAR Metodo de Pago------------------------------

IF OBJECT_ID('dbsl.EliminarMetodoPago','P') IS NOT NULL
DROP PROCEDURE dbsl.EliminarMetodoPago
GO
CREATE PROCEDURE dbsl.EliminarMetodoPago
    @idMetodo INT
AS
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.MetodoPago WHERE idMetodoPago = @idMetodo)
    BEGIN
        RAISERROR('El metodo indicado no existe', 16, 1)
        RETURN
    END

    -- Eliminar el registro
    DELETE FROM dbsl.MetodoPago
    WHERE idMetodoPago = @idMetodo

END
GO

--BORRAR Eliminar Factura------------------------------

IF OBJECT_ID('dbsl.EliminarFactura','P') IS NOT NULL
DROP PROCEDURE dbsl.EliminarFactura
GO
CREATE PROCEDURE dbsl.EliminarFactura
    @idFactura INT
AS
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.Factura WHERE idFactura = @idFactura)
    BEGIN
        RAISERROR('La factura indicada no existe', 16, 1)
        RETURN
    END

    -- Eliminar el registro
    DELETE FROM dbsl.Factura
    WHERE idFactura = @idFactura

END
GO

--BORRAR Pileta Verano------------------------------

IF OBJECT_ID('dbsl.EliminarPiletaVerano','P') IS NOT NULL
DROP PROCEDURE dbsl.EliminarPiletaVerano
GO
CREATE PROCEDURE dbsl.EliminarPiletaVerano
    @idFactura INT
AS
BEGIN
    -- Validar existencia
    IF NOT EXISTS (SELECT 1 FROM dbsl.MetodoPago WHERE idFactura = @idFactura)
    BEGIN
        RAISERROR('La factura indicada no existe', 16, 1)
        RETURN
    END

    -- Eliminar el registro
    DELETE FROM dbsl.Factura
    WHERE idfactura = @idFactura

END
GO

