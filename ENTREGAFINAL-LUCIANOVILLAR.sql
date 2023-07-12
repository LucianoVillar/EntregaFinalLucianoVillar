# Paso 1 Creacion de Base y tablas
create schema lifegame;
use lifegame;

#CREACION DE LAS TABLAS
create table Pais( 
id_pais INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
nombre VARCHAR(50) 
);  

create table categoria( 
id_categoria INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
nombre VARCHAR(50) 
); 

create table usuario( 
id_usuario INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
nombre VARCHAR(50) NOT NULL, 
documento VARCHAR(15) NOT NULL, 
birthdate DATE NOT NULL, 
id_pais INT NOT NULL, 
direccion VARCHAR(50), 
mail VARCHAR(50), 
telefono INT, 
FOREIGN KEY fk_id_pais(id_pais) REFERENCES pais(id_pais)
);

create table empresa( 
id_empresa INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
nombre VARCHAR(50) NOT NULL, 
id_pais INT NOT NULL, 
FOREIGN KEY fk_id_pais(id_pais)REFERENCES pais(id_pais) 
); 

create table juego( 
id_juego INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
nombre VARCHAR(50) NOT NULL,
id_empresa INT NOT NULL, 
fecha DATE, 
id_categoria INT NOT NULL, 
descripcion VARCHAR(250), 

FOREIGN KEY fk_id_empresa(id_empresa)REFERENCES empresa(id_empresa), 
FOREIGN KEY fk_id_categoria(id_categoria)REFERENCES categoria(id_categoria) 
); 

create table valoracion( 
id_reseña INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
id_juego INT NOT NULL, 
valoracion INT NOT NULL, 
reseña VARCHAR(250), 
id_usuario INT NOT NULL, 
FOREIGN KEY fk_id_juego(id_juego)REFERENCES juego(id_juego), 
FOREIGN KEY fk_id_usuario(id_usuario)REFERENCES usuario(id_usuario) 
); 

create table compra( 
id_compra INT NOT NULL AUTO_INCREMENT PRIMARY KEY, 
id_usuario INT NOT NULL, 
id_juego INT NOT NULL, 
monto DECIMAL(6,2), 
FOREIGN KEY fk_id_usuario (id_usuario)REFERENCES usuario(id_usuario), 
FOREIGN KEY fk_id_juego(id_juego)REFERENCES juego(id_juego) 
);





# Paso 2 / Inserccion de datos mediante archivos CSV

select * from lifegame.categoria;
select * from lifegame.pais;
select * from lifegame.usuario;
select * from lifegame.empresa;
select * from lifegame.juego;
select * from lifegame.valoracion;
select * from lifegame.compra;





#Paso 3 / Creacion de obejtos

#CREACION DE VISTAS
CREATE VIEW contacto_usuarios as select usuario.nombre,usuario.mail, usuario.telefono from usuario;
CREATE VIEW descripcion as select juego.nombre, juego.descripcion from juego;
CREATE VIEW Uruguay as select * from usuario where id_pais = 1;
CREATE or replace VIEW juegos_USA as select juego.nombre as juego, juego.descripcion, empresa.nombre from juego inner join empresa on juego.id_empresa = empresa.id_empresa where empresa.id_pais = 5;
CREATE or replace VIEW notFreeBuy as select usuario.nombre, compra.id_compra, compra.id_juego,compra.monto from usuario inner join compra on usuario.id_usuario = compra.id_usuario where monto != 0;
  
#CREACION DE FUNCIONES
delimiter $$
CREATE DEFINER=`root`@`localhost` FUNCTION `CalcularSumaTotalVentas`() RETURNS decimal(10,2)
    READS SQL DATA
BEGIN
    DECLARE TotalVentas DECIMAL(10,2);
    SELECT SUM(monto) INTO TotalVentas FROM compra;
    RETURN TotalVentas;
END
$$

delimiter $$
CREATE DEFINER=`root`@`localhost` FUNCTION `AvgValoraciones`() RETURNS int
    READS SQL DATA
BEGIN
	Declare resultado int;
    select avg(valoracion)into resultado from lifegame.valoracion;
	RETURN resultado;
END
$$

#CREACION DE STOREDPROCEDURES
Delimiter $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `lanzamiento_juego`()
BEGIN
Select nombre, fecha 
from lifegame.juego;
END

$$
DELIMITER $$
CREATE DEFINER=`root`@`localhost`PROCEDURE InsertarUsuario(
    IN p_nombre VARCHAR(50),
    IN p_documento VARCHAR(15),
    IN p_birthdate DATE,
    IN p_id_pais INT,
    IN p_direccion VARCHAR(50),
    IN p_mail VARCHAR(50),
    IN p_telefono INT
)
BEGIN
    INSERT INTO lifegame.usuario (nombre, documento, birthdate, id_pais, direccion, mail, telefono)
    VALUES (p_nombre, p_documento, p_birthdate, p_id_pais, p_direccion, p_mail, p_telefono);
END
$$DELIMITER ;
 
#CREACION DE TRIGGERS
DELIMITER //
CREATE TABLE nuevosJuegos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(250)
);
CREATE TRIGGER insertar_nuevo_juego
AFTER INSERT ON juego
FOR EACH ROW
BEGIN
    INSERT INTO nuevosJuegos (nombre, descripcion)
    VALUES (NEW.nombre, NEW.descripcion);
END 
//DELIMITER ;

CREATE TABLE registro_compras (
id int primary key auto_increment,
comprador int,
juego int,
fecha datetime
);

DELIMITER //
CREATE TRIGGER informacion_compra
AFTER INSERT ON compra
FOR EACH ROW
BEGIN
    INSERT INTO registro_compras(comprador, juego)
    VALUES (NEW.id_usuario, NEW.id_juego);
END 
//DELIMITER 

DELIMITER //
CREATE TRIGGER setear_fecha_registro
BEFORE INSERT ON registro_compras
FOR EACH ROW
BEGIN
    SET NEW.fecha = NOW();
END 
//DELIMITER ;

-- Vistas
select * from lifegame.contacto_usuarios;
select * from lifegame.descripcion;
Select * from lifegame.Uruguay;
select * FROM juegos_usa;
select * from lifegame.notfreebuy;

-- Funciones
Select CalcularSumaTotalVentas();
Select AvgValoraciones();

-- Stored Procedures 
CALL lanzamiento_juego(); 
CALL InsertarUsuario('John Doe', '123456789', '1990-01-01', 5, '123 Main St', 'john@example.com', 123456789);

-- Triggers
-- Para poder ver el efecto de los triggers, realizo consulta sobre las tablas que son utilizadas en cada caso
SELECT * FROM nuevosJuegos;
select * from registro_compras;

-- Inserccion de datos
INSERT INTO pais(id_pais, nombre) values (19,'El Salvador'),(20,'Cuba'),(21,'Venezuela');
INSERT INTO usuario(id_usuario, nombre, documento, birthdate, id_pais, direccion, mail,telefono) values (4,'Matheus','45098762','1997-06-24',6,'Rio de janeiro 198','Math@gmail.com',53246780);
INSERT INTO empresa(id_empresa,nombre,id_pais)values(11,'FromSoftware',8);
INSERT INTO juego (id_juego, nombre,id_empresa, fecha,id_categoria, descripcion) VALUES (8,'DAY OF DEFEEAT:SOURCE',1,'2010-07-12',3,'Day of Defeat te ofrece la acción en línea más trepidante, ambientada en la Europa de la Segunda Guerra Mundial.');
insert into juego (id_juego, nombre,id_empresa, fecha,id_categoria, descripcion) VALUES (13,'ELDEN RING',11,'2022-02-24',8,'EL NUEVO JUEGO DE ROL Y ACCIÓN DE AMBIENTACIÓN FANTÁSTICA. Álzate, Sinluz, y que la gracia te guíe para abrazar el poder del Círculo de Elden y encumbrarte como señor del Círculo en las Tierras Intermedias.');
insert into valoracion(id_reseña,id_juego,valoracion,reseña,id_usuario) values(19,8,5,'Juego que no conocia, pero me volo la cabeza',11);
insert INTO compra(id_compra, id_usuario, id_juego, monto)values(9,4,8,685.00);
insert INTO compra(id_compra, id_usuario, id_juego, monto)values(10,2,4,0.00);

-- Consultas para observar tablas
select * from lifegame.categoria;
select * from lifegame.pais;
select * from lifegame.usuario;
select * from lifegame.empresa;
select * from lifegame.juego;
select * from lifegame.valoracion;
select * from lifegame.compra;

-- informe
-- informe de valoraciones promedio por categoría de juego.
SELECT c.nombre AS categoria, AVG(v.valoracion) AS promedio_valoracion
FROM juego j
JOIN categoria c ON j.id_categoria = c.id_categoria
JOIN valoracion v ON j.id_juego = v.id_juego
GROUP BY c.nombre;

-- informe de ventas de juegos por país
SELECT p.nombre AS pais, COUNT(c.id_compra) AS total_ventas
FROM pais p
JOIN usuario u ON p.id_pais = u.id_pais
JOIN compra c ON u.id_usuario = c.id_usuario
GROUP BY p.nombre;

-- informe de cantidad de usuarios por pais
SELECT p.nombre AS pais, COUNT(u.id_usuario) AS total_usuarios
FROM pais p
JOIN usuario u ON p.id_pais = u.id_pais
GROUP BY p.nombre;


 