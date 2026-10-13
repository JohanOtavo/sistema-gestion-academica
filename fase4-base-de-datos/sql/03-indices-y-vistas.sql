-- =====================================================================
-- Sistema de Gestión Académica (SGA) — Grupo 6
-- Fase 4: Base de datos
-- Archivo 3 de 5: índices y vistas
--
-- Los índices responden a RNF-03 y RNF-04: las consultas de listados y de
-- calificaciones deben responder en menos de tres segundos con 600
-- estudiantes y 40 cursos cargados.
--
-- Las vistas son el contrato de lectura de la capa de datos. Cada una
-- corresponde a una consulta del catálogo de casos de uso de la Fase 3, de
-- modo que la capa de negocio no tenga que reescribir las mismas uniones en
-- cada repositorio.
-- =====================================================================

SET search_path TO sga, public;


-- =====================================================================
-- 1. ÍNDICES
--    PostgreSQL crea índices para las claves primarias y las restricciones
--    de unicidad, pero no para las claves foráneas. Los declaramos de forma
--    explícita porque todas se usan como camino de acceso.
-- =====================================================================

-- Búsqueda de personas por nombre y por documento (RF-12, RF-13, RF-14)
CREATE INDEX ix_persona_apellidos ON persona (apellidos, nombres);
CREATE INDEX ix_persona_activa    ON persona (id_persona) WHERE estado = 'ACTIVO';

-- Oferta académica: cursos de un período y cursos de un docente (RF-25, RF-37)
CREATE INDEX ix_curso_periodo ON curso (id_periodo);
CREATE INDEX ix_curso_docente ON curso (id_docente) WHERE id_docente IS NOT NULL;

CREATE INDEX ix_corte_curso ON corte (id_curso);

-- Matrícula: la carga del estudiante y la lista de clase del curso
CREATE INDEX ix_matricula_estudiante ON matricula (id_estudiante, estado);
CREATE INDEX ix_matricula_curso      ON matricula (id_curso, estado);

-- Calificaciones: las notas de una matrícula y el acta de un corte
CREATE INDEX ix_calificacion_matricula ON calificacion (id_matricula);
CREATE INDEX ix_calificacion_corte     ON calificacion (id_corte);

-- Bitácoras: consulta por entidad afectada y por fecha
CREATE INDEX ix_auditoria_entidad ON registro_auditoria (entidad, id_entidad);
CREATE INDEX ix_auditoria_fecha   ON registro_auditoria (fecha_hora DESC);
CREATE INDEX ix_evento_fecha      ON evento_seguridad (fecha_hora DESC);

COMMENT ON INDEX ix_persona_activa IS
  'Índice parcial: las listas y los selectores solo consultan personas activas (ADR-004).';


-- =====================================================================
-- 2. VISTAS DEL DIRECTORIO DE PERSONAS (M2)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 2.1 vw_estudiante — reconstruye la clase Estudiante de la Figura 6 a
--     partir de las dos tablas de la jerarquía (ADR-010).
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_estudiante AS
SELECT e.id_persona                       AS id_estudiante,
       e.codigo_estudiante,
       p.tipo_documento,
       p.numero_documento,
       p.nombres,
       p.apellidos,
       p.apellidos || ', ' || p.nombres   AS nombre_completo,
       p.correo,
       p.telefono,
       e.fecha_nacimiento,
       e.fecha_ingreso,
       p.estado,
       p.fecha_registro
  FROM estudiante e
  JOIN persona    p ON p.id_persona = e.id_persona;

COMMENT ON VIEW vw_estudiante IS
  'CU-05: evita que cada consulta repita la unión entre persona y estudiante.';


-- ---------------------------------------------------------------------
-- 2.2 vw_docente
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_docente AS
SELECT d.id_persona                       AS id_docente,
       d.codigo_docente,
       p.tipo_documento,
       p.numero_documento,
       p.nombres,
       p.apellidos,
       p.apellidos || ', ' || p.nombres   AS nombre_completo,
       p.correo,
       p.telefono,
       d.area_conocimiento,
       d.fecha_vinculacion,
       p.estado
  FROM docente d
  JOIN persona p ON p.id_persona = d.id_persona;


-- =====================================================================
-- 3. VISTAS DE LA OFERTA ACADÉMICA (M3) Y DE LA MATRÍCULA (M4)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 3.1 vw_oferta_academica — CU-11, RF-25, RF-53
--     Cupos disponibles y porcentaje de ocupación de cada curso.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_oferta_academica AS
SELECT cu.id_curso,
       cu.codigo,
       cu.nombre,
       cu.creditos,
       pa.id_periodo,
       pa.codigo                        AS periodo,
       pa.estado                        AS estado_periodo,
       cu.id_docente,
       dv.nombre_completo               AS docente,
       cu.cupo_maximo,
       cu.matriculados,
       cu.cupo_maximo - cu.matriculados AS cupos_disponibles,
       ROUND(100.0 * cu.matriculados / cu.cupo_maximo, 1) AS ocupacion_porcentaje,
       cu.estado
  FROM curso cu
  JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
  LEFT JOIN vw_docente   dv ON dv.id_docente = cu.id_docente;

COMMENT ON VIEW vw_oferta_academica IS
  'RF-53: reporte de ocupación. El LEFT JOIN respeta la multiplicidad 0..1 del docente.';


-- ---------------------------------------------------------------------
-- 3.2 vw_lista_clase — CU-16, RF-37
--     Solo las matrículas activas: es lo que resuelve el dolor D-3 de la
--     Fase 1, que son las listas con estudiantes que ya no asisten.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_lista_clase AS
SELECT m.id_matricula,
       cu.id_curso,
       cu.codigo          AS codigo_curso,
       cu.nombre          AS curso,
       cu.id_docente,
       ev.id_estudiante,
       ev.codigo_estudiante,
       ev.nombre_completo AS estudiante,
       ev.correo,
       m.fecha_matricula
  FROM matricula      m
  JOIN curso         cu ON cu.id_curso      = m.id_curso
  JOIN vw_estudiante ev ON ev.id_estudiante = m.id_estudiante
 WHERE m.estado = 'ACTIVA';


-- =====================================================================
-- 4. VISTAS DE CALIFICACIONES Y CONSULTAS (M5 Y M6)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 4.1 vw_nota_definitiva — CU-19, RN-11, RN-12, RN-27
--     Calcula la definitiva de las matrículas en curso. Para las
--     FINALIZADAS devuelve la instantánea almacenada al cerrar el período,
--     que es el valor con el que la institución responde oficialmente.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_nota_definitiva AS
SELECT m.id_matricula,
       m.id_estudiante,
       m.id_curso,
       cu.id_periodo,
       m.estado                              AS estado_matricula,
       fn_matricula_completa(m.id_matricula)  AS completa,
       CASE WHEN m.estado = 'FINALIZADA' THEN m.nota_definitiva
            ELSE fn_nota_definitiva(m.id_matricula)
       END                                    AS definitiva,
       CASE WHEN m.estado = 'FINALIZADA' THEN m.aprobada
            WHEN fn_matricula_completa(m.id_matricula)
                 THEN fn_nota_definitiva(m.id_matricula) >= 3.0
            ELSE NULL        -- parcial: todavía no se determina la aprobación
       END                                    AS aprobada
  FROM matricula m
  JOIN curso    cu ON cu.id_curso = m.id_curso
 WHERE m.estado IN ('ACTIVA', 'FINALIZADA');

COMMENT ON VIEW vw_nota_definitiva IS
  'RN-12: aprobada queda en NULL mientras falte algún corte (flujo alterno 1a de CU-19).';


-- ---------------------------------------------------------------------
-- 4.2 vw_notas_estudiante — CU-21, RF-49
--     Una fila por matrícula y corte. El LEFT JOIN es lo que permite
--     presentar los cortes sin nota como PENDIENTE y no como 0.0, que es
--     la distinción que la Fase 3 identificó como crítica.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_notas_estudiante AS
SELECT m.id_estudiante,
       cu.id_periodo,
       pa.codigo          AS periodo,
       cu.id_curso,
       cu.codigo          AS codigo_curso,
       cu.nombre          AS curso,
       cu.creditos,
       co.numero          AS corte,
       co.porcentaje,
       c.valor            AS nota,
       CASE WHEN c.id_calificacion IS NULL THEN 'PENDIENTE'
            ELSE c.estado
       END                AS estado_nota,
       c.fecha_registro,
       nd.definitiva,
       nd.completa,
       nd.aprobada
  FROM matricula            m
  JOIN curso               cu ON cu.id_curso      = m.id_curso
  JOIN periodo_academico   pa ON pa.id_periodo    = cu.id_periodo
  JOIN corte               co ON co.id_curso      = cu.id_curso
  LEFT JOIN calificacion    c ON c.id_matricula   = m.id_matricula
                             AND c.id_corte       = co.id_corte
  JOIN vw_nota_definitiva  nd ON nd.id_matricula  = m.id_matricula
 WHERE m.estado IN ('ACTIVA', 'FINALIZADA');

COMMENT ON VIEW vw_notas_estudiante IS
  'CU-21: un corte sin fila en calificacion se presenta como PENDIENTE (Figura 17).';


-- ---------------------------------------------------------------------
-- 4.3 vw_promedio_estudiante — CU-22, RN-13, RF-50, RF-51
--     Incluye la marca de riesgo académico que dispara CU-27.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_promedio_estudiante AS
SELECT m.id_estudiante,
       ev.codigo_estudiante,
       ev.nombre_completo                                  AS estudiante,
       cu.id_periodo,
       pa.codigo                                           AS periodo,
       COUNT(*)                                            AS cursos_matriculados,
       SUM(cu.creditos)                                    AS creditos_inscritos,
       fn_promedio_periodo(m.id_estudiante, cu.id_periodo)  AS promedio,
       -- RF-51: aviso de riesgo académico cuando el promedio no alcanza 3.0
       COALESCE(fn_promedio_periodo(m.id_estudiante, cu.id_periodo) < 3.0, FALSE) AS en_riesgo
  FROM matricula            m
  JOIN curso               cu ON cu.id_curso      = m.id_curso
  JOIN periodo_academico   pa ON pa.id_periodo    = cu.id_periodo
  JOIN vw_estudiante       ev ON ev.id_estudiante = m.id_estudiante
 WHERE m.estado IN ('ACTIVA', 'FINALIZADA')
 GROUP BY m.id_estudiante, ev.codigo_estudiante, ev.nombre_completo,
          cu.id_periodo, pa.codigo;


-- ---------------------------------------------------------------------
-- 4.4 vw_auditoria_calificacion — CU-25, RN-18
--     Presenta la bitácora en términos del dominio: qué nota cambió, de
--     qué estudiante, en qué curso y quién lo hizo.
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_auditoria_calificacion AS
SELECT ra.id_registro,
       ra.fecha_hora,
       ra.operacion,
       ra.valor_anterior,
       ra.valor_nuevo,
       ev.codigo_estudiante,
       ev.nombre_completo AS estudiante,
       cu.codigo          AS codigo_curso,
       co.numero          AS corte,
       pa.codigo          AS periodo,
       au.correo          AS autor
  FROM registro_auditoria ra
  JOIN calificacion        c ON c.id_calificacion = ra.id_entidad
  JOIN matricula           m ON m.id_matricula    = c.id_matricula
  JOIN corte              co ON co.id_corte       = c.id_corte
  JOIN curso              cu ON cu.id_curso       = m.id_curso
  JOIN periodo_academico  pa ON pa.id_periodo     = cu.id_periodo
  JOIN vw_estudiante      ev ON ev.id_estudiante  = m.id_estudiante
  LEFT JOIN usuario       au ON au.id_usuario     = ra.id_usuario
 WHERE ra.entidad = 'calificacion';

COMMENT ON VIEW vw_auditoria_calificacion IS
  'RN-18 y RNF-20: historial legible de los cambios de nota, con su autor.';
