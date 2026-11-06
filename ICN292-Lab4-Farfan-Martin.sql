-- ICN-292 | Laboratorio 4 | Austral Editores | MySQL 8
-- Ejecutar el archivo completo, desde la primera línea, en MySQL Workbench.
DROP DATABASE IF EXISTS austral;
CREATE DATABASE austral CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE austral;

CREATE TABLE autores (
 id_autor INT AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(80) NOT NULL,
 pais VARCHAR(60) NULL,
 genero ENUM('Cómic','Ensayo','Infantil','Novela','Poesía') NOT NULL
);
CREATE TABLE colecciones (
 id_coleccion INT AUTO_INCREMENT PRIMARY KEY,
 titulo VARCHAR(120) NOT NULL,
 fecha_publicacion DATE
);
CREATE TABLE libros (
 id_libro INT AUTO_INCREMENT PRIMARY KEY,
 id_autor INT NOT NULL,
 id_coleccion INT NULL,
 titulo VARCHAR(120) NOT NULL,
 paginas INT,
 ejemplares_vendidos INT,
 anio INT,
 CONSTRAINT fk_libros_autores FOREIGN KEY (id_autor) REFERENCES autores(id_autor),
 CONSTRAINT fk_libros_colecciones FOREIGN KEY (id_coleccion) REFERENCES colecciones(id_coleccion)
);
CREATE TABLE pagos (
 id_pago INT AUTO_INCREMENT PRIMARY KEY,
 id_autor INT NOT NULL,
 fecha_pago DATE,
 monto DECIMAL(10,2),
 CONSTRAINT fk_pagos_autores FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
);

-- CARGA OFICIAL: autores en el orden del enunciado.
INSERT INTO autores (nombre, pais, genero) VALUES
 ('Elena Pizarro','Chile','Novela'),
 ('Harold Finch','Inglaterra','Ensayo'),
 ('Rodrigo Bahamonde','Chile','Poesía'),
 ('Valentina Correa','Argentina','Infantil'),
 ('Nora Keller','Estados Unidos','Novela'),
 ('Kenji Arakawa',NULL,'Cómic');

-- CARGA OFICIAL: 12 libros. No cargar colecciones ni pagos aún.
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio) VALUES
 (1,'Cielo de Enero',210,1500,2024),
 (1,'Marea Baja',185,800,2023),
 (1,'El Norte',200,2200,2024),
 (2,'Estrellas que Caen',240,3000,2022),
 (2,'Máquinas',215,450,2024),
 (3,'Luz Artificial',300,1200,2024),
 (3,'Ruido Blanco',280,600,2023),
 (4,'El Barrio de Lila',190,5000,2024),
 (4,'Antes del Amanecer',205,2700,2024),
 (4,'La Calle 8',175,900,2023),
 (5,'Flor de Hierro',195,4100,2024),
 (5,'Hora Dorada',220,1800,2022);

-- CONSULTAS 1 A 6: ejecutar antes de INSERT/DELETE/UPDATE de las consultas 7 y 8.
-- 1. Incluye NULL explícitamente: NULL <> 'Chile' no es TRUE.
SELECT nombre, genero
FROM autores
WHERE pais <> 'Chile' OR pais IS NULL
ORDER BY nombre;

-- 2.
SELECT titulo, paginas
FROM libros
WHERE paginas BETWEEN 190 AND 220
ORDER BY paginas DESC;

-- 3. Una fila, cada columna con alias.
SELECT COUNT(*) AS numero_libros,
       SUM(ejemplares_vendidos) AS total_ejemplares_vendidos,
       AVG(paginas) AS promedio_paginas,
       MIN(anio) AS anio_mas_antiguo,
       MAX(ejemplares_vendidos) AS max_ejemplares_vendidos
FROM libros;

-- 4.
SELECT DISTINCT genero
FROM autores
ORDER BY genero;

-- 5.
SELECT a.nombre, COUNT(*) AS libros_2024
FROM autores AS a
INNER JOIN libros AS l ON l.id_autor = a.id_autor
WHERE l.anio = 2024
GROUP BY a.id_autor, a.nombre
HAVING COUNT(*) > 1
ORDER BY a.nombre;

-- 6.
SELECT titulo, ejemplares_vendidos
FROM libros
WHERE anio = 2024 AND ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC
LIMIT 3;

-- 7. Insertar, comprobar, borrar por título y volver a comprobar.
INSERT INTO libros (id_autor, titulo, paginas, ejemplares_vendidos, anio)
SELECT id_autor, 'Papel Mojado', 260, 50, 2024
FROM autores WHERE nombre = 'Rodrigo Bahamonde';
SELECT * FROM libros WHERE titulo = 'Papel Mojado';
DELETE FROM libros WHERE titulo = 'Papel Mojado';
SELECT * FROM libros WHERE titulo = 'Papel Mojado';

-- 8. SELECT previo, UPDATE calculado, SELECT posterior.
SELECT titulo, ejemplares_vendidos FROM libros WHERE titulo = 'Cielo de Enero';
UPDATE libros
SET ejemplares_vendidos = ejemplares_vendidos + 100
WHERE titulo = 'Cielo de Enero';
SELECT titulo, ejemplares_vendidos FROM libros WHERE titulo = 'Cielo de Enero';

-- 9. Datos de prueba (no están en la carga oficial).
INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
 ('Narrativas del Sur','2024-03-15'),
 ('Voces y Horizontes','2023-08-10');
UPDATE libros
SET id_coleccion = CASE
 WHEN id_libro BETWEEN 1 AND 6 THEN 1
 ELSE 2 END;
SELECT l.titulo AS titulo_libro,
       c.titulo AS titulo_coleccion,
       c.fecha_publicacion
FROM libros AS l
INNER JOIN colecciones AS c ON l.id_coleccion = c.id_coleccion
ORDER BY l.id_libro;

-- 10. Datos de prueba: dos pagos para el mismo autor.
INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
 (1,'2024-05-15',125000.00),
 (1,'2024-09-20',85000.50),
 (3,'2024-10-05',96000.00);
-- Sentencia 1: pagos detallados.
SELECT a.nombre AS autor, p.fecha_pago, p.monto
FROM pagos AS p
INNER JOIN autores AS a ON p.id_autor = a.id_autor
ORDER BY a.nombre, p.fecha_pago;
-- Sentencia 2: total pagado por autor.
SELECT a.nombre AS autor, SUM(p.monto) AS total_pagado
FROM pagos AS p
INNER JOIN autores AS a ON p.id_autor = a.id_autor
GROUP BY a.id_autor, a.nombre
ORDER BY a.nombre;
