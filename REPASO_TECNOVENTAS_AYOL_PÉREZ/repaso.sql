use ventas_db;
-- VISTAS PREVIAS
-- 1. Clientes
select * from clientes;

-- 2. Productos
select * from productos;

-- 3. Ventas
select * from ventas;

-- 4. Detalle_ventas
select * from detalle_ventas;

-- CONSULTAS
-- 1. Mostrar todos los productos con stock menor a 20.
select * from productos -- Se muestran todos los campos de la tabla productos
where stock<20; -- Se pone como condicion que solo se muestren aquellos cuyo stock sea menor a 20

-- 2. Listar las ciudades de origen de los clientes sin duplicar.
select ciudad from clientes -- Se selecciona el campo que se mostrar en la tabla y la tabla del que proviene
group by ciudad; -- Se agrupa por ciudad para evitar que se muestren duplicados

-- Otra forma de hacer la pregunta 2
select distinct ciudad -- Se seleccionan valores unicos de (no repetidos) del campo ciudad
from clientes;  -- Se selecciona la tabla de la que seextraeran los datos

-- 3. Mostrar la cantidad total de productos vendidos.
select sum(cantidad) as TOTAL_VENDIDO from detalle_ventas; 
-- Se realiza una suma con de la cantidad de productos vendidos de la tabla detalle_ventas

-- 4. Mostrar los nombres de clientes y la fecha de cada venta.
select c.nombre as CLIENTE, v.fecha as FECHA_VENTA -- Se seleccionan las columnas de las diferentes tablas
from clientes c -- Se establece la tabla principal
join ventas v on c.cliente_id=v.cliente_id; -- Se relaciona los IDs de cliente en ambas tablas

-- SUBCONSULTAS
-- 1. Mostrar los clientes que han comprado más que el promedio general de ventas.
-- forma 1
select c.nombre 
from clientes c
join ventas v on c.cliente_id = v.cliente_id
join detalle_ventas dv on v.venta_id=dv.venta_id
group by c.nombre
having sum(dv.cantidad) > (select avg(cantidad) as PROMEDIO from detalle_ventas);

-- forma 2
select c.nombre
from clientes c
join ventas v on c.cliente_id = v.cliente_id
join detalle_ventas dv on v.venta_id=dv.venta_id
group by c.nombre
having sum(dv.subtotal) > (select avg(subtotal) as SUBTOTOAL from detalle_ventas);

-- 2. Mostrar productos cuyo precio está por encima del promedio de todos los productos.
select nombre, precio from productos -- Se seleccionan las columnas que apareceran en las tablas
-- Filtra solo productos donde el precio es mayor el promedio de precios calculado sobre todos los productos
where precio>(select avg(precio) from productos);

-- 3. Mostrar el cliente con la mayor suma en compras.
select c.nombre as CLIENTE, sum(dv.subtotal) as total_compras -- Se realiza una suma de los subtotales de la tabla detalle_ventas
from ventas v -- Tabla principal
join clientes c on v.cliente_id=c.cliente_id -- Relación con la tabla de clientes
join detalle_ventas dv on v.venta_id = dv.venta_id -- Relación con el detalle de ventas
group by c.cliente_id -- Agrupación por ID de cliente
order by total_compras desc limit 1; -- Ordena de mayor a menor monto comprado

-- 4. Mostrar nombres de productos que aparecen en más de una venta.
select p.nombre, count(distinct dv.venta_id) as VENTA_TOTAL -- Se cuentan las ventas unicas 
from productos p
join detalle_ventas dv on p.producto_id=dv.producto_id -- Se obtienen solo productos que tienen registros en detalle_ventas
group by p.producto_id -- Agrupa por ID de producto
having count(distinct dv.venta_id)>1; -- Filtra para mostrar solo productos con más de una venta


-- JOINS
-- 1. INNER JOIN entre clientes y ventas
select c.nombre as CLIENTES, v.venta_id -- Se seleccionan las columnas que apareceran en las tablas
from clientes c -- Tabla principal
join ventas v on c.cliente_id = v.cliente_id; -- Relacion a traves de los ids


-- 2. JOIN entre ventas y detalle_ventas
select v.venta_id, v.fecha, dv.cantidad, dv.subtotal -- Se seleccionan las columnas que apareceran en las tablas
from ventas v -- Tabla principal
join detalle_ventas dv on v.venta_id=dv.venta_id; -- Relacion a traves de los ids


-- 3. JOIN entre detalle_ventas y productos
select dv.detalle_id, p.nombre as producto , dv.cantidad,  p.precio, p.stock -- Se seleccionan las columnas que apareceran en las tablas
from detalle_ventas dv -- Tabla principal
join productos p on dv.producto_id = p.producto_id; -- Relacion a traves de los ids


-- 4. JOIN entre las 4 tablas
select c.nombre as CLIENTE, c.ciudad, 
v.venta_id, v.fecha, p.nombre as PRODUCTO, dv.cantidad, p.stock -- Se seleccionan las columnas que apareceran en las tablas
from clientes c -- Tabla principal
join ventas v on c.cliente_id = v.cliente_id -- Relacion entre ventas y clientes
join detalle_ventas dv on v.venta_id = dv.venta_id -- Relacion entre detalle_ventas y ventas
join productos p on dv.producto_id = p.producto_id; -- Relacion entre productos y detalle_ventas


-- 5. LEFT JOIN para mostrar clientes sin ventas
-- Primera forma
select c.nombre as CLIENTE, v.venta_id, v.fecha as FECHA_VENTA -- Columnas que apareceran en la tabla
from clientes c -- Tabla izquierda de la que se mostrara todos los registros
left join ventas v on c.cliente_id = v.cliente_id; -- Relacion entre ventas y clientes

-- Segunda forma
select c.nombre as CLIENTE, v.venta_id, v.fecha as FECHA_VENTA -- Columnas que apareceran en la tabla
from clientes c -- Tabla izquierda de la que se mostrara todos los registros
left join ventas v on c.cliente_id = v.cliente_id -- Relacion entre ventas y clientes
where v.venta_id is null; -- Se establece que solo se muestren aquellos clientes que no tienen registros correspondientes en la tabla ventas 


-- 6. RIGHT JOIN entre ventas y detalle_ventas
select v.venta_id, v.fecha as fecha_venta, dv.cantidad, dv.subtotal
from detalle_ventas dv -- Tabla secundaria 'dv' de la cual se moestrarn solo las coinicdencias y si no hay coincidencias se llenara con null
-- Tabla principal 'ventas' de la cual se mostraran todos los registros
right join ventas v on dv.venta_id=v.venta_id; -- Relacion entre ventas y detalle_ventas


-- 7. JOIN para mostrar total vendido por producto
select p.nombre as PRODUCTO, p.producto_id, 
sum(dv.cantidad) as TOTAL_VENDIDO -- Suma la cantidad vendida de productos
from productos p -- Tabla principal
join detalle_ventas dv on p.producto_id = dv.producto_id -- Relacion entre la tabla detalle_ventas y productos
group by p.nombre, p.producto_id; -- Se agrupan los prodcutos por su nombre e id



-- 8. JOIN para ventas con fecha específica
-- Mostrar los clientes que compraron en '2024-03-22'
select c.nombre as CLIENTE, v.fecha as FECHA_COMPRA -- Columnas que apareceran en la tabla
from clientes c -- Tabla principal
join ventas v on c.cliente_id=v.cliente_id -- Relacion entre la tabla ventas y clientes
where v.fecha='2024-03-22'; -- Se filtra para que solo aparezcan los clientes que realizaron una compra en 2024-03-22


-- Transacciones (4)
-- 1. Venta válida con COMMIT.
start transaction; -- Se inicia una transaccion
update ventas set total=30 where venta_id=1; -- Se actualiza el total de la venta cuyo id es 1
commit; -- Para hacer los cambios permanentes en la base de datos


-- 2. Error de stock, aplicar ROLLBACK.
 start transaction; -- Se inicia una transaccion
 update productos set stock= stock - 100 where producto_id=1; -- Se actualiza el stock del producto cuyo id es 1
 rollback; -- Se revierte todo de forma intencional
 
 
 -- 3. Venta eliminando producto con COMMIT (irreversible).
start transaction; -- Se inicia una transaccion 
insert into detalle_ventas(detalle_id, venta_id, producto_id, cantidad, subtotal) 
values (3000, 99, 94, 99, 100.50); -- Se agrega un nuevo registro en detalle_ventas
-- Se elimina de forma irreversible el producto
delete from detalle_ventas where producto_id=94;
delete from productos where producto_id=94;
commit;


-- 4. Uso de SAVEPOINT y ROLLBACK parcial.
start transaction;
insert into clientes(cliente_id, nombre, correo, ciudad) -- Se inserta un nuevo cliente
values (201, 'Liam Vega', 'liam@gmail.com', 'Quito'); 
savepoint insertar_cliente; -- Se guarda un punto de recuperacion 
update productos set stock = stock - 100 where producto_id = 1; -- Se intenta restar 100 del stock del producto cuyo id es 1
rollback to savepoint insertar_cliente; -- Se revierten los cambios hasta el punto de recuperacion
commit; -- Se confirman los cambios realizados hasta el punto de recuperacion


-- PROBLEMAS CON VISTAS
-- 1. Crear vista vista_detalle_clientes con cliente, producto, cantidad y total.
-- Como nos pide que en la vista pongamos el total, y anteriormente el total ya lo calculamos, pero no es una columna hacemos:
-- crear una vista del total vendido para luego poder indicarlo en la vista_detalle_clientes

create view vista_total_vendido as
select p.nombre as PRODUCTO, p.producto_id, 
sum(dv.cantidad) as TOTAL_VENDIDO -- Suma la cantidad vendida de productos
from productos p -- Tabla principal
join detalle_ventas dv on p.producto_id = dv.producto_id -- Relacion entre la tabla detalle_ventas y productos
group by p.nombre, p.producto_id;

-- Con lo anterior ya podemos realizar vista_detalle_cliente
create view vista_detalle_clientes as
select c.nombre  as NOMBRE, p.nombre as PRODUCTO, dv.cantidad as CANTIDAD, vtv.TOTAL_VENDIDO as TOTAL
from clientes c -- indicar primero la tabla de clientes
join ventas v on c.cliente_id=v.cliente_id
join detalle_ventas dv on v.venta_id= dv.venta_id
join productos p on dv.producto_id= p.producto_id
join vista_total_vendido vtv on p.producto_id= vtv.producto_id; -- hacemos un join con la vista que anterirormente creamos, para evitar repetir procesos

-- 2. Crear vista vista_stock_critico para productos con stock < 15.
create view vista_stock_critico as
select nombre,stock from productos
where stock<15;

-- PROBLEMAS CON TRANSACCIONES
-- 1. Compra múltiple con dos productos (usar COMMIT).
-- iniciamos la transacción de una compra múltiple
start transaction;

-- Registrar una nueva venta
INSERT INTO clientes (nombre, correo, ciudad)
VALUES 
  ('Juan Torres', 'juan@gmail.com', 'Quito'),
  ('José Palacios', 'jose@gmail.com', 'Guayaquil');
  -- confirmar la transaccion 
  commit;
  

-- 2. Venta con total mal ingresado, aplicar ROLLBACK.
-- Insertar venta con total incorrecto (ejemplo)
start transaction;
insert into ventas (cliente_id, fecha, total)
values (1, CURDATE(), 9999.99);  -- total incorrecto

-- Insertar detalles de venta (subtotal no suma 9999.99)
insert into detalle_ventas (venta_id, producto_id, cantidad, subtotal)values
  (LAST_INSERT_ID(), 1, 2, 30.00),  
  (LAST_INSERT_ID(), 2, 1, 15.00);  
  
ROLLBACK;


-- CREACIÓN DE USUARIOS
-- 1. Usuario 1: administrador (admin_tventas)
create user 'admin_tventas'@'localhost' identified by '1234';
grant all privileges on ventas_db to 'admin_tventas'@'localhost';
flush privileges;

-- 2. Usuario 2: consulta (consulta)
create user 'consulta'@'localhost' identified by '2345';
grant select on ventas_db to 'consulta'@'localhost';
flush privileges;

use ventas_db;
-- ACTIVIDADES SUGERIDAS
-- 1. Vista de productos más vendidos.
create view vista_productos_mas_vendidos as -- creamos la vista
select p.nombre as PRODUCTO, sum(dv.cantidad) as TOTAL_VENDIDO -- seleccionamos los campos y como los vamoa a llamar
from productos p-- visualizaremos primero la tabla productos
join detalle_ventas dv on p.producto_id=dv.producto_id -- realizamos la relación entre las tablas
group by p.producto_id,p.nombre -- agrupamos 
order by TOTAL_VENDIDO desc; -- ordenamos de manera descendente 
-- Después de creada la vista, solo visualizaremos los 5 productos más vendidos
select * from vista_productos_mas_vendidos
limit 5;

-- 2. Subconsulta para producto más costoso.
select nombre, precio from productos
where precio=(select max(precio) from productos);

-- 3. Transacción fallida por stock insuficiente.
select p.nombre, dv.cantidad, p.stock
from productos p
join detalle_ventas dv on p.producto_id = dv.producto_id
where dv.cantidad > p.stock;

-- 4. JOIN completo: cliente, producto, subtotal y fecha.
select c.nombre as CLIENTE, p.nombre as PRODUCTO, dv.subtotal as SUBTOTAL, v.fecha as FECHA
from clientes c
join ventas v on c.cliente_id=v.cliente_id
join detalle_ventas dv on v.venta_id= dv.venta_id
join productos p on dv.producto_id= p.producto_id;