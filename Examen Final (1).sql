USE SQLII_ExamenFinal;
SELECT *
FROM dbo.BaseClientes


SELECT 
    SubTabla.NoCliente
    ,SubTabla.FlagClienteRegular
    ,SubTabla.NivelEndeudamiento
    ,SubTabla.DependientesYBienes
    ,SubTabla.RangoSalarial
    ,SubTabla.ScoreClientes
    ,SubTabla.ScoreFinal
    ,SubTabla.Riesgo

FROM (
    SELECT 
        Tabla.NoCliente
        ,Tabla.FlagClienteRegular
        ,Tabla.NivelEndeudamiento
        ,Tabla.DependientesYBienes
        ,Tabla.RangoSalarial
        ,Tabla.ScoreClientes
        ,Tabla.FlagClienteRegular + Tabla.NivelEndeudamiento + Tabla.RangoSalarial + Tabla.ScoreClientes + Tabla.DependientesYBienes AS ScoreFinal
        ,CASE 
        WHEN Tabla.FlagClienteRegular + Tabla.NivelEndeudamiento + Tabla.RangoSalarial + Tabla.ScoreClientes + Tabla.DependientesYBienes >= 25 THEN 'Riesgo Bajo'
        WHEN Tabla.FlagClienteRegular + Tabla.NivelEndeudamiento + Tabla.RangoSalarial + Tabla.ScoreClientes + Tabla.DependientesYBienes >= 15 AND Tabla.FlagClienteRegular + Tabla.NivelEndeudamiento + Tabla.RangoSalarial + Tabla.ScoreClientes + Tabla.DependientesYBienes<= 24 THEN 'Riesgo Medio'
        WHEN Tabla.FlagClienteRegular + Tabla.NivelEndeudamiento + Tabla.RangoSalarial + Tabla.ScoreClientes  + Tabla.DependientesYBienes<= 14 THEN 'Riesgo Alto'
        ELSE NULL
        END AS Riesgo
        ,ROW_NUMBER() OVER (PARTITION BY Tabla.NoCliente ORDER BY Tabla.RangoSalarial, Tabla.DependientesYBienes) AS Rank
    
    FROM (
        SELECT 
            A.NoCliente

            ,CASE WHEN A.FlagClienteRegular = 1 THEN CAST(7 AS INT) 
            ELSE CAST(5 AS INT) 
            END AS FlagClienteRegular

            ,CASE 
                WHEN C.NivelEndeudamiento = 'Apto' THEN CAST(7 AS INT)
                WHEN C.NivelEndeudamiento = 'Condicionado' THEN CAST(4 AS INT)
                WHEN C.NivelEndeudamiento = 'No Apto' THEN CAST(1 AS INT)
                ELSE CAST(1 AS INT)
            END AS NivelEndeudamiento

            ,CASE 
                WHEN B.CantidadVehiculos > 0 AND B.CantidadVehiculos = 2 AND B.CantidadPropiedades = 2 THEN CAST(7 AS INT)
                WHEN B.CantidadVehiculos = 0 AND B.CantidadVehiculos = 2 AND B.CantidadPropiedades = 1 THEN CAST(7 AS INT)
                WHEN B.CantidadVehiculos = 0 AND B.CantidadVehiculos = 1 AND B.CantidadPropiedades = 2 THEN CAST(7 AS INT)
                WHEN B.CantidadVehiculos = 0 AND B.CantidadVehiculos = 1 AND B.CantidadPropiedades = 1 THEN CAST(6 AS INT)
                WHEN B.CantidadVehiculos = 0 AND B.CantidadVehiculos = 0 AND B.CantidadPropiedades >= 1 THEN CAST(5 AS INT)
                WHEN B.CantidadVehiculos = 1 AND B.CantidadVehiculos = 1 AND B.CantidadPropiedades = 2 THEN CAST(5 AS INT)
                WHEN B.CantidadVehiculos = 1 AND B.CantidadVehiculos = 2 AND B.CantidadPropiedades = 2 THEN CAST(4 AS INT)
                WHEN B.CantidadVehiculos = 1 AND B.CantidadVehiculos <= 1 AND B.CantidadPropiedades <= 1 THEN CAST(3 AS INT)
                WHEN B.CantidadVehiculos >= 2 AND B.CantidadVehiculos <= 1 AND B.CantidadPropiedades <= 1 THEN CAST(3 AS INT)
                ELSE CAST(1 AS INT)
            END AS DependientesYBienes

            ,CASE
			WHEN D.RangoSalarial = 'Menor a $1000' THEN CAST(1 AS INT)
            WHEN D.RangoSalarial = 'Entre $1000 y $3000' THEN CAST(3 AS INT)
            WHEN D.RangoSalarial = 'Entre $3000 y $6000' THEN CAST(5 AS INT)
            WHEN D.RangoSalarial = 'Mayor a $6000' THEN CAST(7 AS INT)
			ELSE CAST(1 AS INT)
		END AS RangoSalarial

        ,CASE
			WHEN E.Score = 5 THEN CAST(7 AS INT)
            WHEN E.Score = 4 THEN CAST(6 AS INT)
            WHEN E.Score = 3 THEN CAST(5 AS INT)
            WHEN E.Score <= 2 THEN CAST(3 AS INT)
			ELSE CAST(1 AS INT)
		END AS ScoreClientes


    FROM dbo.BaseClientes as A
    INNER JOIN dbo.DependientesYBienes as B
    ON A.NoCliente = B.Cliente
    INNER JOIN dbo.NivelEndeudamiento as C 
    ON A.NoCliente = C.CodigoCliente
    INNER JOIN dbo.RangoSalarial as D
    ON A.NoCliente = D.NoCliente
    INNER JOIN dbo.ScoreClientes as E
    ON A.NoCliente = E.Cliente

) AS Tabla

) AS SubTabla

WHERE 

Subtabla.Rank = 1
;


-- El segundo debe ser un resumen de la cantidad de Clientes Distintos por los diferentes Perfiles de Riesgo Calculados.

SELECT DISTINCT
TablaRiesgo.Riesgo
,COUNT(TablaRiesgo.NoCliente) AS Clientes

FROM (

SELECT 
    SubTabla.NoCliente
    ,SubTabla.FlagClienteRegular
    ,SubTabla.NivelEndeudamiento
    ,SubTabla.DependientesYBienes
    ,SubTabla.RangoSalarial
    ,SubTabla.ScoreClientes
    ,SubTabla.ScoreFinal
    ,SubTabla.Riesgo

FROM (
    SELECT 
        Tabla.NoCliente
        ,Tabla.FlagClienteRegular
        ,Tabla.NivelEndeudamiento
        ,Tabla.DependientesYBienes
        ,Tabla.RangoSalarial
        ,Tabla.ScoreClientes
        ,Tabla.FlagClienteRegular + Tabla.NivelEndeudamiento + Tabla.RangoSalarial + Tabla.ScoreClientes + Tabla.DependientesYBienes AS ScoreFinal
        ,CASE 
        WHEN Tabla.FlagClienteRegular + Tabla.NivelEndeudamiento + Tabla.RangoSalarial + Tabla.ScoreClientes + Tabla.DependientesYBienes >= 25 THEN 'Riesgo Bajo'
        WHEN Tabla.FlagClienteRegular + Tabla.NivelEndeudamiento + Tabla.RangoSalarial + Tabla.ScoreClientes + Tabla.DependientesYBienes >= 15 AND Tabla.FlagClienteRegular + Tabla.NivelEndeudamiento + Tabla.RangoSalarial + Tabla.ScoreClientes + Tabla.DependientesYBienes<= 24 THEN 'Riesgo Medio'
        WHEN Tabla.FlagClienteRegular + Tabla.NivelEndeudamiento + Tabla.RangoSalarial + Tabla.ScoreClientes  + Tabla.DependientesYBienes<= 14 THEN 'Riesgo Alto'
        ELSE NULL
        END AS Riesgo
        ,ROW_NUMBER() OVER (PARTITION BY Tabla.NoCliente ORDER BY Tabla.RangoSalarial, Tabla.DependientesYBienes) AS Rank
    
    FROM (
        SELECT 
            A.NoCliente

            ,CASE WHEN A.FlagClienteRegular = 1 THEN CAST(7 AS INT) 
            ELSE CAST(5 AS INT) 
            END AS FlagClienteRegular

            ,CASE 
                WHEN C.NivelEndeudamiento = 'Apto' THEN CAST(7 AS INT)
                WHEN C.NivelEndeudamiento = 'Condicionado' THEN CAST(4 AS INT)
                WHEN C.NivelEndeudamiento = 'No Apto' THEN CAST(1 AS INT)
                ELSE CAST(1 AS INT)
            END AS NivelEndeudamiento

            ,CASE 
                WHEN B.CantidadVehiculos > 0 AND B.CantidadVehiculos = 2 AND B.CantidadPropiedades = 2 THEN CAST(7 AS INT)
                WHEN B.CantidadVehiculos = 0 AND B.CantidadVehiculos = 2 AND B.CantidadPropiedades = 1 THEN CAST(7 AS INT)
                WHEN B.CantidadVehiculos = 0 AND B.CantidadVehiculos = 1 AND B.CantidadPropiedades = 2 THEN CAST(7 AS INT)
                WHEN B.CantidadVehiculos = 0 AND B.CantidadVehiculos = 1 AND B.CantidadPropiedades = 1 THEN CAST(6 AS INT)
                WHEN B.CantidadVehiculos = 0 AND B.CantidadVehiculos = 0 AND B.CantidadPropiedades >= 1 THEN CAST(5 AS INT)
                WHEN B.CantidadVehiculos = 1 AND B.CantidadVehiculos = 1 AND B.CantidadPropiedades = 2 THEN CAST(5 AS INT)
                WHEN B.CantidadVehiculos = 1 AND B.CantidadVehiculos = 2 AND B.CantidadPropiedades = 2 THEN CAST(4 AS INT)
                WHEN B.CantidadVehiculos = 1 AND B.CantidadVehiculos <= 1 AND B.CantidadPropiedades <= 1 THEN CAST(3 AS INT)
                WHEN B.CantidadVehiculos >= 2 AND B.CantidadVehiculos <= 1 AND B.CantidadPropiedades <= 1 THEN CAST(3 AS INT)
                ELSE CAST(1 AS INT)
            END AS DependientesYBienes

            ,CASE
			WHEN D.RangoSalarial = 'Menor a $1000' THEN CAST(1 AS INT)
            WHEN D.RangoSalarial = 'Entre $1000 y $3000' THEN CAST(3 AS INT)
            WHEN D.RangoSalarial = 'Entre $3000 y $6000' THEN CAST(5 AS INT)
            WHEN D.RangoSalarial = 'Mayor a $6000' THEN CAST(7 AS INT)
			ELSE CAST(1 AS INT)
		END AS RangoSalarial

        ,CASE
			WHEN E.Score = 5 THEN CAST(7 AS INT)
            WHEN E.Score = 4 THEN CAST(6 AS INT)
            WHEN E.Score = 3 THEN CAST(5 AS INT)
            WHEN E.Score <= 2 THEN CAST(3 AS INT)
			ELSE CAST(1 AS INT)
		END AS ScoreClientes


    FROM dbo.BaseClientes as A
    INNER JOIN dbo.DependientesYBienes as B
    ON A.NoCliente = B.Cliente
    INNER JOIN dbo.NivelEndeudamiento as C 
    ON A.NoCliente = C.CodigoCliente
    INNER JOIN dbo.RangoSalarial as D
    ON A.NoCliente = D.NoCliente
    INNER JOIN dbo.ScoreClientes as E
    ON A.NoCliente = E.Cliente

) AS Tabla

) AS SubTabla

WHERE 

Subtabla.Rank = 1
) AS TablaRiesgo

GROUP BY 
Riesgo

ORDER BY
Riesgo DESC;
