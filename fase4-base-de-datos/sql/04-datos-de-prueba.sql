-- =====================================================================
-- Sistema de Gestión Académica (SGA) — Grupo 6
-- Fase 4: Base de datos
-- Archivo 4 de 5: datos de prueba
--
-- Todos los datos son ficticios. Ninguna fila corresponde a una persona
-- real: los nombres, los documentos y los correos son inventados para el
-- entorno de desarrollo.
--
-- El juego de datos no es decorativo. Está construido para que la base
-- quede en los estados que la Fase 2 y la Fase 3 describieron:
--
--   · un período CERRADO con notas definitivas congeladas
--   · un período ACTIVO con cortes todavía pendientes
--   · un período PLANEADO sin cursos
--   · un curso lleno, para probar RN-05
--   · un curso sin docente asignado, por la multiplicidad 0..1
--   · un curso con dos cortes en lugar de tres, por RN-10
--   · un estudiante inactivo, por RN-15
--   · una matrícula cancelada, por RN-16
--   · una nota corregida, por RN-18
--   · la matrícula del diagrama de objetos de la Fase 3: Valentina en
--     Matemáticas I con 4.0, 3.0 y 5.0 sobre cortes de 30 %, 30 % y 40 %,
--     cuya definitiva debe ser 4.1 (criterio CA-1 de HU-21)
--
-- Todo el archivo corre en una sola transacción, porque la verificación de
-- RN-10 está diferida al momento de confirmar: los cortes de un curso solo
-- suman 100 % cuando están insertados todos.
-- =====================================================================

SET search_path TO sga, public;

BEGIN;


-- =====================================================================
-- 1. PERSONAS
-- =====================================================================

-- 1.1 Administradora académica, cuatro docentes y doce estudiantes
INSERT INTO persona (tipo_documento, numero_documento, nombres, apellidos, correo, telefono, estado) VALUES
    ('CC', '43256781',   'Laura Elena',     'Restrepo Ocampo',   'laura.restrepo@sga.edu.co',    '3104567890', 'ACTIVO'),
    ('CC', '71234567',   'Carlos Andres',   'Mejia Ruiz',        'carlos.mejia@sga.edu.co',      '3112223344', 'ACTIVO'),
    ('CC', '52345678',   'Marta Lucia',     'Gomez Pena',        'marta.gomez@sga.edu.co',       '3123334455', 'ACTIVO'),
    ('CC', '79345612',   'Jorge Ivan',      'Salazar Torres',    'jorge.salazar@sga.edu.co',     '3134445566', 'ACTIVO'),
    ('CC', '41567823',   'Diana Carolina',  'Perez Mora',        'diana.perez@sga.edu.co',       '3145556677', 'ACTIVO'),
    ('TI', '1098765401', 'Valentina',       'Rios Cardenas',     'valentina.rios@sga.edu.co',    '3151112233', 'ACTIVO'),
    ('TI', '1098765402', 'Santiago',        'Moreno Ocampo',     'santiago.moreno@sga.edu.co',   '3152223344', 'ACTIVO'),
    ('TI', '1098765403', 'Mariana',         'Castano Loaiza',    'mariana.castano@sga.edu.co',   '3153334455', 'ACTIVO'),
    ('TI', '1098765404', 'Juan David',      'Herrera Nieto',     'juan.herrera@sga.edu.co',      '3154445566', 'ACTIVO'),
    ('TI', '1098765405', 'Camila Andrea',   'Pineda Rojas',      'camila.pineda@sga.edu.co',     '3155556677', 'ACTIVO'),
    ('TI', '1098765406', 'Sebastian',       'Arango Velez',      'sebastian.arango@sga.edu.co',  '3156667788', 'ACTIVO'),
    ('TI', '1098765407', 'Isabella',        'Quintero Marin',    'isabella.quintero@sga.edu.co', '3157778899', 'ACTIVO'),
    ('TI', '1098765408', 'Mateo Alejandro', 'Duque Sierra',      'mateo.duque@sga.edu.co',       '3158889900', 'ACTIVO'),
    ('TI', '1098765409', 'Laura Sofia',     'Betancur Agudelo',  'laura.betancur@sga.edu.co',    '3159990011', 'ACTIVO'),
    ('TI', '1098765410', 'Nicolas',         'Franco Zapata',     'nicolas.franco@sga.edu.co',    '3160001122', 'ACTIVO'),
    ('TI', '1098765411', 'Sara Michelle',   'Osorio Ramirez',    'sara.osorio@sga.edu.co',       '3161112233', 'ACTIVO'),
    ('TI', '1098765412', 'Andres Felipe',   'Cardona Gil',       'andres.cardona@sga.edu.co',    '3162223344', 'ACTIVO');

-- 1.2 Subtipo docente
INSERT INTO docente (id_persona, codigo_docente, area_conocimiento, fecha_vinculacion)
SELECT p.id_persona, v.codigo, v.area, v.fecha
  FROM (VALUES
        ('71234567', 'DOC-001', 'Matematicas',        DATE '2019-01-21'),
        ('52345678', 'DOC-002', 'Humanidades',        DATE '2017-02-06'),
        ('79345612', 'DOC-003', 'Ciencias Naturales', DATE '2021-01-25'),
        ('41567823', 'DOC-004', 'Tecnologia',         DATE '2022-07-18')
       ) AS v(documento, codigo, area, fecha)
  JOIN persona p ON p.numero_documento = v.documento;

-- 1.3 Subtipo estudiante
INSERT INTO estudiante (id_persona, codigo_estudiante, fecha_nacimiento, fecha_ingreso)
SELECT p.id_persona, v.codigo, v.nacimiento, v.ingreso
  FROM (VALUES
        ('1098765401', 'EST-2026-001', DATE '2009-03-14', DATE '2026-01-26'),
        ('1098765402', 'EST-2026-002', DATE '2009-07-02', DATE '2026-01-26'),
        ('1098765403', 'EST-2026-003', DATE '2009-11-28', DATE '2026-01-26'),
        ('1098765404', 'EST-2026-004', DATE '2009-05-19', DATE '2026-01-26'),
        ('1098765405', 'EST-2026-005', DATE '2010-01-09', DATE '2026-01-26'),
        ('1098765406', 'EST-2026-006', DATE '2009-09-30', DATE '2026-01-26'),
        ('1098765407', 'EST-2026-007', DATE '2010-02-17', DATE '2026-01-26'),
        ('1098765408', 'EST-2026-008', DATE '2009-12-05', DATE '2026-01-26'),
        ('1098765409', 'EST-2026-009', DATE '2010-04-23', DATE '2026-07-20'),
        ('1098765410', 'EST-2026-010', DATE '2009-08-11', DATE '2026-07-20'),
        ('1098765411', 'EST-2026-011', DATE '2010-06-07', DATE '2026-07-20'),
        ('1098765412', 'EST-2026-012', DATE '2009-10-16', DATE '2026-07-20')
       ) AS v(documento, codigo, nacimiento, ingreso)
  JOIN persona p ON p.numero_documento = v.documento;


-- =====================================================================
-- 2. CUENTAS DE ACCESO
--    La contraseña temporal de todas las cuentas de prueba es
--    "Temporal123#". Es un valor de desarrollo: nunca se almacena en claro
--    (ADR-007) y debe cambiarse en el primer ingreso, que es justamente lo
--    que fuerza debe_cambiar_contrasena.
-- =====================================================================
INSERT INTO usuario (id_persona, correo, hash_contrasena, sal, rol, debe_cambiar_contrasena)
SELECT p.id_persona,
       p.correo,
       -- ADR-007: resumen criptográfico con sal única por usuario
       encode(sha256((md5(p.correo) || 'Temporal123#')::bytea), 'hex'),
       md5(p.correo),
       CASE
           WHEN EXISTS (SELECT 1 FROM docente    d WHERE d.id_persona = p.id_persona) THEN 'DOCENTE'
           WHEN EXISTS (SELECT 1 FROM estudiante e WHERE e.id_persona = p.id_persona) THEN 'ESTUDIANTE'
           ELSE 'ADMINISTRADOR'
       END,
       TRUE
  FROM persona p
 ORDER BY p.id_persona;   -- así la cuenta 1 es la de la administradora

-- A partir de aquí la administradora es la autora de las operaciones (RNF-20).
-- Se resuelve por correo y no por un identificador en duro, para no depender
-- del orden en que el motor asignó las claves.
SELECT set_config('sga.id_usuario',
                  (SELECT id_usuario::TEXT FROM usuario WHERE correo = 'laura.restrepo@sga.edu.co'),
                  TRUE);


-- =====================================================================
-- 3. PERÍODOS ACADÉMICOS
--    RN-03 solo admite un período ACTIVO, así que el histórico se carga con
--    2026-1 activo y se cierra antes de activar 2026-2.
-- =====================================================================
INSERT INTO periodo_academico (codigo, nombre, fecha_inicio, fecha_fin, estado) VALUES
    ('2026-1', 'Primer semestre de 2026',  DATE '2026-02-02', DATE '2026-06-12', 'ACTIVO'),
    ('2026-2', 'Segundo semestre de 2026', DATE '2026-07-20', DATE '2026-11-27', 'PLANEADO'),
    ('2027-1', 'Primer semestre de 2027',  DATE '2027-02-01', DATE '2027-06-11', 'PLANEADO');


-- =====================================================================
-- 4. PERÍODO 2026-1 — HISTÓRICO QUE SE CERRARÁ
-- =====================================================================

-- 4.1 Cursos
INSERT INTO curso (id_periodo, id_docente, codigo, nombre, creditos, cupo_maximo, estado)
SELECT pa.id_periodo, d.id_persona, v.codigo, v.nombre, v.creditos, v.cupo, 'DISPONIBLE'
  FROM (VALUES
        ('MAT-101', 'Matematicas I',       4, 30, 'DOC-001'),
        ('LEN-101', 'Lengua Castellana I', 3, 30, 'DOC-002')
       ) AS v(codigo, nombre, creditos, cupo, docente)
 CROSS JOIN (SELECT id_periodo FROM periodo_academico WHERE codigo = '2026-1') pa
  JOIN docente d ON d.codigo_docente = v.docente;

-- 4.2 Cortes: tres por curso, 30 % + 30 % + 40 % = 100 % (RN-10)
INSERT INTO corte (id_curso, numero, porcentaje, descripcion)
SELECT cu.id_curso, v.numero, v.porcentaje, v.descripcion
  FROM (VALUES
        (1, 30.00, 'Primer corte'),
        (2, 30.00, 'Segundo corte'),
        (3, 40.00, 'Corte final')
       ) AS v(numero, porcentaje, descripcion)
 CROSS JOIN curso cu
  JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
 WHERE pa.codigo = '2026-1';

-- 4.3 Matrículas del período, por su punto de entrada único (CU-14)
SELECT fn_matricular(e.id_estudiante, cu.id_curso)
  FROM (VALUES
        ('EST-2026-001', 'MAT-101'),
        ('EST-2026-001', 'LEN-101'),
        ('EST-2026-002', 'MAT-101'),
        ('EST-2026-002', 'LEN-101'),
        ('EST-2026-003', 'MAT-101'),
        ('EST-2026-003', 'LEN-101')
       ) AS v(estudiante, curso)
  JOIN vw_estudiante     e  ON e.codigo_estudiante = v.estudiante
  JOIN periodo_academico pa ON pa.codigo = '2026-1'
  JOIN curso             cu ON cu.codigo = v.curso AND cu.id_periodo = pa.id_periodo;

-- 4.4 Calificaciones completas, para que el período pueda cerrarse.
--     Las registra el docente titular de cada curso (RN-08).
INSERT INTO calificacion (id_matricula, id_corte, valor, id_usuario_registro)
SELECT m.id_matricula, co.id_corte, v.valor, u.id_usuario
  FROM (VALUES
        ('EST-2026-001', 'MAT-101', 1, 3.5), ('EST-2026-001', 'MAT-101', 2, 4.0), ('EST-2026-001', 'MAT-101', 3, 4.5),
        ('EST-2026-001', 'LEN-101', 1, 4.2), ('EST-2026-001', 'LEN-101', 2, 3.8), ('EST-2026-001', 'LEN-101', 3, 4.0),
        ('EST-2026-002', 'MAT-101', 1, 2.5), ('EST-2026-002', 'MAT-101', 2, 3.0), ('EST-2026-002', 'MAT-101', 3, 2.8),
        ('EST-2026-002', 'LEN-101', 1, 3.0), ('EST-2026-002', 'LEN-101', 2, 3.5), ('EST-2026-002', 'LEN-101', 3, 3.2),
        ('EST-2026-003', 'MAT-101', 1, 4.8), ('EST-2026-003', 'MAT-101', 2, 4.5), ('EST-2026-003', 'MAT-101', 3, 5.0),
        ('EST-2026-003', 'LEN-101', 1, 4.0), ('EST-2026-003', 'LEN-101', 2, 4.0), ('EST-2026-003', 'LEN-101', 3, 4.0)
       ) AS v(estudiante, curso, numero, valor)
  JOIN vw_estudiante     e  ON e.codigo_estudiante = v.estudiante
  JOIN periodo_academico pa ON pa.codigo = '2026-1'
  JOIN curso             cu ON cu.codigo = v.curso AND cu.id_periodo = pa.id_periodo
  JOIN matricula         m  ON m.id_estudiante = e.id_estudiante AND m.id_curso = cu.id_curso
  JOIN corte             co ON co.id_curso = cu.id_curso AND co.numero = v.numero
  JOIN usuario           u  ON u.id_persona = cu.id_docente;

-- 4.5 Cierre del período: congela las definitivas y determina la aprobación
SELECT fn_cerrar_periodo((SELECT id_periodo FROM periodo_academico WHERE codigo = '2026-1'));


-- =====================================================================
-- 5. PERÍODO 2026-2 — PERÍODO EN CURSO
-- =====================================================================

UPDATE periodo_academico SET estado = 'ACTIVO' WHERE codigo = '2026-2';

-- 5.1 Cursos del período.
--     MAT-101 repite el código de 2026-1: RN-20 exige unicidad dentro del
--     período, no en todo el sistema. Su cupo es de cuatro para que quede
--     lleno con la carga de prueba.
INSERT INTO curso (id_periodo, id_docente, codigo, nombre, creditos, cupo_maximo, estado)
SELECT pa.id_periodo, d.id_persona, v.codigo, v.nombre, v.creditos, v.cupo, 'DISPONIBLE'
  FROM (VALUES
        ('MAT-201', 'Matematicas II',           4, 25, 'DOC-001'),
        ('LEN-201', 'Lengua Castellana II',     3, 25, 'DOC-002'),
        ('CIE-101', 'Ciencias Naturales',       4, 20, 'DOC-003'),
        ('SIS-101', 'Tecnologia e Informatica', 2, 15, 'DOC-004'),
        ('MAT-101', 'Matematicas I',            4,  4, 'DOC-001')
       ) AS v(codigo, nombre, creditos, cupo, docente)
 CROSS JOIN (SELECT id_periodo FROM periodo_academico WHERE codigo = '2026-2') pa
  JOIN docente d ON d.codigo_docente = v.docente;

-- SOC-101 queda sin docente: es el caso que justifica la multiplicidad 0..1
-- y, por lo mismo, es el único curso sin calificaciones.
INSERT INTO curso (id_periodo, id_docente, codigo, nombre, creditos, cupo_maximo, estado)
SELECT pa.id_periodo, NULL, 'SOC-101', 'Ciencias Sociales', 3, 20, 'CREADO'
  FROM periodo_academico pa
 WHERE pa.codigo = '2026-2';

-- 5.2 Cortes. SIS-101 usa dos cortes de 50 %: es la razón por la que las
--     notas no se guardan como tres columnas fijas (Tabla 13 de la Fase 3).
INSERT INTO corte (id_curso, numero, porcentaje, descripcion)
SELECT cu.id_curso, v.numero, v.porcentaje, v.descripcion
  FROM (VALUES
        (1, 30.00, 'Primer corte'),
        (2, 30.00, 'Segundo corte'),
        (3, 40.00, 'Corte final')
       ) AS v(numero, porcentaje, descripcion)
 CROSS JOIN curso cu
  JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
 WHERE pa.codigo = '2026-2'
   AND cu.codigo <> 'SIS-101';

INSERT INTO corte (id_curso, numero, porcentaje, descripcion)
SELECT cu.id_curso, v.numero, v.porcentaje, v.descripcion
  FROM (VALUES
        (1, 50.00, 'Proyecto intermedio'),
        (2, 50.00, 'Proyecto final')
       ) AS v(numero, porcentaje, descripcion)
  JOIN periodo_academico pa ON pa.codigo = '2026-2'
  JOIN curso             cu ON cu.id_periodo = pa.id_periodo AND cu.codigo = 'SIS-101';

-- 5.3 Matrículas del período en curso
SELECT fn_matricular(e.id_estudiante, cu.id_curso)
  FROM (VALUES
        ('EST-2026-001', 'MAT-101'),   -- la matrícula del diagrama de objetos
        ('EST-2026-001', 'LEN-201'),
        ('EST-2026-001', 'CIE-101'),
        ('EST-2026-001', 'SIS-101'),
        ('EST-2026-002', 'MAT-201'),
        ('EST-2026-002', 'LEN-201'),
        ('EST-2026-002', 'SOC-101'),
        ('EST-2026-003', 'MAT-201'),
        ('EST-2026-003', 'CIE-101'),
        ('EST-2026-003', 'SIS-101'),
        ('EST-2026-004', 'LEN-201'),
        ('EST-2026-004', 'CIE-101'),
        ('EST-2026-005', 'MAT-101'),
        ('EST-2026-006', 'MAT-101'),
        ('EST-2026-007', 'MAT-101'),   -- con esta, MAT-101 queda lleno (RN-05)
        ('EST-2026-008', 'MAT-201'),
        ('EST-2026-008', 'LEN-201'),
        ('EST-2026-008', 'CIE-101'),
        ('EST-2026-008', 'SIS-101'),
        ('EST-2026-008', 'SOC-101'),
        ('EST-2026-009', 'MAT-201'),   -- esta matrícula se cancela más abajo
        ('EST-2026-010', 'MAT-201'),
        ('EST-2026-010', 'LEN-201'),
        ('EST-2026-011', 'CIE-101')
       ) AS v(estudiante, curso)
  JOIN vw_estudiante     e  ON e.codigo_estudiante = v.estudiante
  JOIN periodo_academico pa ON pa.codigo = '2026-2'
  JOIN curso             cu ON cu.codigo = v.curso AND cu.id_periodo = pa.id_periodo;

-- 5.4 Calificaciones parciales.
--     Valentina tiene los tres cortes de MAT-101: 4.0, 3.0 y 5.0, que con
--     pesos de 30 %, 30 % y 40 % dan una definitiva de 4.1.
--     Las demás matrículas tienen solo los primeros cortes; el resto queda
--     PENDIENTE, estado que se representa por la ausencia de fila.
INSERT INTO calificacion (id_matricula, id_corte, valor, id_usuario_registro)
SELECT m.id_matricula, co.id_corte, v.valor, u.id_usuario
  FROM (VALUES
        ('EST-2026-001', 'MAT-101', 1, 4.0), ('EST-2026-001', 'MAT-101', 2, 3.0), ('EST-2026-001', 'MAT-101', 3, 5.0),
        ('EST-2026-001', 'LEN-201', 1, 4.3), ('EST-2026-001', 'LEN-201', 2, 4.0),
        ('EST-2026-001', 'CIE-101', 1, 3.8), ('EST-2026-001', 'CIE-101', 2, 4.2),
        ('EST-2026-001', 'SIS-101', 1, 4.5),
        ('EST-2026-002', 'MAT-201', 1, 2.0), ('EST-2026-002', 'MAT-201', 2, 2.5),
        ('EST-2026-002', 'LEN-201', 1, 3.1), ('EST-2026-002', 'LEN-201', 2, 2.9),
        ('EST-2026-003', 'MAT-201', 1, 4.6), ('EST-2026-003', 'MAT-201', 2, 4.9),
        ('EST-2026-003', 'CIE-101', 1, 4.4), ('EST-2026-003', 'CIE-101', 2, 4.1),
        ('EST-2026-003', 'SIS-101', 1, 5.0),
        ('EST-2026-004', 'LEN-201', 1, 3.5), ('EST-2026-004', 'LEN-201', 2, 3.3),
        ('EST-2026-004', 'CIE-101', 1, 2.8), ('EST-2026-004', 'CIE-101', 2, 3.0),
        ('EST-2026-005', 'MAT-101', 1, 3.9), ('EST-2026-005', 'MAT-101', 2, 4.1),
        ('EST-2026-006', 'MAT-101', 1, 2.6), ('EST-2026-006', 'MAT-101', 2, 3.4),
        ('EST-2026-007', 'MAT-101', 1, 4.7),
        ('EST-2026-008', 'MAT-201', 1, 3.2), ('EST-2026-008', 'MAT-201', 2, 3.6),
        ('EST-2026-008', 'LEN-201', 1, 3.9), ('EST-2026-008', 'LEN-201', 2, 4.1),
        ('EST-2026-008', 'CIE-101', 1, 3.4), ('EST-2026-008', 'CIE-101', 2, 3.7),
        ('EST-2026-010', 'MAT-201', 1, 4.0), ('EST-2026-010', 'MAT-201', 2, 3.8),
        ('EST-2026-011', 'CIE-101', 1, 4.2)
       ) AS v(estudiante, curso, numero, valor)
  JOIN vw_estudiante     e  ON e.codigo_estudiante = v.estudiante
  JOIN periodo_academico pa ON pa.codigo = '2026-2'
  JOIN curso             cu ON cu.codigo = v.curso AND cu.id_periodo = pa.id_periodo
  JOIN matricula         m  ON m.id_estudiante = e.id_estudiante AND m.id_curso = cu.id_curso
  JOIN corte             co ON co.id_curso = cu.id_curso AND co.numero = v.numero
  JOIN usuario           u  ON u.id_persona = cu.id_docente;


-- =====================================================================
-- 6. OPERACIONES QUE DEJAN RASTRO
-- =====================================================================

-- 6.1 Corrección de una nota (RN-18): el disparador escribe en la bitácora
--     el valor anterior, el nuevo, el autor y la fecha.
UPDATE calificacion c
   SET valor = 3.0
 WHERE c.id_matricula = (SELECT m.id_matricula
                           FROM matricula m
                           JOIN vw_estudiante     e  ON e.id_estudiante = m.id_estudiante
                           JOIN curso             cu ON cu.id_curso     = m.id_curso
                           JOIN periodo_academico pa ON pa.id_periodo   = cu.id_periodo
                          WHERE e.codigo_estudiante = 'EST-2026-002'
                            AND cu.codigo = 'MAT-201'
                            AND pa.codigo = '2026-2')
   AND c.id_corte = (SELECT co.id_corte
                       FROM corte co
                       JOIN curso             cu ON cu.id_curso   = co.id_curso
                       JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
                      WHERE cu.codigo = 'MAT-201'
                        AND pa.codigo = '2026-2'
                        AND co.numero = 1);

-- 6.2 Cancelación de una matrícula (RN-16): libera el cupo de MAT-201
SELECT fn_cancelar_matricula(
           (SELECT m.id_matricula
              FROM matricula m
              JOIN vw_estudiante     e  ON e.id_estudiante = m.id_estudiante
              JOIN curso             cu ON cu.id_curso     = m.id_curso
              JOIN periodo_academico pa ON pa.id_periodo   = cu.id_periodo
             WHERE e.codigo_estudiante = 'EST-2026-009'
               AND cu.codigo = 'MAT-201'
               AND pa.codigo = '2026-2'),
           'Retiro voluntario del estudiante');

-- 6.3 Inactivación de un estudiante sin matrículas (RN-15, ADR-004): la
--     fila se conserva, su cuenta queda inactiva y el cambio se audita.
UPDATE persona
   SET estado = 'INACTIVO'
 WHERE numero_documento = '1098765412';

-- 6.4 Eventos de seguridad de ejemplo (RN-23, CU-01)
INSERT INTO evento_seguridad (tipo, correo_intento, id_usuario, operacion, direccion_ip) VALUES
    ('AUTENTICACION_FALLIDA', 'desconocido@sga.edu.co', NULL, 'iniciar_sesion', '192.168.10.44'),
    ('ACCESO_DENEGADO', 'santiago.moreno@sga.edu.co',
        (SELECT id_usuario FROM usuario WHERE correo = 'santiago.moreno@sga.edu.co'),
        'consultar_notas_de_otro_estudiante', '192.168.10.52');

COMMIT;


-- =====================================================================
-- 7. RESUMEN DE LA CARGA
-- =====================================================================
SELECT 'personas'       AS tabla, COUNT(*) AS filas FROM persona
UNION ALL SELECT 'estudiantes',    COUNT(*) FROM estudiante
UNION ALL SELECT 'docentes',       COUNT(*) FROM docente
UNION ALL SELECT 'usuarios',       COUNT(*) FROM usuario
UNION ALL SELECT 'periodos',       COUNT(*) FROM periodo_academico
UNION ALL SELECT 'cursos',         COUNT(*) FROM curso
UNION ALL SELECT 'cortes',         COUNT(*) FROM corte
UNION ALL SELECT 'matriculas',     COUNT(*) FROM matricula
UNION ALL SELECT 'calificaciones', COUNT(*) FROM calificacion
UNION ALL SELECT 'auditoria',      COUNT(*) FROM registro_auditoria
UNION ALL SELECT 'eventos',        COUNT(*) FROM evento_seguridad;
