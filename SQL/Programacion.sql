-- Procedimiento para crear una venta, ya con sus productos asociados. La fecha de la venta es la fecha de cuando se llama la función. 
-- @param ingresa_CURP, CURP del cliente que hace la compra.
-- @param ingresa_IDEmpleado, ID del empleado que hace la venta
-- @param ingresa_IDSucursal, ID de la sucursal donde se realiza la compra
-- @param ingresa_MetodoPago, metodo de pago que usa el cliente.
-- @param ingresa_ProductosCantidad, una arreglo de arreglos, donde cada entrada del arreglo tiene formato [IDProducto, cantidad].
create or replace procedure crear_venta( 
    ingresa_CURP CHAR(18),
    ingresa_IDEmpleado INT,
    ingresa_IDSucursal INT,
    ingresa_MetodoPago VARCHAR(40),
    ingresa_ProductosCantidad INT[][]
)
AS $$
DECLARE
    v_IDVenta INT;
    v_ProductoCantidad RECORD;
BEGIN
	-- Verificamos que la sucursal exista
    IF NOT EXISTS (SELECT 1 FROM Sucursal WHERE IDSucursal = ingresa_IDSucursal) THEN
        RAISE EXCEPTION 'La sucursal con ID % no existe en la tabla Sucursal', ingresa_IDScursal;
    END IF;
    
     IF NOT EXISTS (SELECT 1 FROM Empleado WHERE IDEmpleado = ingresa_IDEmpleado) THEN
        RAISE EXCEPTION 'El empleado con ID % no existe en la tabla Empleado', ingresa_IDEmpleado;
    END IF;
    
    -- Insertar datos en la tabla Venta
    INSERT INTO Venta (CURP, IDEmpleado, IDSucursal, MetodoPago, FechaVenta)
    VALUES (ingresa_CURP, ingresa_IDEmpleado, ingresa_IDSucursal, ingresa_MetodoPago, GETDATE())
    RETURNING IDVenta INTO v_IDVenta; -- Capturar el IDVenta generado
	
    -- Insertar datos en la tabla DesglosarProducto
    FOREACH v_ProductoCantidad IN ARRAY ingresa_ProductosCantidad
    LOOP
        -- Verificar si el IDProducto existe en la tabla Producto
        IF v_ProductoCantidad[1] NOT IN (SELECT IDProducto FROM Producto) THEN
            -- El IDProducto no existe en la tabla Producto
            RAISE EXCEPTION 'El producto con IDProducto % no existe en la tabla Producto', v_ProductoCantidad[1];
        
        -- Verificar si la cantidad es un valor negativo
        ELSIF v_ProductoCantidad[2] <= 0 THEN
            RAISE EXCEPTION 'En arreglo % ingresa un valor mayor a 0 para la cantidad.', v_ProductoCantidad;
            
        END IF;
        
        INSERT INTO DesglosarProducto (IDProducto, IDVenta, Cantidad)
        VALUES (v_ProductoCantidad[1], v_IDVenta, v_ProductoCantidad[2]);
        
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Disparador que evita que se ingresen dos productos con el mismo ID relacionados a una venta en la tabla DesglosarProducto
CREATE OR REPLACE FUNCTION verificarDesglosarProducto()
RETURNS TRIGGER
AS $$
BEGIN

    IF EXISTS (
        SELECT 1
        FROM DesglosarProducto
        WHERE IDProducto = NEW.IDProducto AND IDVenta = NEW.IDVenta
    ) THEN
        RAISE EXCEPTION 'No se permite ingresar o actualizar una venta con dos o más productos con el mismo 
        ID, intenta aumentar la cantidad del producto en su lugar.';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_VerificarDesglosarProducto
BEFORE INSERT OR UPDATE ON DesglosarProducto
FOR EACH ROW
EXECUTE PROCEDURE verificarDesglosarProducto();


-- Procedimiento para asociar más productos a una venta.
-- @param ingresa_IDVenta, ID de la venta a la que se le agregarán productos.
-- @param ingresa_ProductosCantidad, una arreglo de arreglos, donde cada entrada del arreglo tiene formato [IDProducto, cantidad].
CREATE OR REPLACE PROCEDURE agregarProductoDesglosarVenta(
    ingresa_IDVenta INT, 
    ingresa_ProductosCantidad INTEGER[][]
)
AS $$
DECLARE
    v_ProductoCantidad RECORD;
BEGIN
    -- Verificar si el ID de la venta existe en la tabla Venta
    IF NOT EXISTS (SELECT 1 FROM Venta WHERE IDVenta = ingresa_IDVenta) THEN
        RAISE EXCEPTION 'La venta con IDVenta % no existe en la tabla Venta', ingresa_IDVenta;
    END IF;
    
    -- Recorrer el array de productos y cantidades
    FOREACH v_ProductoCantidad IN ARRAY p_ProductosCantidad
    LOOP
        -- Verificar si el producto existe en la tabla Producto
        IF (SELECT COUNT(*) FROM Producto WHERE IDProducto = v_ProductoCantidad[1]) = 0 THEN
            RAISE EXCEPTION 'El producto con IDProducto % no existe en la tabla Producto', v_ProductoCantidad[1];
            
        -- Verificar si la cantidad es positiva
        ELSIF v_ProductoCantidad[2] <= 0 THEN
            RAISE EXCEPTION 'La cantidad del producto con IDProducto % debe ser mayor a cero', v_ProductoCantidad[1];
            
        END IF;
        
        -- Insertar el producto y cantidad en DesglosarVenta
        INSERT INTO DesglosarVenta (IDVenta, IDProducto, Cantidad)
        VALUES (ingresa_IDVenta, v_ProductoCantidad[1], v_ProductoCantidad[2]);
        
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Procedimiento para modificar la cantidad de un producto en una venta.
-- @param ingresa_IDVenta, ID de la venta a la que le modificaremos la cantidad de un producto.
-- @param ingresa_IDProducto, ID del producto que le modificaremos su cantidad. 
-- @param ingresa_Cantidad, cantidad nueva. 
CREATE OR REPLACE PROCEDURE modificarCantidadDesglosarVenta(
    ingresa_IDVenta INT, 
    ingresa_IDProducto INT, 
    ingresa_Cantidad INT
)
AS $$
BEGIN
    -- Verificar si la venta existe en la tabla Venta
    IF ingresa_IDVenta NOT IN (SELECT IDVenta FROM Venta) THEN
        RAISE EXCEPTION 'La venta con IDVenta % no existe en la tabla Venta', ingresa_IDVenta;
    
    -- Verificar si el producto existe en la tabla Producto
    ELSIF ingresa_IDProducto NOT IN (SELECT IDProducto FROM Producto) THEN
        RAISE EXCEPTION 'El producto con IDProducto % no existe en la tabla Producto', ingresa_IDProducto;
    
    -- Verificar si la cantidad es mayor o igual a cero
    ELSIF ingresa_Cantidad <= 0 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor a cero';
        
    END IF;
    
     -- Actualizar la cantidad del producto en DesglosarVenta
    UPDATE DesglosarVenta
    SET Cantidad = ingresa_Cantidad
    WHERE IDVenta = ingresa_IDVenta AND IDProducto = ingresa_IDProducto;
END;
$$ LANGUAGE plpgsql;


-- Procedimiento para eliminar un producto de la tabla DesglosarProducto. 
-- @param ingresa_IDVenta, ID de la venta a la que le eliminaremos un producto.
-- @param ingresa_IDProducto, ID del producto a eliminar de la tabla DesglosarProducto.
CREATE OR REPLACE PROCEDURE eliminarProductoDesglosarVenta(
    ingresa_IDVenta INT, 
    ingresa_IDProducto INT
)
AS $$
BEGIN
    -- Verificar si la venta existe en la tabla Venta
    IF NOT EXISTS (SELECT 1 FROM Venta WHERE IDVenta = ingresa_IDVenta) THEN
        RAISE EXCEPTION 'La venta con IDVenta % no existe en la tabla Venta', p_IDVenta;
    END IF;
    
    -- Verificar si el producto existe en la tabla Producto
    IF NOT EXISTS (SELECT 1 FROM Producto WHERE IDProducto = ingresa_IDProducto) THEN
        RAISE EXCEPTION 'El producto con IDProducto % no existe en la tabla Producto', p_IDProducto;
    END IF;
    
    -- Eliminar el registro del producto en DesglosarVenta
    DELETE FROM DesglosarVenta WHERE IDVenta = ingresa_IDVenta AND IDProducto = ingresa_IDProducto;
    
    -- Verificar si quedan productos con el ID de venta en DesglosarVenta y eliminar la venta si no quedan.
    IF NOT EXISTS (SELECT 1 FROM DesglosarVenta WHERE IDVenta = ingresa_IDVenta) THEN
        DELETE FROM Venta WHERE IDVenta = p_IDVenta;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Disparador que verifica que la venta la hace un cajero o un gerente. 
CREATE OR REPLACE FUNCTION validarPuestoEmpleado()
RETURNS TRIGGER AS $$
DECLARE
    v_Puesto VARCHAR(10);
BEGIN
    -- Verificar el puesto del empleado asociado a la venta
    SELECT Puesto INTO v_Puesto FROM Empleado WHERE IDEmpleado = NEW.IDEmpleado;

    -- Verificar si el puesto del empleado no es 'cajero' o 'gerente'
    IF v_Puesto NOT IN ('cajero', 'gerente') THEN
        RAISE EXCEPTION 'Las ventas solo pueden ser realizadas por cajeros o gerentes.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el disparador en la tabla Venta
CREATE TRIGGER trigger_ValidarPuestoEmp_EnVenta
BEFORE INSERT OR UPDATE ON Venta
FOR EACH ROW
EXECUTE PROCEDURE validarPuestoEmpleado();


-- Trigger que evita ingresar un producto a la tabla AbarrotePerecedero si el ID del producto ya está en otro departamento. 
CREATE OR REPLACE FUNCTION verificarProductoDepartamento_AbarrotePerecedero()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM AbarroteNoPerecedero
        WHERE IDProducto = NEW.IDProducto
    ) THEN
        RAISE EXCEPTION 'El producto ya está asociado al departamento de Abarrotes no Perecederos';
    ELSIF EXISTS (
        SELECT 1
        FROM ElectronicaCons
        WHERE IDProducto = NEW.IDProducto
    ) THEN
        RAISE EXCEPTION 'El producto ya está asociado al departamento de Electronica de Consumo';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_VerificarProductoDepartamento_AbarrotePerecedero
BEFORE INSERT OR UPDATE ON AbarrotePerecedero
FOR EACH ROW
EXECUTE PROCEDURE verificarProductoDepartamento_AbarrotePerecedero();

-- Trigger que evita ingresar un producto a la tabla AbarroteNoPerecedero si el ID del producto ya está en otro departamento. 
CREATE OR REPLACE FUNCTION verificarProductoDepartamento_AbarroteNoPerecedero()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM AbarrotePerecedero
        WHERE IDProducto = NEW.IDProducto
    ) THEN
        RAISE EXCEPTION 'El producto ya está asociado al departamento de Abarrotes Perecederos';
    ELSIF EXISTS (
        SELECT 1
        FROM ElectronicaCons
        WHERE IDProducto = NEW.IDProducto
    ) THEN
        RAISE EXCEPTION 'El producto ya está asociado al departamento de Electronica de Consumo';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_VerificarProductoDepartamento_AbarroteNoPerecedero
BEFORE INSERT OR UPDATE ON AbarroteNoPerecedero
FOR EACH ROW
EXECUTE FUNCTION verificarProductoDepartamento_AbarroteNoPerecedero();


-- Trigger que evita ingresar un producto a la tabla ElectronicaCons si el ID del producto ya está en otro departamento. 
CREATE OR REPLACE FUNCTION verificarProductoDepartamento_ElectronicaCons()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM AbarrotePerecedero
        WHERE IDProducto = NEW.IDProducto
    ) THEN
        RAISE EXCEPTION 'El producto ya está asociado al departamento de Abarrotes Perecederos';
    ELSIF EXISTS (
        SELECT 1
        FROM AbarroteNoPerecedero
        WHERE IDProducto = NEW.IDProducto
    ) THEN
        RAISE EXCEPTION 'El producto ya está asociado al departamento de Abarrotes no Perecederos';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_VerificarProductoDepartamento_ElectronicaCons
BEFORE INSERT OR UPDATE ON ElectronicaCons
FOR EACH ROW
EXECUTE FUNCTION verificarProductoDepartamento_ElectronicaCons();


-- Trigger que actualiza la cantidad del stock de una sucursal cada que se hace una operación de DML en DesglosarProducto. 
CREATE OR REPLACE FUNCTION actualizarStock()
RETURNS TRIGGER AS $$
DECLARE
    id_producto INT;
    cantidad_vendida INT;
    id_sucursal INT;
BEGIN
    -- Obtener la cantidad de productos vendidos o devueltos
    IF TG_OP = 'INSERT' THEN
        id_producto := NEW.IDProducto;
        cantidad_vendida := NEW.Cantidad;
        id_sucursal := (SELECT IDSucursal FROM Venta WHERE IDVenta = NEW.IDVenta);
    ELSIF TG_OP = 'UPDATE' THEN
        id_producto := NEW.IDProducto;
        cantidad_vendida := NEW.Cantidad - OLD.Cantidad;
        id_sucursal := (SELECT IDSucursal FROM Venta WHERE IDVenta = NEW.IDVenta);
    ELSIF TG_OP = 'DELETE' THEN
        id_producto := OLD.IDProducto;
        cantidad_vendida := - OLD.Cantidad;
        id_sucursal := (SELECT IDSucursal FROM Venta WHERE IDVenta = OLD.IDVenta);
    END IF;
    
    -- Verificar si hay suficiente stock en la sucursal
    IF cantidad_vendida > (SELECT StockSucursal FROM TenerProducto WHERE IDProducto = id_producto AND IDSucursal = id_sucursal) THEN
        RAISE EXCEPTION 'No hay suficientes productos en el stock de esta sucursal para realizar esta venta.';
    ELSE
        -- Actualizar el stock en TenerProducto
        UPDATE TenerProducto
        SET StockSucursal = StockSucursal - cantidad_vendida
        WHERE IDProducto = id_producto AND IDSucursal = id_sucursal;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger para insertar y actualizar
CREATE TRIGGER trigger_ActualizarStock
BEFORE INSERT OR UPDATE ON DesglosarProducto
FOR EACH ROW
EXECUTE PROCEDURE actualizarStock();

-- Crear el trigger para eliminar
CREATE TRIGGER trigger_RestaurarStock
AFTER DELETE ON DesglosarProducto
FOR EACH ROW
EXECUTE PROCEDURE actualizarStock();
