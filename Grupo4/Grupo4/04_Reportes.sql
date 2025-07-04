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

CREATE OR ALTER PROCEDURE dbsl.ReporteMorososRecurrentes
    @Desde DATE,
    @Hasta DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        S.NroSocio,
        S.Nombre,
        S.Apellido,
		@Desde AS InicioRangoFechas,
		@Hasta AS FinRangoFechas,
        STRING_AGG(FORMAT(F.FechaSegundoVencimiento, 'yyyy-MM'), ', ') AS MesesIncumplidos,
        COUNT(*) AS Incumplimientos,
        RANK() OVER (ORDER BY COUNT(*) DESC) AS RankingMorosidad
    FROM dbsl.Factura F
    JOIN dbsl.Socio S ON S.NroSocio = F.NroSocio
    WHERE F.Estado = 'Pendiente'
      AND F.FechaSegundoVencimiento BETWEEN @Desde AND @Hasta
      AND F.FechaSegundoVencimiento < GETDATE()
    GROUP BY S.NroSocio, S.Nombre, S.Apellido
    HAVING COUNT(*) > 2
    ORDER BY RankingMorosidad;
END;
GO


exec dbsl.ReporteMorososRecurrentes '2025-01-01','2025-12-31';
--------------------REPORTE 2-------------------------------------------

--Reporte acumulado mensual de ingresos por actividad deportiva al momento en que se saca
--el reporte tomando como inicio enero

---------------------------------------------------------------------------
IF OBJECT_ID('dbsl.ReporteIngresosActividadMensual','P') IS NOT NULL
    DROP PROCEDURE dbsl.ReporteIngresosActividadMensual;
GO

CREATE PROCEDURE dbsl.ReporteIngresosMensualesPorActividad
    @Anio INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Anio IS NULL SET @Anio = YEAR(GETDATE());
    WITH IngresosMes AS (
        SELECT
            A.NombreActividad,
            MONTH(F.FechaEmision)        AS Mes,
            SUM(DF.Monto)                AS IngresoMes
        FROM dbsl.Factura         F
        JOIN dbsl.DetalleFactura  DF ON DF.idFactura = F.idFactura
        JOIN dbsl.Inscripcion     I  ON I.idInscripcion = DF.idInscripcion
        JOIN dbsl.Clase           C  ON C.idClase      = I.idClase
        JOIN dbsl.Actividad       A  ON A.idActividad  = C.idActividad
        WHERE F.Estado = 'Pagada'
          AND DF.tipoItem = 'Actividad'
          AND YEAR(F.FechaEmision) = @Anio
        GROUP BY A.NombreActividad, MONTH(F.FechaEmision)
    ),
    Acumulado AS (
        SELECT
            NombreActividad,
            Mes,
            IngresoMes,
            SUM(IngresoMes) OVER (
                PARTITION BY NombreActividad
                ORDER BY Mes
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS IngresoAcumulado
        FROM IngresosMes
    )
    SELECT
        NombreActividad AS [Actividad],
        Mes,
        IngresoMes AS [Ingreso del Mes],
        IngresoAcumulado AS [Ingreso Acumulado]
    FROM Acumulado
    ORDER BY NombreActividad, Mes;
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