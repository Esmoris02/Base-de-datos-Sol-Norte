use ClubSolNorte
go
--------Reporte 1----------
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
-------Reporte 2-----------
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