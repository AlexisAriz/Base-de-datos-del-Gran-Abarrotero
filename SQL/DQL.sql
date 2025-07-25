--Extra: Regresa el dinero (redondeado) recaudado por todas las sucursales en el primer cuatrimestre del año.
SELECT ROUND(SUM(Precio * Cantidad), 0)
FROM Venta NATURAL JOIN (DesglosarProducto NATURAL JOIN Producto)
WHERE FechaVenta >= '2023-01-01' AND FechaVenta <= '2023-04-30';

-- 1 Regresa el dinero (redondeado) recaudado por cada una las sucursales en el primer cuatrimestre del año ordenadas por su ID.
SELECT IDSucursal, ROUND(SUM(Precio * Cantidad), 0) as Total_por_sucursal
FROM Venta NATURAL JOIN (DesglosarProducto NATURAL JOIN Producto)
WHERE FechaVenta >= '2023-01-01' AND FechaVenta <= '2023-04-30'
GROUP BY IDSucursal
ORDER BY IDSucursal;

-- 2 Regresa la cantidad de dinero recaudado por departamento en el primer cuatrimestre del año y su porcentaje en relación al total.
SELECT Departamento, Ventas_por_departamento, ((Ventas_por_departamento * 100) / Total_Ventas) AS Porcentaje_de_ventas
from
(SELECT Departamento, COUNT(*) AS Ventas_por_departamento
FROM Venta natural join Producto
WHERE FechaVenta >= '2023-01-01' AND FechaVenta <= '2023-04-30'
GROUP BY Departamento) as X, 
(SELECT  COUNT(*) AS Total_Ventas
FROM Venta natural join Producto
WHERE FechaVenta >= '2023-01-01' AND FechaVenta <= '2023-04-30') as Y

-- 3 Regresa los 5 productos más vendidos de cada departamento con su número total de ventas.
SELECT Nombre, Departamento, Total_ventas
from 
(SELECT Nombre, Departamento, Total_ventas, row_number() OVER (PARTITION BY Departamento ORDER BY Total_ventas DESC) AS n
from 
(SELECT Nombre, SUM(Cantidad) AS Total_ventas, Departamento
from Producto NATURAL join DesglosarProducto
GROUP BY IDProducto) as x) as y
WHERE n <= 5;

-- 4 Regresa las 15 colonias con mayor número de clientes que provienen de ellas, dicho numero y si hay una sucursal en ellas.
SELECT Colonia_Clientes, Numero_clientes, CASE WHEN Colonia IS NULL THEN 'No' ELSE 'Sí' END AS Hay_Sucursal
FROM
(SELECT Colonia as Colonia_Clientes, COUNT(*) AS Numero_clientes
from Cliente
GROUP BY Colonia) AS X
LEFT JOIN
(SELECT Colonia
from Sucursal 
GROUP BY Colonia) as Y
ON Colonia_Clientes=Colonia
ORDER BY Numero_clientes desc
limit 15;

-- 5 Regresa las 15 sucursales con menor numero de ventas que hechas en el primer cuatrimestre del año, junto con su dirección.
SELECT IDSucursal, Nombre, Total_ventas, CONCAT('Calle ', Calle, ', #', NumExterior, ', Colonia ', Colonia, ', CP ', CP)
FROM 
(SELECT IDSucursal, COUNT(*) AS Total_ventas
FROM Venta natural join Sucursal 
WHERE FechaVenta >= '2023-01-01' AND FechaVenta <= '2023-04-30'
GROUP BY IDSucursal) as X
natural join Sucursal
ORDER BY Total_ventas asc
LIMIT 15;

-- 6 Regresa las sucursales que abren después de las 8:30 con su hora de apertura.
SELECT IDSucursal, Nombre, HInicio, CONCAT('Calle ', Calle, ', #', NumExterior, ', Colonia ', Colonia, ', CP ', CP)
from Sucursal
where HInicio > '8:30 am'
ORDER BY HInicio desc;

-- 7 Regresa todas las sucursales que se encuntran en una calle cerrada o en una privada.
SELECT IDSucursal, Nombre, CONCAT('Calle ', Calle, ', #', NumExterior, ', Colonia ', Colonia, ', CP ', CP)
from Sucursal
where lower(Calle) like 'privada%' or lower(Calle) like 'cerrada%';

-- 8 Regresa el producto menos vendidos de cada sucursal con su número total de ventas.
SELECT IDSucursal, Nombre, Total_ventas
from 
(SELECT IDSucursal, Nombre, Total_ventas, row_number() OVER (PARTITION BY IDSucursal ORDER BY Total_ventas ASC) AS n
from 
(SELECT Nombre, IDProducto, SUM(Cantidad) AS Total_ventas
from Producto NATURAL join DesglosarProducto 
GROUP BY IDProducto) as X
NATURAL join Venta) as Y
WHERE n <= 1;

-- 9 Regresa el nombre, sucursal y celular de los encargados de todas las suscursales ordenados por número de sucursal.
SELECT IDSucursal, Encargado, Telefono
FROM
(SELECT  DISTINCT on (CURP) IDSucursal, CONCAT(NombreP,' ', AMaterno,' ', APaterno) as Encargado, Telefono
from Empleado NATURAL join TelefonoEmpleado
where Puesto = 'encargado') as X
order by IDSucursal ASC;

-- 10 Regresa los productos percederos cuya fecha de preparación tenga más de 4 meses, con su stock, sucursal y ordenados de manera descendente.
SELECT Nombre, StockSucursal, IDSucursal
from Producto NATURAL join AbarrotePerecedero NATURAL join TenerProducto
where Departamento='abarroteperecedero' and now()::date - FechaPreparacion >= 120
order by StockSucursal DESC;

-- 11 Regresa el valor promedio de una venta por sucursal.
SELECT  ROUND(AVG(Precio * Cantidad), 0)
from (DesglosarProducto NATURAL JOIN Producto) NATURAL JOIN Venta
GROUP BY IDSucursal;

-- 12 Regresa el nombre y email de los Clientes que hayan pagado con tarjeta durante mayo del 2023.
SELECT DISTINCT on (CURP) NombreP, Email, FechaVenta
from (Venta NATURAL JOIN Cliente) NATURAL JOIN EmailCliente
where MetodoPago = 'tarjeta' and '2023-05-01' >= FechaVenta and FechaVenta <= '2023-05-31'

-- 13 Regresa los productos del departamento ElectronicaCons almacenados desde hace más de 3 años y les aplica un 50 porciento de descuento a su precio.
SELECT IDProducto , Nombre, (Precio * (.5)) as Precio_con_descuento, FechaAlmacenado
from Producto NATURAL JOIN ElectronicaCons 
where now()::date - FechaAlmacenado > 1095.75;

--14

-- Extra: Regresa el total de empleados.
SELECT COUNT(*) AS Total_empleados
FROM Empleado;

-- 15 Regresa el total de empleados que tiene cada sucursal.
SELECT IDSucursal, COUNT(*) AS Total_empleados
FROM Empleado
GROUP BY IDSucursal
ORDER BY IDSucursal;

-- Extra: Imprime los clientes que se llaman Juan, hayan nacido entre 1980-01-01 y 1990-12-31, y que su dirección no incluya la calle camelia, la cerrada
-- el centauro o la privada aldama.
SELECT * 
from cliente
where NombreP ilike 'juan%' and
      Calle not in ('calle camelia','cerrada el centauro','privada aldama') and
	  FechaNac >= '1980-01-01' and FechaNac <= '1990-12-31';