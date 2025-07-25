--Tabla: Sucursal
CREATE TABLE IF NOT EXISTS Sucursal
(
    IDSucursal serial,
    Calle varchar(60) NOT NULL,
    NumInterior varchar(25),
    NumExterior varchar(25) NOT NULL,
    CP char(5) NOT NULL,
    Colonia varchar(70) NOT NULL,
    Nombre varchar(50) NOT NULL, 
    FechaApertura date NOT NULL,
    HInicio time NOT NULL, 
    HFin time NOT NULL, 
    CONSTRAINT pkIDSucursal PRIMARY KEY (IDSucursal),
    CONSTRAINT CP check(CP not like '%[^0-9]%'),
    CONSTRAINT FechaApertura check(FechaApertura < CURRENT_DATE),
    CONSTRAINT Horario check (HInicio < HFin)
);
--Comentarios restricciones Sucursal
COMMENT ON CONSTRAINT pkIDSucursal ON Sucursal IS 'idsucursal es la llave primara de Sucursal';
COMMENT ON CONSTRAINT CP ON Sucursal IS 'El código postal debe ser caracteres numericos';
COMMENT ON CONSTRAINT FechaApertura ON Sucursal IS 'La fecha de apertura no puede ser posterior a la fecha actual.';
COMMENT ON CONSTRAINT Horario ON Sucursal IS 'La hora de inicio debe ser menor a la hora de cierrer';
-- Comentarios de la tabla Sucursal
comment on table Sucursal is 'Tabla con la información de las sucursales';
comment on column Sucursal.IDSucursal is 'Identificador de la sucursal';
comment on column Sucursal.Nombre is 'Nombre de la sucursal';
comment on column Sucursal.Calle is 'La calle de la sucursal'; 
comment on column Sucursal.NumInterior is 'El número interior de la sucursal (ej. dentro de una plaza)';
comment on column Sucursal.NumExterior is 'El número de la calle de la sucursal';
comment on column Sucursal.CP is 'El código postal de la sucursal';
comment on column Sucursal.Colonia is 'La colonia en la que se encuentra la sucursal';
comment on column Sucursal.HInicio is 'La hora de apertura de la sucursal';
comment on column Sucursal.FechaApertura is 'La fecha de apertura de la sucursal';
comment on column Sucursal.HFin is 'La hora de cierre de la sucursal';

--Tabla: Producto
CREATE TABLE IF NOT EXISTS Producto
(
    IDProducto serial,
    Marca varchar(60) NOT NULL,
    Nombre varchar(50) NOT NULL,
    Precio decimal(9,2) NOT NULL,
	Departamento varchar(20) NOT NULL,
    CONSTRAINT pkProducto PRIMARY KEY (IDProducto),
    CONSTRAINT Precio check(Precio>0),
	CONSTRAINT depar check (Departamento IN ('abarroteperecedero','abarrotenoperecedero','electronicacons'))
);
--Comentarios restricciones en Producto
COMMENT ON CONSTRAINT pkProducto ON Producto IS 'idproducto es la llave primara de Producto';
COMMENT ON CONSTRAINT Precio ON Producto IS 'El precio de un producto no pueder ser menor a 0';
COMMENT ON CONSTRAINT depar ON Producto IS 'El producto puede pertenecer al departamento abarroteperecedero, abarrotenoperecedero y electronicacons';
--Comentarios de la tabla Producto
comment on table Producto is 'Tabla con la información de los productos';
comment on column Producto.IDProducto is 'Identificador de un producto';
comment on column Producto.Marca is 'La Marca a la que pertenece un producto';
comment on column Producto.Nombre is 'Nombre del pruducto';
comment on column Producto.Precio is 'El precio del producto';
comment on column Producto.Departamento is 'El departamento de un producto';

--Tabla: AbarrotePerecedero
CREATE TABLE IF NOT EXISTS AbarrotePerecedero
(
	IDAlmacen serial,
    IDProducto int NOT NULL,
	FechaAlmacenado date NOT NULL,
    Presentacion varchar(50) NOT NULL,
    FechaPreparacion date NOT NULL,
    FechaCaducidad date NOT NULL,
    CONSTRAINT pkPerecedero PRIMARY KEY (IDAlmacen),
	CONSTRAINT fkPerecedero FOREIGN KEY (IDProducto) REFERENCES Producto(IDProducto)
	on update cascade on delete cascade,
	CONSTRAINT FechaAlma check(FechaAlmacenado <= CURRENT_DATE),
    CONSTRAINT FechaPrep check(FechaPreparacion <= CURRENT_DATE),
    CONSTRAINT Caducidad check (FechaPreparacion <= FechaCaducidad)
);
-- Comentarios restricciones en AbarrotePerecedero
COMMENT ON CONSTRAINT pkPerecedero ON AbarrotePerecedero IS 'idalmacen es la llave primara de Abarrote Perecedero';
COMMENT ON CONSTRAINT fkPerecedero ON AbarrotePerecedero IS 'idproducto es la llave foranea de la tabla Producto en Abarrote Perecedero';
COMMENT ON CONSTRAINT FechaAlma ON AbarrotePerecedero IS 'la fecha de almacenaje no puede ser posterior a la fecha actual';
COMMENT ON CONSTRAINT FechaPrep ON AbarrotePerecedero IS 'la fecha de preparación no puede ser posterior a la fecha actual';
COMMENT ON CONSTRAINT Caducidad ON AbarrotePerecedero IS 'la fecha de caducidad no puede ser posterior a la fecha de caducidad';
-- Comentarios de la tabla AbarrotePerecedero
comment on table AbarrotePerecedero is 'Tabla con la información de un producto perecedero';
comment on column AbarrotePerecedero.IDAlmacen is 'Identificador de un producto en el almacén';
comment on column AbarrotePerecedero.IDProducto is 'Identificador del producto perecedero';
comment on column AbarrotePerecedero.FechaAlmacenado is 'La fecha en que se ingresó al almacén.';
comment on column AbarrotePerecedero.FechaPreparacion is 'La fecha en que se preparó el producto perecedero';
comment on column AbarrotePerecedero.Presentacion is 'La presentación en la que viene el producto perecedero';
comment on column AbarrotePerecedero.FechaCaducidad is 'La fecha en la que caduca el producto perecedero';

--Tabla: AbarroteNoPerecedero
CREATE TABLE IF NOT EXISTS AbarroteNoPerecedero
(
	IDAlmacen serial,
    IDProducto int NOT NULL,
	FechaAlmacenado date NOT NULL,
	Presentacion varchar(50) NOT NULL,
	FechaPreparacion date NOT NULL,
    CONSTRAINT pkNoPerecedero PRIMARY KEY (IDAlmacen),
	CONSTRAINT fkNoPerecedero FOREIGN KEY (IDProducto) REFERENCES Producto(IDProducto)
	on update cascade on delete cascade,
	CONSTRAINT FechaAlma check(FechaAlmacenado <= CURRENT_DATE),
	CONSTRAINT FechaPrep check (FechaPreparacion <= CURRENT_DATE)
);
-- Comentarios restricciones en AbarroteNoPerecedero
COMMENT ON CONSTRAINT pkNoPerecedero ON AbarroteNoPerecedero IS 'idalmacen es la llave primara de Abarrote No Perecedero';
COMMENT ON CONSTRAINT fkNoPerecedero ON AbarroteNoPerecedero IS 'idproducto es la llave foranea de la tabla Producto en Abarrote No Perecedero';
COMMENT ON CONSTRAINT FechaAlma ON AbarroteNoPerecedero IS 'la fecha de almacenaje no puede ser posterior a la fecha actual';
COMMENT ON CONSTRAINT FechaPrep ON AbarroteNoPerecedero IS 'la fecha de preparación no puede ser posterior a la fecha actual';
-- Comentarios de la tabla NoPerecedero
comment on table AbarroteNoPerecedero is 'Tabla con la información de un producto no perecedero';
comment on column AbarroteNoPerecedero.IDAlmacen is 'Identificador de un producto en el almacén';
comment on column AbarroteNoPerecedero.IDProducto is 'Identificador del producto no perecedero';
comment on column AbarroteNoPerecedero.FechaAlmacenado is 'La fecha en que se ingresó al almacén.';
comment on column AbarroteNoPerecedero.FechaPreparacion is 'La fecha en que se preparó el producto no perecedero';
comment on column AbarroteNoPerecedero.Presentacion is 'La presentación en la que viene el producto no perecedero';


--Tabla: ElectronicaCons
CREATE TABLE IF NOT EXISTS ElectronicaCons
(
	IDAlmacen serial,
    IDProducto int NOT NULL,
	FechaAlmacenado date NOT NULL,
	ConsumoElectrico int2 NOT NULL,
	Descripcion varchar(200) NOT NULL,
	Categoria varchar(100) NOT NULL,
	CONSTRAINT pkElec PRIMARY KEY (IDAlmacen),
	CONSTRAINT fkElec FOREIGN KEY (IDProducto) REFERENCES Producto(IDProducto)
	on update cascade on delete cascade,
	CONSTRAINT FechaAlma check(FechaAlmacenado <= CURRENT_DATE),
	CONSTRAINT Consumo check (ConsumoElectrico > 0)
);
-- Comentarios restricciones en ElectronicaCons
COMMENT ON CONSTRAINT pkElec ON ElectronicaCons IS 'idalmacen es la llave primara de ElectronicaCons';
COMMENT ON CONSTRAINT fkElec  ON ElectronicaCons IS 'idproducto es la llave foranea de la tabla Producto en ElectronicaCons';
COMMENT ON CONSTRAINT FechaAlma ON ElectronicaCons IS 'la fecha de almacenaje no puede ser posterior a la fecha actual';
COMMENT ON CONSTRAINT Consumo ON ElectronicaCons IS 'El consumo no pueder ser menor a 0';
-- Comentarios de la tabla ElectronicaCons
comment on table ElectronicaCons is 'Tabla donde se almacena los datos de los productos de electronica';
comment on column ElectronicaCons.IDAlmacen is 'Identificador de un producto en el almacén';
comment on column ElectronicaCons.IDProducto is 'Identificador del producto.';
comment on column ElectronicaCons.FechaAlmacenado is 'La fecha en que se ingresó al almacén.';
comment on column ElectronicaCons.Descripcion is 'Descripción breve del producto';
comment on column ElectronicaCons.ConsumoElectrico is 'Cantidad del consumo eléctrico del producto en watts';
comment on column ElectronicaCons.Categoria is 'Categoria a la que pertenece el producto';


--Tabla: Empleado
CREATE TABLE IF NOT EXISTS Empleado
(
	IDEmpleado serial,
	IDSucursal int NOT NULL,
	Puesto varchar(9) NOT NULL,
	Calle varchar(60) NOT NULL,
	NumInterior varchar(25),
    NumExterior varchar(25) NOT NULL,
    CP char(5) NOT NULL,
    Colonia varchar(70) NOT NULL,
    NombreP varchar(25) NOT NULL,
	AMaterno varchar(25) NOT NULL,
	APaterno varchar(25) NOT NULL,
	FechaNac date NOT NULL,
	Estudios varchar(30) NOT NULL,
	RFC char(13) NOT NULL,
	CURP char(18) NOT NULL,
	EstadoCivil varchar(12) NOT NULL,
	Nacionalidad varchar(50) NOT NULL,
	CONSTRAINT pkEmpleado PRIMARY KEY (IDEmpleado),
	CONSTRAINT fkSucursal FOREIGN KEY (IDSucursal) REFERENCES Sucursal(IDSucursal)
	on update cascade on delete cascade,
	CONSTRAINT tipoEmpleado check (Puesto IN ('cajero','gerente','encargado')),
	CONSTRAINT CPEmpleado check(CP not like '%[^0-9]%'),
	CONSTRAINT NacEmpleado check (FechaNac < CURRENT_DATE)
);
-- Comentarios restricciones en Empleado
COMMENT ON CONSTRAINT pkEmpleado ON Empleado IS 'idempleado es la llave primaria de Empleado';
COMMENT ON CONSTRAINT fkSucursal ON Empleado IS 'idsucursal es la llave foranea de Empleado';
COMMENT ON CONSTRAINT tipoEmpleado ON Empleado IS 'El puesto de un empleado pueder ser cajero, gerente y encargado';
COMMENT ON CONSTRAINT CPEMpleado ON Empleado IS 'El código postal de un empleado solo contiene números.';
COMMENT ON CONSTRAINT NacEmpleado ON Empleado IS 'Un Empleado no pueda nacer después posterior a la fecha actual';
-- Comentarios de la tabla Empleado
comment on table Empleado is 'Tabla que contiene la información de los Empleados';
comment on column Empleado.IDEmpleado is 'Identificador del Empleado';
comment on column Empleado.IDSucursal is 'Foreign key que conecta con el IDSucursal';
comment on column Empleado.Puesto is 'Puesto que ocupa el Empleado';
comment on column Empleado.NombreP is 'Nombre de pila del Empleado';
comment on column Empleado.APaterno is 'Apellido paterno del Empleado';
comment on column Empleado.AMaterno is 'Apellido materno del Empleado';
comment on column Empleado.Calle is 'Nombre de la calle donde vive el Empleado';
comment on column Empleado.NumInterior is 'Número del interior de la residencia del empleado';
comment on column Empleado.NumExterior is 'Número de la calle donde vive el Empleado';
comment on column Empleado.CP is 'Código postal de donde vive el Empleado';
comment on column Empleado.Colonia is 'Colonia donde vive el Empleado';
comment on column Empleado.FechaNac is 'Fecha de nacimiento del Empleado';
comment on column Empleado.Estudios is 'Grado de estudios del empleado Empleado';
comment on column Empleado.CURP is 'CURP del Empleado';
comment on column Empleado.RFC is 'RFC del Empleado';
comment on column Empleado.EstadoCivil is 'Estado civil del Empleado';
comment on column Empleado.Nacionalidad is 'Nacionalidad del Empleado';


-- Tabla: Cliente
CREATE TABLE IF NOT EXISTS Cliente
(
    CURP char(18) NOT NULL,
    Calle varchar(60) NOT NULL,
    NumInterior varchar(20),
    NumExterior varchar(25) NOT NULL,
    CP char(5) NOT NULL,
    Colonia varchar(70) NOT NULL,
    NombreP varchar(25) NOT NULL,
    APaterno varchar(25) NOT NULL,
    AMaterno varchar(25) NOT NULL,
    FechaNac date NOT NULL,
    CONSTRAINT pkCURP PRIMARY KEY (CURP),
	CONSTRAINT CP check(CP not like '%[^0-9]%'),
    CONSTRAINT NacCliente check (FechaNac < CURRENT_DATE)  
);
-- Comentarios restricciones en Cliente
COMMENT ON CONSTRAINT pkCURP ON Cliente IS 'curp es la llave primaria de Empleado';
COMMENT ON CONSTRAINT CP ON Cliente IS 'El código postal solo contiene números.';
COMMENT ON CONSTRAINT NacCliente ON Cliente IS 'un cliente no puede nacer posterior a la fecha actual';
-- Comentarios de la tabla Cliente
comment on table Cliente is 'Tabla que contiene la información de los clientes';
comment on column Cliente.CURP is 'Es el CURP del cliente, al igual que su identificador';
comment on column Cliente.NombreP is 'Nombre de pila del cliente';
comment on column Cliente.APaterno is 'Apellido paterno del cliente';
comment on column Cliente.AMaterno is 'Apellido materno del cliente';
comment on column Cliente.Calle is 'Nombre de la calle donde vive el cliente';
comment on column Cliente.NumInterior is 'Número del interior de la vivienda del cliente';
comment on column Cliente.NumExterior is 'Número de la calle donde vive el cliente';
comment on column Cliente.CP is 'Código postal de donde vive el cliente';
comment on column Cliente.Colonia is 'Colonia donde vive el cliente';
comment on column Cliente.FechaNac is 'Fecha de nacimiento del cliente';

-- Tabla: Venta
CREATE TABLE IF NOT EXISTS Venta
(
	IDVenta serial,
	CURP char(18) NOT NULL,
	IDEmpleado int NOT NULL,
	IDSucursal int NOT NULL,
	MetodoPago varchar(40) NOT NULL,
	FechaVenta timestamp NOT NULL,
	CONSTRAINT pkVenta PRIMARY KEY (IDVenta),
	CONSTRAINT fkCliente FOREIGN KEY (CURP) REFERENCES Cliente(CURP)
	on update cascade on delete cascade,
	CONSTRAINT fkEmpleado FOREIGN KEY (IDEmpleado) REFERENCES Empleado(IDEmpleado)
	on update cascade on delete cascade,
	CONSTRAINT fkSucursal FOREIGN KEY (IDSucursal) REFERENCES Sucursal(IDSucursal)
	on update cascade on delete cascade,
	CONSTRAINT FechaVenta check(FechaVenta <= NOW()),
	CONSTRAINT metodoPago check (MetodoPago IN ('efectivo','tarjeta','mercado pago','CODI'))
	
);
-- Comentarios restricciones en Venta
COMMENT ON CONSTRAINT pkVenta ON Venta IS 'idventa es la llave primaria de Venta';
COMMENT ON CONSTRAINT fkCliente ON Venta IS 'curp es la llave foranea proviente de tabla cliente';
COMMENT ON CONSTRAINT fkEmpleado ON Venta IS 'idempleado es la llave foranea proviente de tabla empleado';
COMMENT ON CONSTRAINT fkSucursal ON Venta IS 'idsucursal es la llave foranea proviente de tabla Venta';
COMMENT ON CONSTRAINT FechaVenta ON Venta IS 'una venta no puede ser posterior a la fecha actual';
COMMENT ON CONSTRAINT metodoPago ON Venta IS 'los métodos de pago son: efectivo, tarjeta, mercado pago y CODI';
-- Comentarios de la tabla Venta
COMMENT ON TABLE Venta is 'Tabla que relaciona al cliente, la sucursal, el metodo de pago y al cajero que hace la venta';
COMMENT ON COLUMN Venta.IDVenta is 'El identificador del numero de la venta';
COMMENT ON COLUMN Venta.CURP is 'Foreign key que identifica al cliente que hace la compra';
COMMENT ON COLUMN Venta.IDEmpleado is 'Foreign key que identifica al empleado(cajero) que procesa la venta al cliente';
COMMENT ON COLUMN Venta.IDSucursal is 'Foreign key que identifica en que sucursal se realiza la venta';
COMMENT ON COLUMN Venta.MetodoPago is 'Forma en la que paga el cliente';
COMMENT ON COLUMN Venta.FechaVenta is 'Fecha en que se realizó la venta';

--Tabla: TelefonoCliente
CREATE TABLE IF NOT EXISTS TelefonoCliente
(
	CURP char(18) NOT NULL,
	Telefono varchar(15) NOT NULL,
	CONSTRAINT pkTelCliente PRIMARY KEY (CURP,Telefono),
	CONSTRAINT fkCliente FOREIGN KEY (CURP) REFERENCES Cliente(CURP)
	on update cascade on delete cascade,
	CONSTRAINT tel check(Telefono not like '%[^0-9]%')
);
-- Comentarios restricciones en TelefonoCliente
COMMENT ON CONSTRAINT pkTelCliente ON TelefonoCliente IS 'curp y teléfono son llaves primarias de TelefonoCliente';
COMMENT ON CONSTRAINT fkCliente ON TelefonoCliente IS 'curp es llave foranea proveniente de la tabla Cliente para TelefonoCliente';
COMMENT ON CONSTRAINT tel ON TelefonoCliente IS 'teléfono solo contiene números';
-- Comentarios de la tabla TelefonoCliente 
comment on table TelefonoCliente is 'Tabla con la información de los teléfonos de los clientes';
comment on column TelefonoCliente.CURP is 'Foreign key que conecta con el CURP del cliente';
comment on column TelefonoCliente.Telefono is 'El teléfono del cliente';

--Tabla: EmailCliente 
CREATE TABLE IF NOT EXISTS EmailCliente	
(
	CURP char(18) NOT NULL,
	Email varchar(256) NOT NULL,
	CONSTRAINT pkEmailCliente PRIMARY KEY (CURP,Email),
	CONSTRAINT fkCliente FOREIGN KEY (CURP) REFERENCES Cliente(CURP)
	on update cascade on delete cascade,
	CONSTRAINT correoCliente check (Email like '_%@_%._%')
);
-- Comentarios restricciones en TelefonoCliente
COMMENT ON CONSTRAINT pkEmailCliente ON EmailCliente IS 'curp y email son llaves primarias de EmailCliente';
COMMENT ON CONSTRAINT fkCliente ON EmailCliente IS 'curp es llave foranea proveniente de la tabla Cliente para EmailCliente';
COMMENT ON CONSTRAINT correoCliente ON EmailCliente IS 'un correo contiene el siguiente regex "_%@_%._%" ';
-- Comentarios de la tabla EmailCliente
comment on table EmailCliente is 'Tabla con la información de los correos de los clientes';
comment on column EmailCliente.CURP is 'Foreign key que conecta con el CURP del cliente';
comment on column EmailCliente.Email is 'El correo del cliente';

--Tabla: TelefonoEmpleado
CREATE TABLE IF NOT EXISTS TelefonoEmpleado
(
	IDEmpleado int NOT NULL,
	Telefono varchar(15) NOT NULL,
	CONSTRAINT pkTelEmpleado PRIMARY KEY (IDEmpleado,Telefono),
	CONSTRAINT fkEmpleado FOREIGN KEY (IDEmpleado) REFERENCES Empleado(IDEmpleado)
	on update cascade on delete cascade,
	CONSTRAINT tel check(Telefono not like '%[^0-9]%')
);
-- Comentarios restricciones en TelefonoEmpleado
COMMENT ON CONSTRAINT pkTelEmpleado ON TelefonoEmpleado IS 'curp y teléfono son llaves primarias de TelefonoEmpleado';
COMMENT ON CONSTRAINT fkEmpleado ON TelefonoEmpleado IS 'curp es llave foranea proveniente de la tabla Cliente para TelefonoEmpleado';
COMMENT ON CONSTRAINT tel ON TelefonoEmpleado IS 'teléfono solo contiene números';
-- Comentarios de la tabla TelefonoEmpleado 
comment on table TelefonoEmpleado is 'Tabla con la información de los teléfonos de los Empleados';
comment on column TelefonoEmpleado.IDEmpleado is 'Foreign key que conecta con el IDEmpleado';
comment on column TelefonoEmpleado.Telefono is 'El teléfono del Empleado';


--Tabla: EmailEmpleado
CREATE TABLE IF NOT EXISTS EmailEmpleado
(
	IDEmpleado int NOT NULL,
	Email varchar(256) NOT NULL,
	CONSTRAINT pkEmailEmpleado PRIMARY KEY (IDEmpleado,Email),
	CONSTRAINT fkEmpleado FOREIGN KEY (IDEmpleado) REFERENCES Empleado(IDEmpleado)
	on update cascade on delete cascade,
	CONSTRAINT correoEmpleado check (Email like '_%@_%._%')
);
-- Comentarios restricciones en EmailEmpleado
COMMENT ON CONSTRAINT pkEmailEmpleado ON EmailEmpleado IS 'curp y email son llaves primarias de EmailEmpleado';
COMMENT ON CONSTRAINT fkEmpleado ON EmailEmpleado IS 'curp es llave foranea proveniente de la tabla Cliente para EmailEmpleado';
COMMENT ON CONSTRAINT correoEmpleado ON EmailEmpleado IS 'un correo contiene el siguiente regex "_%@_%._%" ';
-- Comentarios de la tabla EmailEmpleado
comment on table EmailEmpleado is 'Tabla con la información de los emails de los Empleados';
comment on column EmailEmpleado.IDEmpleado is 'Foreign key que conecta con el IDEmpleado';
comment on column EmailEmpleado.Email is 'El email del Empleado';


--Tablad: TelefonoSucursal
CREATE TABLE IF NOT EXISTS TelefonoSucursal
(
	IDSucursal int NOT NULL,
	Telefono varchar(15) NOT NULL,
	CONSTRAINT pkTelSuc PRIMARY KEY (IDSucursal,Telefono),
	CONSTRAINT fkSuc FOREIGN KEY (IDSucursal) REFERENCES Sucursal(IDSucursal)
	on update cascade on delete cascade,
	CONSTRAINT tel check(Telefono not like '%[^0-9]%')
);
-- Comentarios restricciones en TelefonoSucursal
COMMENT ON CONSTRAINT pkTelSuc ON TelefonoSucursal IS 'idsucursal y teléfono son llaves primarias de TelefonoSucursal';
COMMENT ON CONSTRAINT fkSuc ON TelefonoSucursal IS 'idsucursal es llave foranea proveniente de la tabla Sucursal para TelefonoSucursal';
COMMENT ON CONSTRAINT tel ON TelefonoSucursal IS 'teléfono solo contiene números';
-- Comentarios de la tabla TelefonoSucursal
comment on table TelefonoSucursal is 'Tabla con los telefonos de la sucursal';
comment on column TelefonoSucursal.IDSucursal is 'Foreign key que conecta con el IDSucursal';
comment on column TelefonoSucursal.Telefono is 'El telefono de la sucursal';

--RELACIONES COMO TABLAS

--Tabla: TenerProducto
CREATE TABLE IF NOT EXISTS TenerProducto
(
	IDProducto int NOT NULL,
	IDSucursal int NOT NULL,
	StockSucursal int NOT NULL,
	CONSTRAINT pkTenerProducto PRIMARY KEY (IDProducto, IDSucursal),
	CONSTRAINT fkProd FOREIGN KEY (IDProducto) REFERENCES  Producto(IDProducto)
	on update cascade on delete cascade,
	CONSTRAINT fkSuc FOREIGN KEY (IDSucursal) REFERENCES Sucursal(IDSucursal)
	on update cascade on delete cascade,
	CONSTRAINT stock check (StockSucursal >= 0)
);
-- Comentarios restricciones en TenerProducto
COMMENT ON CONSTRAINT pkTenerProducto ON TenerProducto IS 'Llave primaria para garantizar unicidad respecto a una sucursal con un producto';
COMMENT ON CONSTRAINT fkProd ON TenerProducto IS 'idproducto es llave foranea proveniente de la tabla Producto para TenerProducto';
COMMENT ON CONSTRAINT fkSuc ON TenerProducto IS 'idsucursal es llave foranea proveniente de la tabla Sucursal para TenerProducto';
COMMENT ON CONSTRAINT stock ON TenerProducto IS 'el stock debe ser mayor o igual a 0';
-- Comentarios de la tabla TenerProducto
comment on table TenerProducto is 'Tabla que representa la relación entre la sucursal y los productos.';
comment on column TenerProducto.IDProducto is 'Foreign key del producto';
comment on column TenerProducto.IDSucursal is 'Foreign key que identifica a la sucursal';
comment on column TenerProducto.StockSucursal is 'Cantidad del productos que hay en la sucursal';


--Tabla: DesglosarProducto
CREATE TABLE IF NOT EXISTS DesglosarProducto
(
	IDProducto int NOT NULL,
	IDVenta int NOT NULL,
	Cantidad int NOT NULL,
	CONSTRAINT pkdesglosarProducto PRIMARY KEY (IDProducto, IDVenta),
	CONSTRAINT fkProd FOREIGN KEY (IDProducto) REFERENCES Producto(IDProducto)
	on update cascade on delete cascade,
	CONSTRAINT fkVenta FOREIGN KEY (IDVenta) REFERENCES Venta(IDVenta)
	on update cascade on delete cascade,
	CONSTRAINT cant check (Cantidad > 0)
);
-- Comentarios restricciones en DesglosarProducto
COMMENT ON CONSTRAINT pkdesglosarProducto ON DesglosarProducto IS 'Garantiza unicidad para el par (IDProducto, IDVenta)';
COMMENT ON CONSTRAINT fkProd ON DesglosarProducto IS 'idproducto es llave foranea proveniente de la tabla Producto para DesglosarProducto';
COMMENT ON CONSTRAINT fkVenta ON DesglosarProducto IS 'idventa es llave foranea proveniente de la tabla Venta para DesglosarProducto';
COMMENT ON CONSTRAINT cant ON DesglosarProducto IS 'cantidad debe ser mayor a 0';
-- Comentarios de la tabla DesglosarAPerecedero
comment on table DesglosarProducto is 'Tabla que representa la relación entre la venta y los productos';
comment on column DesglosarProducto.IDProducto is 'Foreign key del producto de perecederos';
comment on column DesglosarProducto.IDVenta is 'Foreign key que identifica a la venta';
comment on column DesglosarProducto.Cantidad is 'Cantidad del productos que se venden';
