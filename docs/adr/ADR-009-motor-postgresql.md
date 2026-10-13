# ADR-009: PostgreSQL como motor de base de datos

- **Estado:** Aceptada
- **Fecha:** 2026-10-07
- **Decidido por:** Jannier Johan Otavo
- **Relacionado con:** ADR-002, ADR-008, RE-02, RE-03, RN-03, RN-04, RN-10, RNF-15, RNF-28, Fase 4

## Contexto

[ADR-002](ADR-002-base-de-datos-relacional.md) decidió que la persistencia fuera relacional, pero
dejó abierto el motor concreto. La Fase 4 ya no puede postergarlo: el entregable incluye un script
SQL ejecutable, y las sentencias de creación, los disparadores y los índices parciales no son
idénticos entre motores.

Tres reglas de negocio del proyecto no se pueden expresar con una restricción `UNIQUE` corriente,
porque la unicidad solo aplica a un subconjunto de las filas:

- **RN-03**: solo un período académico en estado activo. Puede haber muchos cerrados.
- **RN-04**: una sola matrícula activa por estudiante y curso. Puede haber varias canceladas.

Y una tercera, **RN-10**, exige que los porcentajes de los cortes de un curso sumen exactamente
100 %, algo que solo tiene sentido verificar cuando están insertados todos los cortes, no fila por
fila.

La restricción RE-03 pide operar sobre la infraestructura disponible en la institución, sin
servidores dedicados de alto costo.

## Decisión

Usar **PostgreSQL 16 o superior** como motor de base de datos del sistema.

## Consecuencias

Se vuelve más fácil:

- Hacer cumplir RN-03 y RN-04 con **índices únicos parciales**, que el motor impone sin una línea de
  código de aplicación y sin posibilidad de condición de carrera.
- Verificar RN-10 con un **disparador de restricción diferido**, que se evalúa al confirmar la
  transacción y no en cada inserción.
- Cumplir RE-03: la licencia es libre y el motor funciona con holgura en el hardware de la
  institución para el volumen proyectado en RNF-06, que son 5.000 estudiantes y 20 períodos.
- Sostener RNF-15, porque el DDL transaccional permite que incluso los cambios de esquema entren o
  no entren completos.

Se vuelve más difícil:

- Los disparadores quedan escritos en PL/pgSQL, que es específico del motor. Si en el futuro hubiera
  que migrar, habría que reescribirlos. Para acotar ese costo, el esquema de tablas se mantuvo en
  SQL estándar: `GENERATED ALWAYS AS IDENTITY` en lugar de tipos propietarios, y `VARCHAR` con
  `CHECK` en lugar de tipos enumerados nativos.
- El equipo debe administrar un motor más que si usara el que ya conoce.

La sección 8 del entregable de la Fase 4 documenta, regla por regla, qué habría que cambiar para
llevar el esquema a otro motor, que es la forma en que esta decisión sigue respetando RNF-28.

## Alternativas consideradas

**MySQL 8.** Descartada por los índices únicos parciales: MySQL no los tiene, de modo que RN-03 y
RN-04 tendrían que implementarse con disparadores o con columnas calculadas artificiales, que es más
código y más frágil. Sus restricciones `CHECK` sí funcionan desde la versión 8.0.16.

**SQL Server Express.** Descartada por el límite de 10 GB por base de datos y por la dependencia de
una plataforma concreta. Técnicamente habría servido: tiene índices filtrados, que son el
equivalente de los índices parciales.

**SQLite.** Descartada por RNF-05: no está diseñada para 50 sesiones concurrentes con escrituras, y
la semana de matrícula es justamente un pico de escritura concurrente.
