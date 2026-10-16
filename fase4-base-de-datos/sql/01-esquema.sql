-- =====================================================================
-- Sistema de Gestión Académica (SGA) — Grupo 6
-- Fase 4: Base de datos
-- Archivo 1 de 5: esquema físico (DDL)
--
-- Motor:        PostgreSQL 16 o superior (ADR-009)
-- Codificación: UTF-8
-- Orden de ejecución:
--   01-esquema.sql  ->  02-reglas-de-negocio.sql  ->  03-indices-y-vistas.sql
--   ->  04-datos-de-prueba.sql  ->  05-verificacion.sql
--
-- Convención de nombres (sección 6.1 del entregable):
--   tabla          singular, minúscula, guion bajo    persona
--   clave primaria id_<tabla>                         id_persona
--   clave foránea  id_<tabla referenciada>            id_curso
--   restricciones  pk_ uq_ fk_ ck_                    ck_curso_creditos
--   índices        ix_<tabla>_<columnas>              ix_matricula_curso
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Esquema
-- ---------------------------------------------------------------------
DROP SCHEMA IF EXISTS sga CASCADE;
CREATE SCHEMA sga;
SET search_path TO sga, public;

COMMENT ON SCHEMA sga IS
  'Sistema de Gestión Académica — Grupo 6. Modelo físico de la Fase 4.';


-- =====================================================================
-- 1. MÓDULOS M1 Y M2: PERSONAS, CUENTAS Y SEGURIDAD
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1.1 persona — superclase de estudiante y docente (ADR-010)
--     RN-01 documento único · RN-15 no se elimina, se inactiva
-- ---------------------------------------------------------------------
CREATE TABLE persona (
    id_persona        BIGINT       GENERATED ALWAYS AS IDENTITY,
    tipo_documento    VARCHAR(2)   NOT NULL,
    numero_documento  VARCHAR(20)  NOT NULL,
    nombres           VARCHAR(60)  NOT NULL,
    apellidos         VARCHAR(60)  NOT NULL,
    correo            VARCHAR(120) NOT NULL,
    telefono          VARCHAR(20),
    estado            VARCHAR(10)  NOT NULL DEFAULT 'ACTIVO',
    fecha_registro    DATE         NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT pk_persona            PRIMARY KEY (id_persona),
    -- RN-01: el número de documento identifica de manera única a una persona
    CONSTRAINT uq_persona_documento  UNIQUE (numero_documento),
    -- Supuesto S-1 de la Fase 2: cada persona dispone de un correo propio
    CONSTRAINT uq_persona_correo     UNIQUE (correo),
    CONSTRAINT ck_persona_tipo_doc   CHECK (tipo_documento IN ('CC', 'TI', 'CE', 'PA')),
    CONSTRAINT ck_persona_estado     CHECK (estado IN ('ACTIVO', 'INACTIVO')),
    CONSTRAINT ck_persona_correo     CHECK (position('@' IN correo) > 1
                                        AND correo LIKE '%.%'
                                        AND correo NOT LIKE '% %'),
    CONSTRAINT ck_persona_nombres    CHECK (btrim(nombres) <> '' AND btrim(apellidos) <> '')
);

COMMENT ON TABLE  persona IS 'Datos de identificación y contacto comunes a estudiantes y docentes.';
COMMENT ON COLUMN persona.numero_documento IS 'RN-01: único en todo el sistema, sin importar el subtipo.';
COMMENT ON COLUMN persona.estado IS 'RN-15 y ADR-004: la baja es lógica; nunca se borra la fila.';


-- ---------------------------------------------------------------------
-- 1.2 estudiante — subclase de persona con clave primaria compartida
-- ---------------------------------------------------------------------
CREATE TABLE estudiante (
    id_persona          BIGINT      NOT NULL,
    codigo_estudiante   VARCHAR(15) NOT NULL,
    fecha_nacimiento    DATE        NOT NULL,
    fecha_ingreso       DATE        NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT pk_estudiante          PRIMARY KEY (id_persona),
    CONSTRAINT fk_estudiante_persona  FOREIGN KEY (id_persona)
        REFERENCES persona (id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_estudiante_codigo   UNIQUE (codigo_estudiante),
    CONSTRAINT ck_estudiante_nacim    CHECK (fecha_nacimiento < CURRENT_DATE),
    CONSTRAINT ck_estudiante_ingreso  CHECK (fecha_ingreso > fecha_nacimiento)
);

COMMENT ON TABLE estudiante IS
  'ADR-010: tabla por clase, con la clave primaria compartida con persona.';


-- ---------------------------------------------------------------------
-- 1.3 docente — subclase de persona con clave primaria compartida
-- ---------------------------------------------------------------------
CREATE TABLE docente (
    id_persona          BIGINT      NOT NULL,
    codigo_docente      VARCHAR(15) NOT NULL,
    area_conocimiento   VARCHAR(60) NOT NULL,
    fecha_vinculacion   DATE        NOT NULL DEFAULT CURRENT_DATE,

    CONSTRAINT pk_docente         PRIMARY KEY (id_persona),
    CONSTRAINT fk_docente_persona FOREIGN KEY (id_persona)
        REFERENCES persona (id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_docente_codigo  UNIQUE (codigo_docente)
);


-- ---------------------------------------------------------------------
-- 1.4 usuario — cuenta de acceso, uno a uno con persona
--     RN-02 correo único · RN-21 longitud mínima · RNF-17 solo el resumen
-- ---------------------------------------------------------------------
CREATE TABLE usuario (
    id_usuario                BIGINT       GENERATED ALWAYS AS IDENTITY,
    id_persona                BIGINT       NOT NULL,
    correo                    VARCHAR(120) NOT NULL,
    hash_contrasena           CHAR(64)     NOT NULL,
    sal                       CHAR(32)     NOT NULL,
    rol                       VARCHAR(15)  NOT NULL,
    estado                    VARCHAR(10)  NOT NULL DEFAULT 'ACTIVO',
    debe_cambiar_contrasena   BOOLEAN      NOT NULL DEFAULT TRUE,
    ultimo_acceso             TIMESTAMP,
    fecha_creacion            TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_usuario          PRIMARY KEY (id_usuario),
    -- Multiplicidad 1 a 1 de la Figura 6: una sola cuenta por persona
    CONSTRAINT uq_usuario_persona  UNIQUE (id_persona),
    -- RN-02: el correo es el nombre de acceso y es único
    CONSTRAINT uq_usuario_correo   UNIQUE (correo),
    CONSTRAINT fk_usuario_persona  FOREIGN KEY (id_persona)
        REFERENCES persona (id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_usuario_rol      CHECK (rol IN ('ADMINISTRADOR', 'DOCENTE', 'ESTUDIANTE')),
    CONSTRAINT ck_usuario_estado   CHECK (estado IN ('ACTIVO', 'INACTIVO')),
    CONSTRAINT ck_usuario_correo   CHECK (position('@' IN correo) > 1
                                      AND correo NOT LIKE '% %')
);

COMMENT ON COLUMN usuario.hash_contrasena IS
  'RNF-17 y ADR-007: resumen criptográfico en hexadecimal. Nunca la contraseña.';
COMMENT ON COLUMN usuario.sal IS 'ADR-007: sal única por usuario, en hexadecimal.';
COMMENT ON COLUMN usuario.debe_cambiar_contrasena IS
  'Flujo alterno 7a de CU-01: obliga el cambio en el primer ingreso.';


-- ---------------------------------------------------------------------
-- 1.5 evento_seguridad — intentos fallidos y accesos denegados (RN-23)
-- ---------------------------------------------------------------------
CREATE TABLE evento_seguridad (
    id_evento       BIGINT       GENERATED ALWAYS AS IDENTITY,
    tipo            VARCHAR(25)  NOT NULL,
    correo_intento  VARCHAR(120),
    id_usuario      BIGINT,
    operacion       VARCHAR(60),
    direccion_ip    VARCHAR(45),
    fecha_hora      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_evento_seguridad PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_usuario   FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_evento_tipo      CHECK (tipo IN
        ('AUTENTICACION_FALLIDA', 'ACCESO_DENEGADO', 'SESION_EXPIRADA'))
);

COMMENT ON COLUMN evento_seguridad.id_usuario IS
  'Nulo cuando el correo del intento no corresponde a ninguna cuenta (excepción 4a de CU-01).';


-- ---------------------------------------------------------------------
-- 1.6 solicitud_restablecimiento — RF-58 a RF-60
--     RN-28 un solo uso y vencimiento · RN-30 tope por hora
--
--     Del enlace se guarda unicamente su resumen criptografico, nunca el
--     identificador en claro. El razonamiento es el mismo de ADR-007 con
--     las contrasenas: un enlace almacenado tal cual es una credencial
--     activa, y quien leyera la tabla podria usarla.
-- ---------------------------------------------------------------------
CREATE TABLE solicitud_restablecimiento (
    id_solicitud       BIGINT    GENERATED ALWAYS AS IDENTITY,
    id_usuario         BIGINT    NOT NULL,
    hash_enlace        CHAR(64)  NOT NULL,
    fecha_creacion     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento  TIMESTAMP NOT NULL,
    fecha_uso          TIMESTAMP,
    direccion_ip       VARCHAR(45),

    CONSTRAINT pk_solicitud_restablecimiento PRIMARY KEY (id_solicitud),
    -- Composición con usuario: la solicitud no sobrevive a la cuenta
    CONSTRAINT fk_solicitud_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    -- El mismo enlace no puede existir dos veces
    CONSTRAINT uq_solicitud_enlace UNIQUE (hash_enlace),
    -- RN-28: el vencimiento siempre es posterior a la creación
    CONSTRAINT ck_solicitud_vencimiento CHECK (fecha_vencimiento > fecha_creacion),
    -- Una solicitud no se puede haber usado antes de existir
    CONSTRAINT ck_solicitud_uso CHECK (fecha_uso IS NULL OR fecha_uso >= fecha_creacion)
);

COMMENT ON TABLE solicitud_restablecimiento IS
  'RF-58 a RF-60: enlaces de restablecimiento de contraseña, de un solo uso (RN-28).';
COMMENT ON COLUMN solicitud_restablecimiento.hash_enlace IS
  'Resumen criptográfico del identificador del enlace. Nunca el enlace en claro.';
COMMENT ON COLUMN solicitud_restablecimiento.fecha_uso IS
  'Nula mientras el enlace esté sin usar. Al fijarse, el enlace deja de servir.';


-- =====================================================================
-- 2. MÓDULO M3: OFERTA ACADÉMICA
-- =====================================================================

-- ---------------------------------------------------------------------
-- 2.1 periodo_academico
--     RN-03 un solo período activo · RN-19 fecha de fin posterior al inicio
-- ---------------------------------------------------------------------
CREATE TABLE periodo_academico (
    id_periodo    BIGINT      GENERATED ALWAYS AS IDENTITY,
    codigo        VARCHAR(10) NOT NULL,
    nombre        VARCHAR(60) NOT NULL,
    fecha_inicio  DATE        NOT NULL,
    fecha_fin     DATE        NOT NULL,
    estado        VARCHAR(10) NOT NULL DEFAULT 'PLANEADO',

    CONSTRAINT pk_periodo         PRIMARY KEY (id_periodo),
    CONSTRAINT uq_periodo_codigo  UNIQUE (codigo),
    CONSTRAINT ck_periodo_estado  CHECK (estado IN ('PLANEADO', 'ACTIVO', 'CERRADO')),
    -- RN-19: la fecha de fin debe ser posterior a la de inicio
    CONSTRAINT ck_periodo_fechas  CHECK (fecha_fin > fecha_inicio)
);

-- RN-03: un único período en estado ACTIVO en todo instante. El índice único
-- parcial lo impone el motor, no el código de la aplicación.
CREATE UNIQUE INDEX uq_periodo_unico_activo
    ON periodo_academico (estado)
    WHERE estado = 'ACTIVO';

COMMENT ON INDEX uq_periodo_unico_activo IS
  'RN-03: índice único parcial. Impide la existencia de un segundo período ACTIVO.';


-- ---------------------------------------------------------------------
-- 2.2 curso
--     RN-05 cupo · RN-20 código único por período · RN-25 enteros positivos
--     RN-26 el cupo no baja del número de matriculados
-- ---------------------------------------------------------------------
CREATE TABLE curso (
    id_curso      BIGINT      GENERATED ALWAYS AS IDENTITY,
    id_periodo    BIGINT      NOT NULL,
    id_docente    BIGINT,
    codigo        VARCHAR(15) NOT NULL,
    nombre        VARCHAR(80) NOT NULL,
    creditos      SMALLINT    NOT NULL,
    cupo_maximo   SMALLINT    NOT NULL,
    matriculados  SMALLINT    NOT NULL DEFAULT 0,
    estado        VARCHAR(12) NOT NULL DEFAULT 'CREADO',

    CONSTRAINT pk_curso           PRIMARY KEY (id_curso),
    -- RN-20: el código es único dentro del período, no en todo el sistema
    CONSTRAINT uq_curso_codigo    UNIQUE (id_periodo, codigo),
    CONSTRAINT fk_curso_periodo   FOREIGN KEY (id_periodo)
        REFERENCES periodo_academico (id_periodo) ON DELETE RESTRICT ON UPDATE CASCADE,
    -- Multiplicidad 0..1 de la Figura 7: un curso recién creado no tiene docente
    CONSTRAINT fk_curso_docente   FOREIGN KEY (id_docente)
        REFERENCES docente (id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_curso_estado    CHECK (estado IN ('CREADO', 'DISPONIBLE', 'INACTIVO')),
    -- RN-25: créditos y cupo son enteros positivos
    CONSTRAINT ck_curso_creditos  CHECK (creditos > 0 AND creditos <= 10),
    CONSTRAINT ck_curso_cupo      CHECK (cupo_maximo > 0),
    -- RN-05 y RN-26: el contador nunca excede el cupo ni baja de cero
    CONSTRAINT ck_curso_ocupacion CHECK (matriculados BETWEEN 0 AND cupo_maximo)
);

COMMENT ON COLUMN curso.matriculados IS
  'Desnormalización deliberada (Tabla 13 de la Fase 3): contador mantenido por trigger para que RN-05 se valide de forma inmediata y transaccional (RNF-15).';
COMMENT ON COLUMN curso.id_docente IS
  'Admite nulos por la multiplicidad 0..1 entre docente y curso.';


-- ---------------------------------------------------------------------
-- 2.3 corte — composición con curso: se elimina con él
--     RN-10 los porcentajes de los cortes de un curso suman 100 %
-- ---------------------------------------------------------------------
CREATE TABLE corte (
    id_corte     BIGINT       GENERATED ALWAYS AS IDENTITY,
    id_curso     BIGINT       NOT NULL,
    numero       SMALLINT     NOT NULL,
    porcentaje   NUMERIC(5,2) NOT NULL,
    descripcion  VARCHAR(60),

    CONSTRAINT pk_corte            PRIMARY KEY (id_corte),
    CONSTRAINT uq_corte_numero     UNIQUE (id_curso, numero),
    -- Composición de la Figura 7: el corte no existe sin su curso
    CONSTRAINT fk_corte_curso      FOREIGN KEY (id_curso)
        REFERENCES curso (id_curso) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_corte_numero     CHECK (numero BETWEEN 1 AND 10),
    CONSTRAINT ck_corte_porcentaje CHECK (porcentaje > 0 AND porcentaje <= 100)
);

COMMENT ON TABLE corte IS
  'Composición con curso: ON DELETE CASCADE traduce el rombo relleno del modelo UML.';


-- =====================================================================
-- 3. MÓDULO M4: MATRÍCULA
-- =====================================================================

-- ---------------------------------------------------------------------
-- 3.1 matricula
--     RN-04 sin duplicados · RN-06 estudiante activo · RN-07 período activo
--     RN-14 máximo siete activas · RN-16 la cancelación libera el cupo
-- ---------------------------------------------------------------------
CREATE TABLE matricula (
    id_matricula            BIGINT       GENERATED ALWAYS AS IDENTITY,
    id_estudiante           BIGINT       NOT NULL,
    id_curso                BIGINT       NOT NULL,
    fecha_matricula         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado                  VARCHAR(12)  NOT NULL DEFAULT 'ACTIVA',
    id_usuario_registro     BIGINT       NOT NULL,
    fecha_cancelacion       TIMESTAMP,
    id_usuario_cancelacion  BIGINT,
    motivo_cancelacion      VARCHAR(120),
    nota_definitiva         NUMERIC(2,1),
    aprobada                BOOLEAN,

    CONSTRAINT pk_matricula            PRIMARY KEY (id_matricula),
    CONSTRAINT fk_matricula_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES estudiante (id_persona) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_matricula_curso      FOREIGN KEY (id_curso)
        REFERENCES curso (id_curso) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_matricula_usuario    FOREIGN KEY (id_usuario_registro)
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_matricula_cancela    FOREIGN KEY (id_usuario_cancelacion)
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_matricula_estado     CHECK (estado IN ('ACTIVA', 'CANCELADA', 'FINALIZADA')),
    -- RN-09 y RN-27: la definitiva vive en la misma escala y con un decimal
    CONSTRAINT ck_matricula_nota       CHECK (nota_definitiva IS NULL
                                           OR (nota_definitiva >= 0.0 AND nota_definitiva <= 5.0)),
    -- Coherencia con el diagrama de estados (Figura 16): la cancelación deja rastro
    CONSTRAINT ck_matricula_cancelada  CHECK (
        (estado = 'CANCELADA') = (fecha_cancelacion IS NOT NULL)),
    -- Al finalizar hay definitiva y estado de aprobación; mientras esté activa, no
    CONSTRAINT ck_matricula_finalizada CHECK (
        estado <> 'FINALIZADA' OR (nota_definitiva IS NOT NULL AND aprobada IS NOT NULL))
);

-- RN-04: no se admiten dos matrículas ACTIVAS del mismo estudiante en el mismo
-- curso. Como el curso pertenece a un único período, la restricción cubre
-- también el período, sin necesidad de duplicar la columna.
CREATE UNIQUE INDEX uq_matricula_activa
    ON matricula (id_estudiante, id_curso)
    WHERE estado = 'ACTIVA';

COMMENT ON INDEX uq_matricula_activa IS
  'RN-04: índice único parcial. Permite rematricular después de una cancelación.';
COMMENT ON COLUMN matricula.nota_definitiva IS
  'Instantánea calculada al finalizar (Figura 16). Mientras la matrícula está ACTIVA la definitiva se obtiene de la vista vw_nota_definitiva.';


-- =====================================================================
-- 4. MÓDULO M5: CALIFICACIONES Y AUDITORÍA
-- =====================================================================

-- ---------------------------------------------------------------------
-- 4.1 calificacion — composición con matricula
--     RN-09 rango 0.0 a 5.0 · RN-17 solo lectura al cerrar · RN-18 auditoría
--
--     El estado PENDIENTE del diagrama de la Figura 17 no se almacena: se
--     representa por la ausencia de fila. Así una nota no registrada nunca
--     se confunde con un 0.0.
-- ---------------------------------------------------------------------
CREATE TABLE calificacion (
    id_calificacion      BIGINT       GENERATED ALWAYS AS IDENTITY,
    id_matricula         BIGINT       NOT NULL,
    id_corte             BIGINT       NOT NULL,
    valor                NUMERIC(2,1) NOT NULL,
    estado               VARCHAR(12)  NOT NULL DEFAULT 'REGISTRADA',
    id_usuario_registro  BIGINT       NOT NULL,
    fecha_registro       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_modificacion   TIMESTAMP,

    CONSTRAINT pk_calificacion           PRIMARY KEY (id_calificacion),
    -- Una sola nota por matrícula y corte
    CONSTRAINT uq_calificacion_corte     UNIQUE (id_matricula, id_corte),
    -- Composición de la Figura 7: la calificación no sobrevive a su matrícula
    CONSTRAINT fk_calificacion_matricula FOREIGN KEY (id_matricula)
        REFERENCES matricula (id_matricula) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_calificacion_corte     FOREIGN KEY (id_corte)
        REFERENCES corte (id_corte) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_calificacion_usuario   FOREIGN KEY (id_usuario_registro)
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    -- RN-09: entre 0.0 y 5.0; el tipo NUMERIC(2,1) ya impone el único decimal
    CONSTRAINT ck_calificacion_valor     CHECK (valor >= 0.0 AND valor <= 5.0),
    CONSTRAINT ck_calificacion_estado    CHECK (estado IN ('REGISTRADA', 'CORREGIDA', 'BLOQUEADA'))
);

COMMENT ON COLUMN calificacion.valor IS
  'RN-09: escala de 0.0 a 5.0. El tipo NUMERIC(2,1) impone el máximo de un decimal.';
COMMENT ON TABLE calificacion IS
  'La ausencia de fila significa PENDIENTE (Figura 17). Un 0.0 es una nota real.';


-- ---------------------------------------------------------------------
-- 4.2 registro_auditoria — RN-18 · RNF-20 · RNF-21
--     Tabla de solo inserción: el trigger trg_auditoria_inmutable del
--     archivo 02 impide actualizarla y borrarla.
-- ---------------------------------------------------------------------
CREATE TABLE registro_auditoria (
    id_registro      BIGINT       GENERATED ALWAYS AS IDENTITY,
    entidad          VARCHAR(30)  NOT NULL,
    id_entidad       BIGINT       NOT NULL,
    operacion        VARCHAR(15)  NOT NULL,
    valor_anterior   VARCHAR(255),
    valor_nuevo      VARCHAR(255),
    id_usuario       BIGINT,
    fecha_hora       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_registro_auditoria  PRIMARY KEY (id_registro),
    CONSTRAINT fk_auditoria_usuario   FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_auditoria_operacion CHECK (operacion IN
        ('INSERCION', 'MODIFICACION', 'INACTIVACION'))
);

COMMENT ON TABLE registro_auditoria IS
  'RNF-21: bitácora inmutable. Solo admite INSERT; UPDATE y DELETE se rechazan.';
COMMENT ON COLUMN registro_auditoria.id_usuario IS
  'Nulo únicamente cuando el cambio lo produce un proceso del sistema sin sesión.';
