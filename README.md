# Proyecto de Base de Datos: El Gran Abarrotero 🏪

Este repositorio contiene el proyecto final para la materia de Fundamentos de Bases de Datos, enfocado en el diseño e implementación de una base de datos para una tienda de abarrotes llamada "El Gran Abarrotero".

---

## 📜 Descripción

El objetivo principal de este proyecto es modelar, crear y poblar una base de datos relacional en **PostgreSQL** que gestione eficientemente la información de una tienda de abarrotes. Esto incluye la administración de productos, empleados, clientes, ventas y el inventario en las distintas sucursales.

El sistema está diseñado para manejar las operaciones diarias de la tienda, permitiendo realizar consultas complejas y mantener la integridad de los datos.

---

## 🗃️ Estructura del Proyecto

El proyecto se encuentra organizado en las siguientes carpetas y archivos:

* **`/Database`**: Contiene todos los scripts SQL necesarios para la creación, manipulación y consulta de la base de datos.
    * **`DDL.sql`**: Creación de tablas, restricciones y llaves.
    * **`DML.sql`**: Inserción de datos de ejemplo para poblar la base de datos.
    * **`DQL.sql`**: Consultas de ejemplo para obtener información relevante.
    * **`Programacion.sql`**: Procedimientos almacenados y triggers para automatizar tareas.
* **`/Diagrams`**: Incluye los diagramas del modelo de la base de datos.
    * **`ER_MongoBingo.jpg`**: Diagrama Entidad-Relación.
    * **`Relacional_MongoBingo.jpg`**: Diagrama del Esquema Relacional.
    * Archivos fuente `.drawio` de los diagramas.

---

## 🖼️ Modelo de la Base de Datos

Se diseñó un modelo Entidad-Relación y un modelo Relacional para representar la estructura de la base de datos.

### Diagrama Entidad-Relación
*A continuación, se muestra una imagen del diagrama Entidad-Relación que sirvió como base para el diseño.*
![Diagrama Entidad-Relación](./Diagrams/ER_MongoBingo.jpg)

### Esquema Relacional
*Este es el esquema relacional que define las tablas, sus atributos y las relaciones entre ellas.*
![Esquema Relacional](./Diagrams/Relacional_MongoBingo.jpg)

---

## ✨ Funcionalidades Principales

* **Gestión de Catálogos**: Manejo de la información de productos, clientes y empleados.
* **Control de Inventario**: Administración del stock de productos por sucursal.
* **Registro de Ventas**: Sistema para registrar las ventas y los productos asociados a cada una.
* **Consultas Analíticas**: Consultas complejas para obtener insights del negocio.
* **Automatización**: Uso de triggers y procedimientos para mantener la consistencia e integridad de los datos.

---

## 👥 Autores

* Arturo
* Jaime
* Braulio
* Daniel
* Yun