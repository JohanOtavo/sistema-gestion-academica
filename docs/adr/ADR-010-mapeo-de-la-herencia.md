# ADR-010: Tabla por clase para la jerarquía Persona

- **Estado:** Aceptada
- **Fecha:** 2026-10-07
- **Decidido por:** Jannier Johan Otavo
- **Relacionado con:** RN-01, RN-15, Fase 3 (Figura 6), Fase 4

## Contexto

El modelo de clases de la Fase 3 declaró `Persona` como clase abstracta, con `Estudiante` y
`Docente` como especializaciones. El modelo relacional no tiene herencia, así que la Fase 4 tiene
que escoger cómo representarla. Las tres opciones clásicas son una tabla única con columnas
opcionales, una tabla por subtipo con los datos comunes repetidos, o una tabla por clase con la
clave primaria compartida.

La decisión no es cosmética porque **RN-01** exige que el número de documento identifique de manera
única a una persona *sin importar si es estudiante o docente*. Esa regla es la que descarta opciones.

La Fase 3 ya había anotado el problema en su Tabla 13: *"se pierde algo de simplicidad en el mapeo a
tablas, que se resolverá en la Fase 4 al escoger la estrategia de herencia"*.

## Decisión

Usar **tabla por clase con clave primaria compartida**: una tabla `persona` con los atributos
comunes y dos tablas `estudiante` y `docente` cuya clave primaria es también clave foránea hacia
`persona`.

## Consecuencias

Se vuelve más fácil:

- **RN-01 se cumple con una sola restricción `UNIQUE`** sobre `persona.numero_documento`. No hay que
  comparar entre tablas ni programar nada.
- Declarar obligatorios los atributos propios de cada subtipo. `estudiante.fecha_nacimiento` puede
  ser `NOT NULL` porque la columna solo existe para los estudiantes.
- Inactivar de manera uniforme (RN-15, ADR-004): el estado vive en `persona` y vale para los dos
  subtipos.
- Añadir un tercer subtipo en el futuro, por ejemplo un acudiente, sin alterar lo existente.

Se vuelve más difícil:

- Toda consulta de un estudiante o de un docente necesita una unión. El costo se paga una sola vez:
  las vistas `vw_estudiante` y `vw_docente` encapsulan la unión y el resto del sistema las usa como
  si fueran tablas.
- La tabla `persona` admite filas sin subtipo, porque el motor no puede imponer que una fila sea
  obligatoriamente estudiante o docente. En el sistema eso es una ventaja y no un defecto: la cuenta
  del administrador académico es exactamente ese caso, una persona que no es ninguno de los dos.
  Si más adelante hiciera falta prohibirlo para los demás roles, se añadiría un disparador de
  verificación.

## Alternativas consideradas

**Tabla única con columnas opcionales.** Descartada porque obligaría a que
`codigo_estudiante`, `fecha_nacimiento`, `codigo_docente` y `area_conocimiento` admitieran nulos. El
motor dejaría de poder exigir los datos obligatorios de cada subtipo y la validación se trasladaría
por completo al código.

**Tabla por subtipo, con los datos comunes repetidos.** Descartada porque vuelve inaplicable RN-01:
el número de documento tendría que ser único entre dos tablas distintas, lo que no se puede expresar
con una restricción `UNIQUE`. Además duplicaría nueve columnas y la lógica de inactivación.
