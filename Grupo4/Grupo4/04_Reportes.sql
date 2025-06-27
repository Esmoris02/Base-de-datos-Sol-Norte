use ClubSolNorte
go
---------------------------------REPORTE 1--------------------------------------
--Reporte de los socios morosos, que hayan incumplido en más de dos oportunidades dado un
--rango de fechas a ingresar. El reporte debe contener los siguientes datos:
--Nombre del reporte: Morosos Recurrentes
--Período: rango de fechas
--Nro de socio
--Nombre y apellido.
--Mes incumplido
--Ordenados de Mayor a menor por ranking de morosidad
--El mismo debe ser desarrollado utilizando Windows Function.

-------------------------------------------------------------------------------------
IF OBJECT_ID('dbsl.ReporteMorososRecurrentes', 'P') IS NOT NULL
DROP PROCEDURE dbsl.ReporteMorososRecurrentes;
GO

CREATE PROCEDURE dbsl.ReporteMorososRecurrentes
    @FechaDesde DATE,
    @FechaHasta DATE
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH FacturasMorosas AS (
        SELECT 
            F.NroSocio,
            S.Nombre,
            S.Apellido,
            YEAR(F.FechaEmision) AS Anio,
            MONTH(F.FechaEmision) AS MesNumero,
            DATENAME(MONTH, F.FechaEmision) AS MesNombre
        FROM dbsl.Factura F
        JOIN dbsl.Socio S ON F.NroSocio = S.NroSocio
        WHERE 
            F.Estado = 'Pendiente'
            AND F.FechaSegundoVencimiento < GETDATE()
            AND F.FechaEmision BETWEEN @FechaDesde AND @FechaHasta
    ),
    MorosidadConContador AS (
        SELECT 
            NroSocio,
            Nombre,
            Apellido,
            MesNombre,
            MesNumero,
            Anio,
            COUNT(*) OVER (PARTITION BY NroSocio) AS CantidadIncumplimientos,
            ROW_NUMBER() OVER (PARTITION BY NroSocio ORDER BY Anio, MesNumero) AS OrdenInterno
        FROM FacturasMorosas
    )
    SELECT 
        NroSocio,
        Nombre,
        Apellido,
        MesNombre,
        Anio,
        CantidadIncumplimientos
    FROM MorosidadConContador
    WHERE CantidadIncumplimientos > 2
    ORDER BY CantidadIncumplimientos DESC, NroSocio;
END;
GO
exec dbsl.ReporteMorososRecurrentes '2025-01-01','2025-12-31';
--------------------REPORTE 2-------------------------------------------

--Reporte acumulado mensual de ingresos por actividad deportiva al momento en que se saca
--el reporte tomando como inicio enero

---------------------------------------------------------------------------
IF OBJECT_ID('dbsl.ReporteIngresosMensualesPorActividad', 'P') IS NOT NULL
DROP PROCEDURE dbsl.ReporteIngresosMensualesPorActividad;
GO

CREATE PROCEDURE dbsl.ReporteIngresosMensualesPorActividad
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        YEAR(F.FechaEmision) AS Año,
        MONTH(F.FechaEmision) AS MesNumero,
        DATENAME(MONTH, F.FechaEmision) AS MesNombre,
        A.NombreActividad,
        SUM(DF.Monto) AS TotalIngresos
    FROM dbsl.DetalleFactura DF
    JOIN dbsl.Factura F ON DF.idFactura = F.idFactura
    JOIN dbsl.Inscripcion I ON DF.idInscripcion = I.idInscripcion
    JOIN dbsl.Clase C ON I.idClase = C.idClase
    JOIN dbsl.Actividad A ON C.idActividad = A.idActividad
    WHERE DF.tipoItem = 'Actividad'
      AND F.Estado = 'Pagada'
      AND F.FechaEmision >= '2025-01-01'
    GROUP BY 
        YEAR(F.FechaEmision),
        MONTH(F.FechaEmision),
        DATENAME(MONTH, F.FechaEmision),
        A.NombreActividad
    ORDER BY 
        Año,
        MesNumero,
        A.NombreActividad;
END;
GO
exec dbsl.ReporteIngresosMensualesPorActividad
-------------------------REPORTE 3-------------------------------------
--Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
--(inasistencias) por categoría de socios y actividad, ordenado según cantidad de inasistencias
--ordenadas de mayor a menor.
---------------------------------------------------------------
CREATE PROCEDURE dbsl.ReporteTotalInasistenciasPorCategoriaSocioYActividad
AS
BEGIN
	SELECT 
		CS.NombreCategoria,
		P.NombreActividad,
		COUNT(DISTINCT P.NroSocio) AS CantidadSociosConFaltas,
		COUNT(*) AS TotalInasistencias
	FROM dbsl.PresentismoClases P
	JOIN dbsl.Socio S ON P.NroSocio = S.NroSocio
	JOIN dbsl.CategoriaSocio CS ON S.idCategoria = CS.idCategoria
	WHERE P.Asistencia = 'A'
	GROUP BY 
		CS.NombreCategoria,
		P.NombreActividad
	ORDER BY 
		TotalInasistencias DESC;
END

EXEC dbsl.ReporteTotalInasistenciasPorCategoriaSocioYActividad

-----------------REPORTE 4---------------------------------------------------------------------------------------
--Reporte que contenga a los socios que no han asistido a alguna clase de la actividad que
--realizan. El reporte debe contener: Nombre, Apellido, edad, categoría y la actividad
--------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbsl.ReporteInasistenciasActividad
AS
BEGIN
    SELECT DISTINCT 
        S.NroSocio,
        S.Nombre,
        S.Apellido,
        DATEDIFF(YEAR, S.FechaNac, GETDATE()) AS Edad,
        P.NombreActividad,
        CS.NombreCategoria
    FROM dbsl.PresentismoClases P
    INNER JOIN dbsl.Socio S ON P.NroSocio = S.NroSocio
    INNER JOIN dbsl.CategoriaSocio CS ON S.idCategoria = CS.idCategoria
    WHERE P.Asistencia = 'A'
    ORDER BY S.Apellido, S.Nombre;
END

EXEC dbsl.ReporteInasistenciasActividad