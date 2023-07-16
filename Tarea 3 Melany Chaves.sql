USE AdventureWorks2019;
 
-- En un SELECT sobre alguna de las tablas de la base de datos AdventureWorks2019, aplique un ejemplo usando un Subquery Correlacionado.--

SELECT DISTINCT
PurchaseOrderID
,OrderQty
,(SELECT MAX(DueDate) FROM Purchasing.PurchaseOrderDetail) AS Due_Date

FROM Purchasing.PurchaseOrderDetail

ORDER BY
OrderQty DESC;

-- En un SELECT sobre alguna de las tablas de la base de datos AdventureWorks2019, aplique un ejemplo usando un Subquery en la sección del FROM

SELECT

A.HireDate
,A.CantidadContratada

FROM 
(
    SELECT
    HireDate
    ,COUNT(HireDate) AS CantidadContratada

    FROM
    HumanResources.Employee

    WHERE 
    HireDate >= '2009-01-01'

    GROUP BY
    HireDate

) AS A

    ORDER BY
    A.HireDate ASC
;

-- En un SELECT sobre algunas de las tablas de la base de datos AdventureWorks2019, aplique un ejemplo usando un Subquery en la sección del FROM junto con un LEFT JOIN hacia otra tabla.

SELECT
 Stock.Name
 ,Stock.OrderQty
 ,Stock.StockedQty

FROM 

    (
        SELECT 
        O.OrderQty
        ,P.Name
        ,O.StockedQty
        ,O.DueDate

        FROM Purchasing.PurchaseOrderDetail AS O
        LEFT JOIN Production.Product AS P
        ON O.ProductID = P.ProductID
    ) AS Stock
;

-- En un SELECT sobre algunas de las tablas de la base de datos AdventureWorks2019, aplique un ejemplo usando un Subquery en la sección del FROM junto con un RIGHT JOIN hacia otra tabla

SELECT
Employee.FirstName
,Employee.LastName
,Employee.Rate
,Employee.OrganizationLevel
FROM 
(
    SELECT
    N.FirstName
    ,N.LastName
    ,P.Rate
,E.HireDate
,E.OrganizationLevel

    FROM HumanResources.EmployeePayHistory AS P
    RIGHT JOIN HumanResources.Employee AS E
    ON P.BusinessEntityID = E.BusinessEntityID
    RIGHT JOIN Person.Person AS N
    ON E.BusinessEntityID = N.BusinessEntityID
) AS Employee

ORDER BY
OrganizationLevel DESC
,Rate DESC
;


-- En un SELECT sobre algunas de las tablas de la base de datos AdventureWorks2019, realice un ejemplo realizandos dos Subquerys en la sección del FROM y curzandolos por medio de algún JOIN (puede ser: INNER JOIN, LEFT JOIN o RIGHT JOIN) --
SELECT DISTINCT
Persona.FirstName
,Persona.LastName
,Titulo.Name

FROM
(SELECT 
P.FirstName
,P.LastName
,E.EmailAddress
, 1 AS Llave

FROM Person.Person AS P
LEFT JOIN Person.EmailAddress AS E
ON P.BusinessEntityID = E.BusinessEntityID
) AS Persona
INNER JOIN
(
    SELECT 
     C.Name
     , 1 AS Llave
FROM
   Person.ContactType AS C
   LEFT JOIN Person.BusinessEntityContact AS B
   ON C.ContactTypeID = B.ContactTypeID
   LEFT JOIN Person.Person AS E
   ON B.BusinessEntityID = E.BusinessEntityID
) AS Titulo
ON Persona.Llave = Titulo.Llave
;
