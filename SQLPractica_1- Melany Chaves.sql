USE SQLI_Examen;

/* Muestre el TOP 10 de clientes (Destinatarios) que mayor invirtieron
(en términos de montoDolarizado) que se encuentren entre las
edades de 21 a 29 años */

SELECT
Top 10
A.Nombre
,A.PrimerApellido
,A.SegundoApellido
,A.Codigo

,DATEDIFF(YEAR, A.FechaNacimiento, GETDATE()) AS Edad
,SUM(case
wHEN C.Codigo = 'USD' THEN B.Monto
WHEN C.Codigo = 'CRC' THEN (B.Monto / 615.37)
WHEN C.Codigo = 'EUR' THEN ((B.Monto*720.15)/ 615.37)
END) AS MontoDolarizado

from
dbo.Clientes as A
JOIN dbo.Transferencias as B
on a.Codigo = b.IdClienteDestino
JOIN dbo.Monedas as C
on b.IdMoneda = c.Id

where
DATEDIFF(YEAR, A.FechaNacimiento, GETDATE()) >= 21
and DATEDIFF(YEAR, A.FechaNacimiento, GETDATE()) <= 29

GROUP BY
A.Nombre
,A.PrimerApellido
,A.SegundoApellido
,A.Codigo
,A.FechaNacimiento

ORDER BY
MontoDolarizado DESC
;

/* Muestre el Promedio de Transferencias (en términos de
montoDolarizado) de los clientes (Originarios) que viven en la
Provincia de Puntarenas */

SELECT 

AVG(case
wHEN C.Codigo = '1' THEN T.Monto
WHEN C.Codigo = '2' THEN (T.Monto / 615.37)
WHEN C.Codigo = '3' THEN ((T.Monto*720.15)/ 615.37) 
END) AS Monto_Promedio

FROM dbo.Clientes AS C
JOIN dbo.Transferencias as T
ON C.Codigo = T.IdClienteOrigen
JOIN dbo.Monedas AS M
ON M.Id = T.IdMoneda

WHERE C.Provincia = 'Puntarenas'
;

/* Cuantos Clientes (Originarios) diferentes Transfirieron en la Moneda
Euros. */

SELECT DISTINCT 
COUNT(IdClienteOrigen) AS ClientesO_Euros

FROM dbo.Clientes AS C
JOIN dbo.Transferencias as T
ON C.Codigo = T.IdClienteOrigen
JOIN dbo.Monedas as M
ON M.Id = T.IdMoneda

WHERE T.IdMoneda = '3'
;

/* Cuantas Transacciones están en estado Flotantes en los meses de
Agosto y Setiembre 2020. */

SELECT DISTINCT 
COUNT(FechaHora) AS Transferencias_Flotantes

FROM dbo.Clientes AS C
JOIN dbo.Transferencias as T
ON C.Codigo = T.IdClienteOrigen
JOIN dbo.Estados as E
ON E.Codigo = T.IdEstadoTransferencia

WHERE T.IdEstadoTransferencia = '2'
AND T.FechaHora >= '2020-08-01' 
AND T.FechaHora <= '2020-09-30'
;


/* Ver la Cantidad de Transacciones y el Monto Promedio
(MontoDolarizado) de las transacciones de Noviembre y Diciembre
del 2020 hechas en el Banco Nacional */


SELECT 
COUNT(T.FechaHora) AS Transferencias_Totales
,AVG(case
wHEN C.Codigo = '1' THEN T.Monto
WHEN C.Codigo = '2' THEN (T.Monto / 615.37)
WHEN C.Codigo = '3' THEN ((T.Monto*720.15)/ 615.37) 
END) AS Monto_Promedio

FROM dbo.Clientes AS C
JOIN dbo.Transferencias AS T
ON C.Codigo = T.IdClienteOrigen
JOIN dbo.Estados AS E
ON E.Codigo = T.IdEstadoTransferencia
JOIN dbo.Monedas AS M
ON M.Id = T.IdMoneda

WHERE 
T.FechaHora >= '2020-11-01' 
AND T.FechaHora <= '2020-12-31'
;

/* Comparar la cantidad de Transacciones, la Desviación Estándar y el
Total (MontoDolarizado) de los Bancos Públicos vs los Bancos
Privados */

SELECT DISTINCT

B.Tipo
,COUNT(T.FechaHora) AS Cantidad_Transacciones
,STDEV(case
wHEN T.IdMoneda = '1' THEN T.Monto
WHEN T.IdMoneda = '2' THEN (T.Monto / 615.37)
WHEN T.IdMoneda = '3' THEN ((T.Monto*720.15)/ 615.37) 
END) AS Desviacion


FROM dbo.Transferencias AS T
JOIN dbo.Monedas  M
ON M.Id = T.IdMoneda
JOIN dbo.Bancos as B
ON T.IdBanco = B.Codigo

GROUP BY
Tipo
,IdMoneda
,Monto

ORDER BY
B.Tipo ASC
;

