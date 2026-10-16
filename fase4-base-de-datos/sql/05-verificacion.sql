-- =====================================================================
-- Sistema de Gestión Académica (SGA) — Grupo 6
-- Fase 4: Base de datos
-- Archivo 5 de 5: verificación del modelo
--
-- Un script de creación demuestra que el esquema se puede construir, no que
-- las reglas se cumplan. Este archivo prueba lo segundo: cada bloque intenta
-- una operación que el modelo debe rechazar y falla ruidosamente si el motor
-- la acepta. Es la contraparte en base de datos de los 15 casos de prueba de
-- la Fase 2 y la base de las pruebas automatizadas que exige RNF-26.
--
-- Ejecución:
--   psql -d sga -f 05-verificacion.sql
--
-- Resultado esperado: 26 avisos "OK" y un único ERROR, el de V-13, que es
-- el resultado que esa comprobación busca provocar. Cualquier otro ERROR
-- significa que el esquema dejó de cumplir una regla de negocio.
-- =====================================================================

SET search_path TO sga, public;
SET client_min_messages TO NOTICE;

-- Las operaciones de prueba también necesitan un autor (RNF-20). Se resuelve
-- por correo para no depender de un identificador en duro.
SELECT set_config('sga.id_usuario',
                  (SELECT id_usuario::TEXT FROM usuario WHERE correo = 'laura.restrepo@sga.edu.co'),
                  FALSE);


-- =====================================================================
-- 1. RESTRICCIONES DE UNICIDAD
-- =====================================================================

-- V-01 · RN-01: el número de documento no se repite
DO $$
BEGIN
    BEGIN
        INSERT INTO persona (tipo_documento, numero_documento, nombres, apellidos, correo)
        VALUES ('CC', '1098765401', 'Documento', 'Repetido', 'documento.repetido@sga.edu.co');
        RAISE EXCEPTION 'V-01 FALLA: se aceptó un documento duplicado';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'V-01 OK · RN-01: documento duplicado rechazado';
    END;
END $$;

-- V-02 · RN-02 y supuesto S-1: el correo tampoco se repite
DO $$
BEGIN
    BEGIN
        INSERT INTO persona (tipo_documento, numero_documento, nombres, apellidos, correo)
        VALUES ('CC', '99999999', 'Correo', 'Repetido', 'valentina.rios@sga.edu.co');
        RAISE EXCEPTION 'V-02 FALLA: se aceptó un correo duplicado';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'V-02 OK · RN-02: correo duplicado rechazado';
    END;
END $$;

-- V-03 · RN-03: no puede haber dos períodos activos
DO $$
BEGIN
    BEGIN
        UPDATE periodo_academico SET estado = 'ACTIVO' WHERE codigo = '2027-1';
        RAISE EXCEPTION 'V-03 FALLA: se aceptó un segundo período activo';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'V-03 OK · RN-03: segundo período activo rechazado';
    END;
END $$;

-- V-04 · RN-20: el código de curso es único dentro del período
DO $$
DECLARE
    v_periodo BIGINT;
BEGIN
    SELECT id_periodo INTO v_periodo FROM periodo_academico WHERE codigo = '2026-2';
    BEGIN
        INSERT INTO curso (id_periodo, codigo, nombre, creditos, cupo_maximo)
        VALUES (v_periodo, 'MAT-201', 'Matematicas II duplicada', 4, 10);
        RAISE EXCEPTION 'V-04 FALLA: se aceptó un código de curso repetido en el período';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'V-04 OK · RN-20: código de curso repetido en el período rechazado';
    END;
END $$;

-- V-05 · RN-20: el mismo código sí se admite en otro período
DO $$
DECLARE
    v_cuenta INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_cuenta FROM curso WHERE codigo = 'MAT-101';
    IF v_cuenta <> 2 THEN
        RAISE EXCEPTION 'V-05 FALLA: se esperaban 2 cursos MAT-101 en períodos distintos, hay %', v_cuenta;
    END IF;
    RAISE NOTICE 'V-05 OK · RN-20: MAT-101 existe en dos períodos distintos';
END $$;


-- =====================================================================
-- 2. REGLAS DE LA MATRÍCULA
-- =====================================================================

-- V-06 · RN-04: no hay dos matrículas activas del mismo estudiante en el curso.
--        Se usa LEN-201 y no MAT-101 a propósito: MAT-101 está lleno, y el
--        disparador de cupo rechazaría la operación antes de que el índice
--        único parcial llegara a evaluarse. La prueba estaría verificando
--        RN-05 creyendo verificar RN-04.
DO $$
DECLARE
    v_est BIGINT;
    v_cur BIGINT;
BEGIN
    SELECT e.id_estudiante INTO v_est FROM vw_estudiante e WHERE e.codigo_estudiante = 'EST-2026-001';
    SELECT cu.id_curso INTO v_cur
      FROM curso cu JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
     WHERE cu.codigo = 'LEN-201' AND pa.codigo = '2026-2';
    BEGIN
        PERFORM fn_matricular(v_est, v_cur);
        RAISE EXCEPTION 'V-06 FALLA: se aceptó una matrícula duplicada';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'V-06 OK · RN-04: matrícula duplicada rechazada';
    END;
END $$;

-- V-07 · RN-05: el curso lleno no admite más matrículas.
--        MAT-101 de 2026-2 tiene cupo 4 y cuatro matriculados.
DO $$
DECLARE
    v_est BIGINT;
    v_cur BIGINT;
BEGIN
    SELECT e.id_estudiante INTO v_est FROM vw_estudiante e WHERE e.codigo_estudiante = 'EST-2026-008';
    SELECT cu.id_curso INTO v_cur
      FROM curso cu JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
     WHERE cu.codigo = 'MAT-101' AND pa.codigo = '2026-2';
    BEGIN
        PERFORM fn_matricular(v_est, v_cur);
        RAISE EXCEPTION 'V-07 FALLA: se aceptó una matrícula sin cupo';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-07 OK · RN-05: matrícula rechazada por falta de cupo';
    END;
END $$;

-- V-08 · RN-06: el estudiante inactivo no se matricula
DO $$
DECLARE
    v_est BIGINT;
    v_cur BIGINT;
BEGIN
    SELECT p.id_persona INTO v_est FROM persona p WHERE p.numero_documento = '1098765412';
    SELECT cu.id_curso INTO v_cur
      FROM curso cu JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
     WHERE cu.codigo = 'CIE-101' AND pa.codigo = '2026-2';
    BEGIN
        PERFORM fn_matricular(v_est, v_cur);
        RAISE EXCEPTION 'V-08 FALLA: se aceptó la matrícula de un estudiante inactivo';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-08 OK · RN-06: matrícula de estudiante inactivo rechazada';
    END;
END $$;

-- V-09 · RN-07: no se matricula sobre un período que no está activo
DO $$
DECLARE
    v_est BIGINT;
    v_cur BIGINT;
BEGIN
    SELECT e.id_estudiante INTO v_est FROM vw_estudiante e WHERE e.codigo_estudiante = 'EST-2026-010';
    SELECT cu.id_curso INTO v_cur
      FROM curso cu JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
     WHERE cu.codigo = 'LEN-101' AND pa.codigo = '2026-1';
    BEGIN
        PERFORM fn_matricular(v_est, v_cur);
        RAISE EXCEPTION 'V-09 FALLA: se aceptó una matrícula en un período cerrado';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-09 OK · RN-07: matrícula en período no activo rechazada';
    END;
END $$;

-- V-10 · RN-16: la cancelación liberó el cupo de MAT-201
DO $$
DECLARE
    v_matriculados SMALLINT;
    v_activas      INTEGER;
BEGIN
    SELECT cu.matriculados,
           (SELECT COUNT(*) FROM matricula m WHERE m.id_curso = cu.id_curso AND m.estado = 'ACTIVA')
      INTO v_matriculados, v_activas
      FROM curso cu JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
     WHERE cu.codigo = 'MAT-201' AND pa.codigo = '2026-2';

    IF v_matriculados <> v_activas THEN
        RAISE EXCEPTION 'V-10 FALLA: el contador dice % y hay % matrículas activas',
            v_matriculados, v_activas;
    END IF;
    RAISE NOTICE 'V-10 OK · RN-16: el contador de MAT-201 quedó en % tras la cancelación', v_matriculados;
END $$;

-- V-11 · RN-05 y RNF-15: el contador coincide con las matrículas activas en
--        todos los cursos de los períodos que no están cerrados.
DO $$
DECLARE
    v_descuadres INTEGER;
BEGIN
    SELECT COUNT(*)
      INTO v_descuadres
      FROM curso cu
      JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
     WHERE pa.estado <> 'CERRADO'
       AND cu.matriculados <> (SELECT COUNT(*) FROM matricula m
                                WHERE m.id_curso = cu.id_curso AND m.estado = 'ACTIVA');

    IF v_descuadres > 0 THEN
        RAISE EXCEPTION 'V-11 FALLA: % curso(s) con el contador descuadrado', v_descuadres;
    END IF;
    RAISE NOTICE 'V-11 OK · RNF-15: ningún contador de cupo quedó descuadrado';
END $$;

-- V-12 · RN-14: la octava matrícula activa del período se rechaza.
--        El bloque crea tres cursos adicionales para llevar a una estudiante
--        hasta siete matrículas y deshace todo al final.
BEGIN;
SELECT set_config('sga.id_usuario',
                  (SELECT id_usuario::TEXT FROM usuario WHERE correo = 'laura.restrepo@sga.edu.co'),
                  TRUE);

INSERT INTO curso (id_periodo, id_docente, codigo, nombre, creditos, cupo_maximo, estado)
SELECT pa.id_periodo, d.id_persona, v.codigo, v.nombre, 2, 10, 'DISPONIBLE'
  FROM (VALUES ('TMP-001', 'Curso temporal 1'),
               ('TMP-002', 'Curso temporal 2'),
               ('TMP-003', 'Curso temporal 3')) AS v(codigo, nombre)
 CROSS JOIN (SELECT id_periodo FROM periodo_academico WHERE codigo = '2026-2') pa
  JOIN docente d ON d.codigo_docente = 'DOC-004';

INSERT INTO corte (id_curso, numero, porcentaje, descripcion)
SELECT cu.id_curso, 1, 100.00, 'Corte unico'
  FROM curso cu
 WHERE cu.codigo IN ('TMP-001', 'TMP-002', 'TMP-003');

DO $$
DECLARE
    v_est  BIGINT;
    v_cur  BIGINT;
    v_fila RECORD;
BEGIN
    SELECT e.id_estudiante INTO v_est FROM vw_estudiante e WHERE e.codigo_estudiante = 'EST-2026-001';

    -- Valentina pasa de cuatro a siete matrículas activas
    FOR v_fila IN SELECT id_curso FROM curso WHERE codigo IN ('TMP-001', 'TMP-002', 'TMP-003') LOOP
        PERFORM fn_matricular(v_est, v_fila.id_curso);
    END LOOP;

    SELECT cu.id_curso INTO v_cur
      FROM curso cu JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
     WHERE cu.codigo = 'MAT-201' AND pa.codigo = '2026-2';

    BEGIN
        PERFORM fn_matricular(v_est, v_cur);
        RAISE EXCEPTION 'V-12 FALLA: se aceptó la octava matrícula del período';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-12 OK · RN-14: la octava matrícula activa fue rechazada';
    END;
END $$;

ROLLBACK;


-- =====================================================================
-- 3. REGLAS DE LA OFERTA ACADÉMICA
-- =====================================================================

-- V-13 · RN-10: los porcentajes de los cortes de un curso deben sumar 100.
--
--        Esta comprobación no cabe en un bloque DO. La verificación de RN-10
--        está diferida al momento de confirmar, y SET CONSTRAINTS ALL IMMEDIATE
--        no libera los eventos pendientes desde dentro de una función: hay que
--        ejecutarlo como sentencia de primer nivel dentro de una transacción.
--
--        Por eso V-13 es el único bloque que imprime un ERROR, y ese ERROR es
--        justamente el resultado esperado. Lo que se comprueba después es que
--        la transacción no dejó rastro: CIE-101 debe seguir sumando 100.
BEGIN;

INSERT INTO corte (id_curso, numero, porcentaje, descripcion)
SELECT cu.id_curso, 4, 10.00, 'Corte que rompe la suma'
  FROM curso cu
  JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
 WHERE cu.codigo = 'CIE-101' AND pa.codigo = '2026-2';

-- Se espera que la siguiente sentencia falle con el mensaje de RN-10
SET CONSTRAINTS ALL IMMEDIATE;

ROLLBACK;

DO $$
DECLARE
    v_suma   NUMERIC;
    v_cortes INTEGER;
BEGIN
    SELECT COUNT(*), SUM(co.porcentaje)
      INTO v_cortes, v_suma
      FROM corte co
      JOIN curso cu             ON cu.id_curso   = co.id_curso
      JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
     WHERE cu.codigo = 'CIE-101' AND pa.codigo = '2026-2';

    IF v_cortes <> 3 OR v_suma <> 100 THEN
        RAISE EXCEPTION 'V-13 FALLA: CIE-101 quedó con % corte(s) que suman %', v_cortes, v_suma;
    END IF;
    RAISE NOTICE 'V-13 OK · RN-10: el corte que rompía la suma no se pudo confirmar';
END $$;

-- V-14 · RN-25: los créditos y el cupo son enteros positivos
DO $$
DECLARE
    v_periodo BIGINT;
BEGIN
    SELECT id_periodo INTO v_periodo FROM periodo_academico WHERE codigo = '2026-2';
    BEGIN
        INSERT INTO curso (id_periodo, codigo, nombre, creditos, cupo_maximo)
        VALUES (v_periodo, 'NEG-001', 'Curso con cupo invalido', 3, 0);
        RAISE EXCEPTION 'V-14 FALLA: se aceptó un cupo de cero';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-14 OK · RN-25: cupo no positivo rechazado';
    END;
END $$;

-- V-15 · RN-26: el cupo no se reduce por debajo de los matriculados
DO $$
BEGIN
    BEGIN
        UPDATE curso cu
           SET cupo_maximo = 1
         WHERE cu.codigo = 'MAT-101'
           AND cu.id_periodo = (SELECT id_periodo FROM periodo_academico WHERE codigo = '2026-2');
        RAISE EXCEPTION 'V-15 FALLA: se aceptó un cupo menor al número de matriculados';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-15 OK · RN-26: reducción de cupo por debajo de los matriculados rechazada';
    END;
END $$;

-- V-16 · RN-19: la fecha de fin del período es posterior a la de inicio
DO $$
BEGIN
    BEGIN
        INSERT INTO periodo_academico (codigo, nombre, fecha_inicio, fecha_fin)
        VALUES ('2028-X', 'Periodo invalido', DATE '2028-06-01', DATE '2028-02-01');
        RAISE EXCEPTION 'V-16 FALLA: se aceptó un período con fechas invertidas';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-16 OK · RN-19: período con fechas invertidas rechazado';
    END;
END $$;


-- =====================================================================
-- 4. REGLAS DE LAS CALIFICACIONES
-- =====================================================================

-- V-17 · RN-09: la nota está entre 0.0 y 5.0
DO $$
DECLARE
    v_mat BIGINT;
    v_cor BIGINT;
    v_doc BIGINT;
BEGIN
    SELECT m.id_matricula, co.id_corte, u.id_usuario
      INTO v_mat, v_cor, v_doc
      FROM matricula m
      JOIN vw_estudiante     e  ON e.id_estudiante = m.id_estudiante
      JOIN curso             cu ON cu.id_curso     = m.id_curso
      JOIN periodo_academico pa ON pa.id_periodo   = cu.id_periodo
      JOIN corte             co ON co.id_curso     = cu.id_curso AND co.numero = 3
      JOIN usuario           u  ON u.id_persona    = cu.id_docente
     WHERE e.codigo_estudiante = 'EST-2026-011'
       AND cu.codigo = 'CIE-101'
       AND pa.codigo = '2026-2';
    BEGIN
        INSERT INTO calificacion (id_matricula, id_corte, valor, id_usuario_registro)
        VALUES (v_mat, v_cor, 5.5, v_doc);
        RAISE EXCEPTION 'V-17 FALLA: se aceptó una nota de 5.5';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-17 OK · RN-09: nota fuera del rango 0.0 a 5.0 rechazada';
    END;
END $$;

-- V-18 · RN-17: con el período cerrado las notas son de solo lectura
DO $$
DECLARE
    v_cal BIGINT;
BEGIN
    SELECT c.id_calificacion INTO v_cal
      FROM calificacion c
      JOIN matricula         m  ON m.id_matricula = c.id_matricula
      JOIN curso             cu ON cu.id_curso    = m.id_curso
      JOIN periodo_academico pa ON pa.id_periodo  = cu.id_periodo
     WHERE pa.codigo = '2026-1'
     LIMIT 1;
    BEGIN
        UPDATE calificacion SET valor = 1.0 WHERE id_calificacion = v_cal;
        RAISE EXCEPTION 'V-18 FALLA: se modificó una nota de un período cerrado';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-18 OK · RN-17: modificación en período cerrado rechazada';
    END;
END $$;

-- V-19 · RN-18: la corrección de la nota quedó auditada con su valor anterior
DO $$
DECLARE
    v_registros INTEGER;
BEGIN
    SELECT COUNT(*)
      INTO v_registros
      FROM vw_auditoria_calificacion
     WHERE operacion      = 'MODIFICACION'
       AND valor_anterior = '2.0'
       AND valor_nuevo    = '3.0';

    IF v_registros < 1 THEN
        RAISE EXCEPTION 'V-19 FALLA: la corrección de nota no quedó registrada en la bitácora';
    END IF;
    RAISE NOTICE 'V-19 OK · RN-18: la corrección de 2.0 a 3.0 quedó auditada';
END $$;

-- V-20 · RNF-21: la bitácora no se modifica ni se borra
DO $$
BEGIN
    BEGIN
        UPDATE registro_auditoria SET valor_nuevo = '9.9'
         WHERE id_registro = (SELECT MIN(id_registro) FROM registro_auditoria);
        RAISE EXCEPTION 'V-20 FALLA: se modificó la bitácora de auditoría';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'V-20 OK · RNF-21: la bitácora rechazó la modificación';
    END;
END $$;


-- =====================================================================
-- 5. INACTIVACIÓN LÓGICA
-- =====================================================================

-- V-21 · RN-15: no se borra ninguna persona
DO $$
BEGIN
    BEGIN
        DELETE FROM persona WHERE numero_documento = '1098765412';
        RAISE EXCEPTION 'V-21 FALLA: se eliminó físicamente una persona';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'V-21 OK · RN-15: el borrado físico de persona fue rechazado';
    END;
END $$;

-- V-22 · RN-24: el docente con cursos vigentes no se inactiva
DO $$
BEGIN
    BEGIN
        UPDATE persona SET estado = 'INACTIVO' WHERE numero_documento = '71234567';
        RAISE EXCEPTION 'V-22 FALLA: se inactivó un docente con cursos en el período activo';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-22 OK · RN-24: inactivación de docente con cursos vigentes rechazada';
    END;
END $$;


-- =====================================================================
-- 5b. RESTABLECIMIENTO DE CONTRASEÑA
-- =====================================================================

-- V-23 · RN-29: la solicitud responde igual exista o no la cuenta
DO $$
DECLARE
    v_existe    BOOLEAN;
    v_no_existe BOOLEAN;
BEGIN
    v_existe := fn_solicitar_restablecimiento('valentina.rios@sga.edu.co',
                  encode(sha256('v23-a'::bytea), 'hex'), '127.0.0.1');
    v_no_existe := fn_solicitar_restablecimiento('nadie@sga.edu.co',
                  encode(sha256('v23-b'::bytea), 'hex'), '127.0.0.1');

    IF v_existe IS DISTINCT FROM v_no_existe THEN
        RAISE EXCEPTION 'V-23 FALLA: la respuesta delata si la cuenta existe';
    END IF;
    IF EXISTS (SELECT 1 FROM solicitud_restablecimiento
                WHERE hash_enlace = encode(sha256('v23-b'::bytea), 'hex')) THEN
        RAISE EXCEPTION 'V-23 FALLA: se registro un enlace para una cuenta inexistente';
    END IF;
    RAISE NOTICE 'V-23 OK · RN-29: la solicitud no revela que correos existen';
END $$;

-- V-24 · RN-28: el enlace vencido y el ya usado no sirven
DO $$
BEGIN
    IF fn_validar_enlace(encode(sha256('enlace-vencido-de-prueba'::bytea), 'hex')) IS NOT NULL THEN
        RAISE EXCEPTION 'V-24 FALLA: se acepto un enlace vencido';
    END IF;
    IF fn_validar_enlace(encode(sha256('enlace-ya-usado-de-prueba'::bytea), 'hex')) IS NOT NULL THEN
        RAISE EXCEPTION 'V-24 FALLA: se acepto un enlace ya usado';
    END IF;
    IF fn_validar_enlace(encode(sha256('enlace-vigente-de-prueba'::bytea), 'hex')) IS NULL THEN
        RAISE EXCEPTION 'V-24 FALLA: se rechazo un enlace vigente';
    END IF;
    RAISE NOTICE 'V-24 OK · RN-28: solo el enlace vigente y sin usar es aceptado';
END $$;

-- V-25 · RN-28 y RN-31: al usar el enlace, se consume y cambia la contrasena
DO $$
DECLARE
    v_hash    CHAR(64) := encode(sha256('enlace-vigente-de-prueba'::bytea), 'hex');
    v_usuario BIGINT;
    v_antes   CHAR(64);
    v_despues CHAR(64);
BEGIN
    v_usuario := fn_validar_enlace(v_hash);
    SELECT hash_contrasena INTO v_antes FROM usuario WHERE id_usuario = v_usuario;

    PERFORM fn_usar_enlace(v_hash,
             encode(sha256('contrasena-nueva'::bytea), 'hex'),
             md5('sal-nueva'));

    SELECT hash_contrasena INTO v_despues FROM usuario WHERE id_usuario = v_usuario;
    IF v_antes = v_despues THEN
        RAISE EXCEPTION 'V-25 FALLA: la contrasena no cambio';
    END IF;

    BEGIN
        PERFORM fn_usar_enlace(v_hash, encode(sha256('otra'::bytea), 'hex'), md5('otra'));
        RAISE EXCEPTION 'V-25 FALLA: el enlace se pudo usar dos veces';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-25 OK · RN-28: el enlace cambio la contrasena y quedo consumido';
    END;
END $$;

-- V-26 · RN-30: la cuarta solicitud en una hora se rechaza
DO $$
DECLARE
    v_correo VARCHAR := 'mariana.castano@sga.edu.co';
BEGIN
    PERFORM fn_solicitar_restablecimiento(v_correo, encode(sha256('v26-1'::bytea), 'hex'));
    PERFORM fn_solicitar_restablecimiento(v_correo, encode(sha256('v26-2'::bytea), 'hex'));
    PERFORM fn_solicitar_restablecimiento(v_correo, encode(sha256('v26-3'::bytea), 'hex'));
    BEGIN
        PERFORM fn_solicitar_restablecimiento(v_correo, encode(sha256('v26-4'::bytea), 'hex'));
        RAISE EXCEPTION 'V-26 FALLA: se acepto la cuarta solicitud en una hora';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'V-26 OK · RN-30: la cuarta solicitud en una hora fue rechazada';
    END;
END $$;


-- =====================================================================
-- 6. COMPROBACIÓN DE LOS CÁLCULOS
--    Los valores esperados vienen del diagrama de objetos de la Fase 3 y
--    del criterio de aceptación CA-1 de HU-21.
-- =====================================================================

-- RN-11 y RN-27: Valentina en Matemáticas I con 4.0, 3.0 y 5.0 sobre cortes
-- de 30 %, 30 % y 40 % debe tener una definitiva de 4.1.
SELECT 'RN-11 definitiva de Valentina en MAT-101' AS comprobacion,
       nd.definitiva                              AS obtenido,
       4.1                                        AS esperado,
       CASE WHEN nd.definitiva = 4.1 THEN 'OK' ELSE 'FALLA' END AS resultado
  FROM vw_nota_definitiva nd
  JOIN curso             cu ON cu.id_curso     = nd.id_curso
  JOIN periodo_academico pa ON pa.id_periodo   = cu.id_periodo
  JOIN vw_estudiante     e  ON e.id_estudiante = nd.id_estudiante
 WHERE e.codigo_estudiante = 'EST-2026-001'
   AND cu.codigo = 'MAT-101'
   AND pa.codigo = '2026-2';

-- RN-12: Santiago reprobó Matemáticas I de 2026-1 con 2.8
SELECT 'RN-12 aprobación de Santiago en MAT-101 de 2026-1' AS comprobacion,
       nd.definitiva                                        AS definitiva,
       nd.aprobada                                          AS obtenido,
       FALSE                                                AS esperado,
       CASE WHEN nd.aprobada IS FALSE THEN 'OK' ELSE 'FALLA' END AS resultado
  FROM vw_nota_definitiva nd
  JOIN curso             cu ON cu.id_curso     = nd.id_curso
  JOIN periodo_academico pa ON pa.id_periodo   = cu.id_periodo
  JOIN vw_estudiante     e  ON e.id_estudiante = nd.id_estudiante
 WHERE e.codigo_estudiante = 'EST-2026-002'
   AND cu.codigo = 'MAT-101'
   AND pa.codigo = '2026-1';

-- Figura 17: un corte sin nota se presenta como PENDIENTE, nunca como 0.0
SELECT 'Cortes pendientes del período activo' AS comprobacion,
       COUNT(*)                               AS pendientes,
       CASE WHEN COUNT(*) > 0 THEN 'OK' ELSE 'FALLA' END AS resultado
  FROM vw_notas_estudiante
 WHERE periodo = '2026-2'
   AND estado_nota = 'PENDIENTE'
   AND nota IS NULL;

-- RN-13: promedio ponderado por créditos del período activo
SELECT 'RN-13 promedio ponderado del período activo' AS comprobacion,
       estudiante,
       cursos_matriculados,
       creditos_inscritos,
       promedio,
       en_riesgo
  FROM vw_promedio_estudiante
 WHERE periodo = '2026-2'
 ORDER BY estudiante;

-- Estado final de la oferta del período activo
SELECT 'Ocupación del período activo' AS comprobacion,
       codigo,
       nombre,
       COALESCE(docente, 'sin asignar') AS docente,
       matriculados,
       cupo_maximo,
       cupos_disponibles,
       ocupacion_porcentaje
  FROM vw_oferta_academica
 WHERE periodo = '2026-2'
 ORDER BY codigo;
