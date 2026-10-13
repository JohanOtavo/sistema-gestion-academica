-- =====================================================================
-- Sistema de Gestión Académica (SGA) — Grupo 6
-- Fase 4: Base de datos
-- Archivo 2 de 5: reglas de negocio en el esquema (funciones y disparadores)
--
-- Aquí viven las reglas que no se pueden expresar con una restricción
-- declarativa porque necesitan consultar otras filas o otras tablas.
-- El criterio para bajar una regla hasta la base de datos es el de ADR-002:
-- si su incumplimiento corrompe el registro académico, se impone en el motor
-- y no solo en la capa de negocio, de modo que la regla se sostenga incluso
-- si un error de programación la omite en el código.
--
-- Reglas implementadas en este archivo:
--   RN-05  cupo disponible                 trg_matricula_valida / trg_matricula_cupo
--   RN-06  estudiante activo               trg_matricula_valida
--   RN-07  solo sobre el período activo    trg_matricula_valida
--   RN-10  los cortes suman 100 %          trg_corte_suma_100 (diferido)
--   RN-11  cálculo de la nota definitiva   fn_nota_definitiva
--   RN-12  aprobación con 3.0              fn_cerrar_periodo
--   RN-13  promedio ponderado por créditos fn_promedio_periodo
--   RN-14  máximo siete matrículas         trg_matricula_valida
--   RN-15  no se elimina, se inactiva      trg_persona_no_borrar / trg_curso_no_borrar
--   RN-16  cancelar libera cupo            trg_matricula_cupo
--   RN-17  período cerrado, solo lectura   trg_calificacion_periodo
--   RN-18  auditoría de la calificación    trg_calificacion_auditoria
--   RN-24  docente con cursos vigentes     trg_persona_inactivar
--   RN-27  redondeo a un decimal           fn_nota_definitiva / fn_promedio_periodo
--   RNF-21 bitácora inmutable              trg_auditoria_inmutable
-- =====================================================================

SET search_path TO sga, public;


-- =====================================================================
-- 0. USUARIO DE LA SESIÓN
--    RNF-20 exige que toda operación sobre notas y matrículas registre a su
--    autor. La aplicación declara quién opera al inicio de cada transacción:
--
--        SET LOCAL sga.id_usuario = '3';
--
--    Si nadie lo declara, la función devuelve NULL y el registro de auditoría
--    queda marcado como operación del sistema.
-- =====================================================================
CREATE OR REPLACE FUNCTION fn_usuario_sesion()
RETURNS BIGINT
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_valor TEXT;
BEGIN
    v_valor := current_setting('sga.id_usuario', TRUE);
    IF v_valor IS NULL OR btrim(v_valor) = '' THEN
        RETURN NULL;
    END IF;
    RETURN v_valor::BIGINT;
END;
$$;

COMMENT ON FUNCTION fn_usuario_sesion() IS
  'RNF-20: identifica al autor de la operación a partir de la variable de sesión sga.id_usuario.';


-- =====================================================================
-- 1. CÁLCULOS ACADÉMICOS
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1.1 fn_nota_definitiva — RN-11, RN-27
--     Suma el producto de cada nota por el porcentaje de su corte y redondea
--     a un decimal. Si faltan cortes por calificar devuelve el aporte
--     acumulado: es un valor parcial, no una nota final. Quien necesite
--     distinguir ambos casos usa fn_matricula_completa.
--
--     Sin ninguna nota registrada devuelve NULL y no 0.0. Un cero sería una
--     afirmación falsa sobre el desempeño del estudiante, y es exactamente la
--     confusión entre PENDIENTE y 0.0 que el modelo de datos evita al no
--     almacenar las calificaciones pendientes.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_nota_definitiva(p_id_matricula BIGINT)
RETURNS NUMERIC(2,1)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_definitiva NUMERIC;
    v_notas      INTEGER;
BEGIN
    SELECT COUNT(*), COALESCE(SUM(c.valor * co.porcentaje / 100), 0)
      INTO v_notas, v_definitiva
      FROM calificacion c
      JOIN corte co ON co.id_corte = c.id_corte
     WHERE c.id_matricula = p_id_matricula;

    IF v_notas = 0 THEN
        RETURN NULL;   -- no hay nada calificado todavía
    END IF;

    -- RN-27: un decimal con redondeo estándar
    RETURN ROUND(v_definitiva, 1);
END;
$$;

COMMENT ON FUNCTION fn_nota_definitiva(BIGINT) IS
  'RN-11 y RN-27: definitiva = suma(nota x porcentaje), redondeada a un decimal. NULL si no hay ninguna nota registrada.';


-- ---------------------------------------------------------------------
-- 1.2 fn_matricula_completa
--     Verdadero cuando la matrícula tiene nota en todos los cortes de su
--     curso. Solo entonces la definitiva es final y se puede aplicar RN-12.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_matricula_completa(p_id_matricula BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_cortes       INTEGER;
    v_calificadas  INTEGER;
BEGIN
    SELECT COUNT(*)
      INTO v_cortes
      FROM corte co
      JOIN matricula m ON m.id_curso = co.id_curso
     WHERE m.id_matricula = p_id_matricula;

    SELECT COUNT(*)
      INTO v_calificadas
      FROM calificacion c
     WHERE c.id_matricula = p_id_matricula;

    RETURN v_cortes > 0 AND v_cortes = v_calificadas;
END;
$$;

COMMENT ON FUNCTION fn_matricula_completa(BIGINT) IS
  'Distingue una definitiva final de un valor parcial (flujo alterno 1a de CU-19).';


-- ---------------------------------------------------------------------
-- 1.3 fn_promedio_periodo — RN-13, RN-27
--     Promedio ponderado por los créditos de cada curso, calculado solo
--     sobre las matrículas con todas sus notas registradas.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_promedio_periodo(
    p_id_estudiante BIGINT,
    p_id_periodo    BIGINT)
RETURNS NUMERIC(2,1)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_suma      NUMERIC := 0;
    v_creditos  INTEGER := 0;
    v_fila      RECORD;
BEGIN
    FOR v_fila IN
        SELECT m.id_matricula, cu.creditos
          FROM matricula m
          JOIN curso cu ON cu.id_curso = m.id_curso
         WHERE m.id_estudiante = p_id_estudiante
           AND cu.id_periodo   = p_id_periodo
           AND m.estado       IN ('ACTIVA', 'FINALIZADA')
    LOOP
        IF fn_matricula_completa(v_fila.id_matricula) THEN
            v_suma     := v_suma + fn_nota_definitiva(v_fila.id_matricula) * v_fila.creditos;
            v_creditos := v_creditos + v_fila.creditos;
        END IF;
    END LOOP;

    IF v_creditos = 0 THEN
        RETURN NULL;   -- todavía no hay nada que promediar
    END IF;

    -- RN-27: un decimal con redondeo estándar
    RETURN ROUND(v_suma / v_creditos, 1);
END;
$$;

COMMENT ON FUNCTION fn_promedio_periodo(BIGINT, BIGINT) IS
  'RN-13: promedio ponderado por créditos. Devuelve NULL si aún no hay cursos completos.';


-- =====================================================================
-- 2. INTEGRIDAD DE LA OFERTA ACADÉMICA
-- =====================================================================

-- ---------------------------------------------------------------------
-- 2.1 RN-10 — los porcentajes de los cortes de un curso suman 100 %
--     Se verifica con un disparador de restricción diferido: la suma solo
--     tiene sentido cuando están insertados todos los cortes, de modo que
--     la comprobación ocurre al confirmar la transacción y no fila por fila.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_corte_suma_100()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_curso BIGINT;
    v_suma     NUMERIC;
BEGIN
    v_id_curso := COALESCE(NEW.id_curso, OLD.id_curso);

    -- Si el curso se eliminó en la misma transacción no hay nada que validar
    IF NOT EXISTS (SELECT 1 FROM curso WHERE id_curso = v_id_curso) THEN
        RETURN NULL;
    END IF;

    SELECT COALESCE(SUM(porcentaje), 0)
      INTO v_suma
      FROM corte
     WHERE id_curso = v_id_curso;

    IF v_suma <> 100 THEN
        RAISE EXCEPTION
            'RN-10: los porcentajes de los cortes del curso % suman %, deben sumar 100',
            v_id_curso, v_suma
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER trg_corte_suma_100
    AFTER INSERT OR UPDATE OR DELETE ON corte
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE FUNCTION fn_corte_suma_100();


-- =====================================================================
-- 3. REGLAS DE LA MATRÍCULA
-- =====================================================================

-- ---------------------------------------------------------------------
-- 3.1 trg_matricula_valida — RN-05, RN-06, RN-07, RN-14
--     Las validaciones se evalúan en el orden que fija RF-30, que es el que
--     determina cuál mensaje recibe el administrador cuando falla más de una
--     (Figura 11 de la Fase 3).
--     RN-04 no aparece aquí: la impone el índice único parcial
--     uq_matricula_activa, que es más barato y a prueba de concurrencia.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_matricula_valida()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado_persona  VARCHAR(10);
    v_estado_periodo  VARCHAR(10);
    v_id_periodo      BIGINT;
    v_estado_curso    VARCHAR(12);
    v_cupo            SMALLINT;
    v_matriculados    SMALLINT;
    v_activas         INTEGER;
BEGIN
    SELECT p.estado
      INTO v_estado_persona
      FROM persona p
     WHERE p.id_persona = NEW.id_estudiante;

    SELECT cu.id_periodo, cu.estado, cu.cupo_maximo, cu.matriculados, pa.estado
      INTO v_id_periodo, v_estado_curso, v_cupo, v_matriculados, v_estado_periodo
      FROM curso cu
      JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
     WHERE cu.id_curso = NEW.id_curso
       FOR UPDATE OF cu;   -- serializa los intentos simultáneos sobre el mismo curso

    -- RN-07: las matrículas solo se registran sobre el período activo
    IF v_estado_periodo <> 'ACTIVO' THEN
        RAISE EXCEPTION 'RN-07: no hay un período académico activo para el curso %', NEW.id_curso
            USING ERRCODE = 'check_violation';
    END IF;

    -- RN-06: solo se matriculan estudiantes activos
    IF v_estado_persona <> 'ACTIVO' THEN
        RAISE EXCEPTION 'RN-06: el estudiante % no está activo', NEW.id_estudiante
            USING ERRCODE = 'check_violation';
    END IF;

    IF v_estado_curso = 'INACTIVO' THEN
        RAISE EXCEPTION 'RN-15: el curso % está inactivo', NEW.id_curso
            USING ERRCODE = 'check_violation';
    END IF;

    -- RN-05: no se matricula si el curso llegó a su cupo
    IF v_matriculados >= v_cupo THEN
        RAISE EXCEPTION 'RN-05: el curso % no tiene cupos disponibles', NEW.id_curso
            USING ERRCODE = 'check_violation';
    END IF;

    -- RN-14: máximo siete matrículas activas por estudiante y período
    SELECT COUNT(*)
      INTO v_activas
      FROM matricula m
      JOIN curso cu ON cu.id_curso = m.id_curso
     WHERE m.id_estudiante = NEW.id_estudiante
       AND cu.id_periodo   = v_id_periodo
       AND m.estado        = 'ACTIVA';

    IF v_activas >= 7 THEN
        RAISE EXCEPTION
            'RN-14: el estudiante % ya tiene 7 matrículas activas en el período %',
            NEW.id_estudiante, v_id_periodo
            USING ERRCODE = 'check_violation';
    END IF;

    NEW.id_usuario_registro := COALESCE(NEW.id_usuario_registro, fn_usuario_sesion());
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_matricula_valida
    BEFORE INSERT ON matricula
    FOR EACH ROW
    EXECUTE FUNCTION fn_matricula_valida();


-- ---------------------------------------------------------------------
-- 3.2 trg_matricula_cupo — RN-05, RN-16, RNF-15
--     Mantiene el contador curso.matriculados dentro de la misma transacción
--     que la matrícula. La restricción ck_curso_ocupacion del archivo 01
--     actúa como red: si este disparador fallara, el motor rechaza la
--     operación antes de dejar el contador en un valor imposible.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_matricula_cupo()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.estado = 'ACTIVA' THEN
            UPDATE curso SET matriculados = matriculados + 1 WHERE id_curso = NEW.id_curso;
        END IF;
        RETURN NEW;
    END IF;

    IF TG_OP = 'UPDATE' AND OLD.estado <> NEW.estado THEN
        -- RN-16: la cancelación libera el cupo. El paso a FINALIZADA no lo
        -- libera: el contador de un período cerrado debe seguir reflejando
        -- cuántos estudiantes lo cursaron, que es lo que consulta el
        -- reporte histórico de ocupación.
        IF OLD.estado = 'ACTIVA' AND NEW.estado = 'CANCELADA' THEN
            UPDATE curso SET matriculados = matriculados - 1 WHERE id_curso = NEW.id_curso;
        -- Rematrícula sobre la misma fila: vuelve a ocupar cupo
        ELSIF OLD.estado = 'CANCELADA' AND NEW.estado = 'ACTIVA' THEN
            UPDATE curso SET matriculados = matriculados + 1 WHERE id_curso = NEW.id_curso;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_matricula_cupo
    AFTER INSERT OR UPDATE OF estado ON matricula
    FOR EACH ROW
    EXECUTE FUNCTION fn_matricula_cupo();


-- ---------------------------------------------------------------------
-- 3.3 fn_matricular — CU-14 completo en una sola transacción (RNF-15)
--     Toda la validación vive en los disparadores anteriores; esta función
--     existe para que la capa de negocio tenga un único punto de entrada y
--     para que la matrícula y el contador se escriban juntos o no se
--     escriban. Devuelve el identificador de la matrícula creada.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_matricular(
    p_id_estudiante BIGINT,
    p_id_curso      BIGINT,
    p_id_usuario    BIGINT DEFAULT NULL)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_matricula BIGINT;
BEGIN
    INSERT INTO matricula (id_estudiante, id_curso, id_usuario_registro)
    VALUES (p_id_estudiante, p_id_curso, COALESCE(p_id_usuario, fn_usuario_sesion()))
    RETURNING id_matricula INTO v_id_matricula;

    RETURN v_id_matricula;
EXCEPTION
    WHEN unique_violation THEN
        -- RN-04: ya existe una matrícula activa del estudiante en ese curso
        RAISE EXCEPTION 'RN-04: el estudiante % ya está matriculado en el curso %',
            p_id_estudiante, p_id_curso
            USING ERRCODE = 'unique_violation';
END;
$$;

COMMENT ON FUNCTION fn_matricular(BIGINT, BIGINT, BIGINT) IS
  'CU-14: punto de entrada único de la matrícula. Atómica por RNF-15.';


-- ---------------------------------------------------------------------
-- 3.4 fn_cancelar_matricula — CU-15, RN-16, RN-17
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_cancelar_matricula(
    p_id_matricula BIGINT,
    p_motivo       VARCHAR DEFAULT NULL,
    p_id_usuario   BIGINT  DEFAULT NULL)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_estado_matricula VARCHAR(12);
    v_estado_periodo   VARCHAR(10);
BEGIN
    SELECT m.estado, pa.estado
      INTO v_estado_matricula, v_estado_periodo
      FROM matricula m
      JOIN curso cu             ON cu.id_curso   = m.id_curso
      JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
     WHERE m.id_matricula = p_id_matricula
       FOR UPDATE OF m;

    IF v_estado_matricula IS NULL THEN
        RAISE EXCEPTION 'La matrícula % no existe', p_id_matricula;
    END IF;

    IF v_estado_matricula <> 'ACTIVA' THEN
        RAISE EXCEPTION 'Solo se cancelan matrículas activas; la % está en estado %',
            p_id_matricula, v_estado_matricula
            USING ERRCODE = 'check_violation';
    END IF;

    -- RN-17: con el período cerrado el registro académico es de solo lectura
    IF v_estado_periodo = 'CERRADO' THEN
        RAISE EXCEPTION 'RN-17: el período está cerrado y no admite cancelaciones'
            USING ERRCODE = 'check_violation';
    END IF;

    UPDATE matricula
       SET estado                 = 'CANCELADA',
           fecha_cancelacion      = CURRENT_TIMESTAMP,
           id_usuario_cancelacion = COALESCE(p_id_usuario, fn_usuario_sesion()),
           motivo_cancelacion     = p_motivo
     WHERE id_matricula = p_id_matricula;
END;
$$;

COMMENT ON FUNCTION fn_cancelar_matricula(BIGINT, VARCHAR, BIGINT) IS
  'CU-15: cancela la matrícula y deja que trg_matricula_cupo libere el cupo (RN-16).';


-- =====================================================================
-- 4. REGLAS DE LAS CALIFICACIONES
-- =====================================================================

-- ---------------------------------------------------------------------
-- 4.1 trg_calificacion_periodo — RN-17
--     Con el período cerrado las calificaciones no se escriben, no se
--     corrigen y no se borran.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_calificacion_periodo()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_matricula   BIGINT;
    v_estado_periodo VARCHAR(10);
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_id_matricula := OLD.id_matricula;
    ELSE
        v_id_matricula := NEW.id_matricula;
    END IF;

    SELECT pa.estado
      INTO v_estado_periodo
      FROM matricula m
      JOIN curso cu             ON cu.id_curso   = m.id_curso
      JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
     WHERE m.id_matricula = v_id_matricula;

    IF v_estado_periodo = 'CERRADO' THEN
        RAISE EXCEPTION 'RN-17: el período está cerrado; las calificaciones son de solo lectura'
            USING ERRCODE = 'check_violation';
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        NEW.fecha_modificacion := CURRENT_TIMESTAMP;
        IF NEW.valor <> OLD.valor THEN
            NEW.estado := 'CORREGIDA';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_calificacion_periodo
    BEFORE INSERT OR UPDATE OR DELETE ON calificacion
    FOR EACH ROW
    EXECUTE FUNCTION fn_calificacion_periodo();


-- ---------------------------------------------------------------------
-- 4.2 trg_calificacion_auditoria — RN-18, RNF-20
--     Toda modificación de una nota conserva el valor anterior, el nuevo,
--     el autor y la fecha. La bitácora la escribe el motor: no depende de
--     que la aplicación se acuerde de hacerlo.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_calificacion_auditoria()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO registro_auditoria
            (entidad, id_entidad, operacion, valor_anterior, valor_nuevo, id_usuario)
        VALUES ('calificacion', NEW.id_calificacion, 'INSERCION',
                NULL, NEW.valor::TEXT,
                COALESCE(NEW.id_usuario_registro, fn_usuario_sesion()));
        RETURN NEW;
    END IF;

    IF OLD.valor <> NEW.valor THEN
        INSERT INTO registro_auditoria
            (entidad, id_entidad, operacion, valor_anterior, valor_nuevo, id_usuario)
        VALUES ('calificacion', NEW.id_calificacion, 'MODIFICACION',
                OLD.valor::TEXT, NEW.valor::TEXT,
                COALESCE(NEW.id_usuario_registro, fn_usuario_sesion()));
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_calificacion_auditoria
    AFTER INSERT OR UPDATE ON calificacion
    FOR EACH ROW
    EXECUTE FUNCTION fn_calificacion_auditoria();


-- ---------------------------------------------------------------------
-- 4.3 trg_auditoria_inmutable — RNF-21
--     La bitácora solo admite inserciones. Ni la aplicación ni un error de
--     programación pueden reescribir la historia.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_auditoria_inmutable()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'RNF-21: la bitácora de auditoría no admite la operación %', TG_OP
        USING ERRCODE = 'insufficient_privilege';
END;
$$;

CREATE TRIGGER trg_auditoria_inmutable
    BEFORE UPDATE OR DELETE ON registro_auditoria
    FOR EACH ROW
    EXECUTE FUNCTION fn_auditoria_inmutable();


-- =====================================================================
-- 5. INACTIVACIÓN LÓGICA (ADR-004)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 5.1 trg_persona_no_borrar y trg_curso_no_borrar — RN-15, RE-10
--     El borrado físico no se permite desde la aplicación. Las claves
--     foráneas con ON DELETE RESTRICT ya lo impedirían para los registros
--     con historial; estos disparadores lo prohíben también para los que
--     todavía no lo tienen, de modo que el procedimiento sea uno solo.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_prohibir_borrado()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION
        'RN-15 (ADR-004): % no se elimina. Cambie su estado a INACTIVO.', TG_TABLE_NAME
        USING ERRCODE = 'insufficient_privilege';
END;
$$;

CREATE TRIGGER trg_persona_no_borrar
    BEFORE DELETE ON persona
    FOR EACH ROW
    EXECUTE FUNCTION fn_prohibir_borrado();

CREATE TRIGGER trg_curso_no_borrar
    BEFORE DELETE ON curso
    FOR EACH ROW
    EXECUTE FUNCTION fn_prohibir_borrado();


-- ---------------------------------------------------------------------
-- 5.2 trg_persona_inactivar — RN-24 y sincronización con la cuenta
--     Un docente con cursos asignados en el período activo no se inactiva
--     sin reasignarlos antes. Al inactivar a cualquier persona, su cuenta
--     de acceso queda inactiva en la misma transacción: es el costo que la
--     Fase 3 anotó al separar Usuario de Persona.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_persona_inactivar()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_cursos INTEGER;
BEGIN
    IF OLD.estado = 'ACTIVO' AND NEW.estado = 'INACTIVO' THEN

        -- RN-24: el docente no se va dejando cursos sin responsable
        SELECT COUNT(*)
          INTO v_cursos
          FROM curso cu
          JOIN periodo_academico pa ON pa.id_periodo = cu.id_periodo
         WHERE cu.id_docente = OLD.id_persona
           AND pa.estado     = 'ACTIVO'
           AND cu.estado    <> 'INACTIVO';

        IF v_cursos > 0 THEN
            RAISE EXCEPTION
                'RN-24: el docente tiene % curso(s) en el período activo. Reasígnelos primero.',
                v_cursos
                USING ERRCODE = 'check_violation';
        END IF;

        UPDATE usuario
           SET estado = 'INACTIVO'
         WHERE id_persona = OLD.id_persona
           AND estado     = 'ACTIVO';

        INSERT INTO registro_auditoria
            (entidad, id_entidad, operacion, valor_anterior, valor_nuevo, id_usuario)
        VALUES ('persona', OLD.id_persona, 'INACTIVACION', 'ACTIVO', 'INACTIVO',
                fn_usuario_sesion());
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_persona_inactivar
    BEFORE UPDATE OF estado ON persona
    FOR EACH ROW
    EXECUTE FUNCTION fn_persona_inactivar();


-- =====================================================================
-- 6. CIERRE DEL PERÍODO
-- =====================================================================

-- ---------------------------------------------------------------------
-- 6.1 fn_cerrar_periodo — RN-12, RN-17, CU-10
--     Traduce el diagrama de actividades de la Figura 14: el período solo
--     se cierra cuando todas las notas están registradas. Al cerrarlo, cada
--     matrícula activa pasa a FINALIZADA con su definitiva y su estado de
--     aprobación congelados, que es el efecto de entrada que la Figura 16
--     documenta para ese estado.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_cerrar_periodo(p_id_periodo BIGINT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_pendientes INTEGER;
    v_cerradas   INTEGER := 0;
    v_fila       RECORD;
    v_definitiva NUMERIC(2,1);
BEGIN
    -- ¿Queda alguna matrícula activa sin todas sus notas?
    SELECT COUNT(*)
      INTO v_pendientes
      FROM matricula m
      JOIN curso cu ON cu.id_curso = m.id_curso
     WHERE cu.id_periodo = p_id_periodo
       AND m.estado      = 'ACTIVA'
       AND NOT fn_matricula_completa(m.id_matricula);

    IF v_pendientes > 0 THEN
        RAISE EXCEPTION
            'No se puede cerrar el período: % matrícula(s) tienen cortes sin calificar',
            v_pendientes
            USING ERRCODE = 'check_violation';
    END IF;

    FOR v_fila IN
        SELECT m.id_matricula
          FROM matricula m
          JOIN curso cu ON cu.id_curso = m.id_curso
         WHERE cu.id_periodo = p_id_periodo
           AND m.estado      = 'ACTIVA'
    LOOP
        v_definitiva := fn_nota_definitiva(v_fila.id_matricula);

        UPDATE matricula
           SET nota_definitiva = v_definitiva,
               -- RN-12: se aprueba con 3.0
               aprobada        = (v_definitiva >= 3.0),
               estado          = 'FINALIZADA'
         WHERE id_matricula = v_fila.id_matricula;

        v_cerradas := v_cerradas + 1;
    END LOOP;

    -- RN-17: a partir de aquí el período es de solo lectura
    UPDATE periodo_academico SET estado = 'CERRADO' WHERE id_periodo = p_id_periodo;
    UPDATE curso SET estado = 'INACTIVO' WHERE id_periodo = p_id_periodo;

    RETURN v_cerradas;
END;
$$;

COMMENT ON FUNCTION fn_cerrar_periodo(BIGINT) IS
  'CU-10: cierra el período, congela las definitivas (RN-12) y deja todo en solo lectura (RN-17).';
