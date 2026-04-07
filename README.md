# Cómo Ejecutar el Proyecto

Para probar este proyecto en tu entorno local, necesitas tener instalado
PostgreSQL (y opcionalmente pgAdmin o DBeaver para facilitar la interfaz
gráfica).

Sigue este orden estricto de ejecución para evitar errores de
dependencias:

## 1. Crear la base de datos

Abre tu consola de `psql` o tu gestor de base de datos y crea una nueva
base de datos para el proyecto:

``` sql
CREATE DATABASE el_gran_abarrotero;
```

Conéctate a la base de datos recién creada.

## 2. Ejecutar el esquema (DDL)

Ejecuta el script `DDL.sql`. Esto creará todas las tablas principales
(Sucursal, Producto, Empleado, Cliente, Venta, etc.) junto con sus
llaves primarias, foráneas y restricciones (como checks y dominios).

## 3. Cargar la lógica de programación

Ejecuta el script `Programacion.sql`.

Es muy importante hacerlo antes de poblar la base de datos o registrar
ventas, ya que esto inicializa los Procedimientos Almacenados (Stored
Procedures) y los Disparadores (Triggers) que validan las inserciones y
calculan el stock dinámicamente.

## 4. Poblar la base de datos (DML)

Ejecuta el script `DML.sql`. Este archivo contiene todos los comandos
`INSERT` que llenarán los catálogos con datos de prueba (sucursales,
clientes, empleados y productos iniciales).

## 5. Probar las consultas (DQL)

Finalmente, abre el script `DQL.sql` y ejecuta las consultas analíticas
una por una para comprobar que los datos se extraen correctamente (por
ejemplo, el cálculo de ventas por departamento o el desempeño de los
cajeros).

------------------------------------------------------------------------

# Autores y Equipo de Desarrollo

Este proyecto fue desarrollado en la Facultad de Ciencias de la UNAM
(Semestre 2023-II) para la materia de Fundamentos de Bases de Datos:

-   Mario Letepichia Romero --- Número de cuenta: 318316611
-   Ivette González Mancera --- Número de cuenta: 316014490
-   Jaime Octavio Delfín López --- Número de cuenta: 318315308
-   Alexis de Jesús Arizmendi López --- Número de cuenta: 318176110
-   Yun Hernández González --- Número de cuenta: 318261171
-   Erick Joel Baltodano Cuevas --- Número de cuenta: 312245924
