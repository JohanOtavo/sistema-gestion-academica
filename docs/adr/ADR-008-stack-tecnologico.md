# ADR-008: Conjunto tecnológico de construcción

- **Estado:** **Pendiente** — debe decidirse antes de iniciar el Sprint 1
- **Fecha de registro:** 2026-08-26
- **Decidido por:** por definir
- **Relacionado con:** RE-03, RE-05, RE-06, RG-5, Fase 6

## Contexto

Las fases 1 y 2 son de análisis y no exigen elegir tecnología. La Fase 6 sí. Dejamos la decisión
registrada como pendiente porque el riesgo RG-5 de la Fase 1 —que el equipo no domine la tecnología
elegida— tiene probabilidad media e impacto medio, y la única mitigación acordada es decidir el
conjunto tecnológico temprano y hacer una prueba técnica antes del primer sprint.

Las restricciones que acotan la elección ya están fijadas: aplicación web (ADR-001), base de datos
relacional (ADR-002), tres capas (ADR-005) y operación sobre la infraestructura disponible en la
institución, sin servidores dedicados costosos (RE-03).

## Decisión

Pendiente **en lo que respecta al lenguaje y al marco de trabajo**. La parte de persistencia ya se
resolvió: la Fase 4 necesitaba un script SQL ejecutable y por eso el motor quedó decidido en
[ADR-009](ADR-009-motor-postgresql.md), que fija PostgreSQL 16. Lo que sigue abierto es el lenguaje
del servidor y el marco de trabajo de la capa de presentación.

La tomaremos aplicando estos criterios, en orden de peso:

1. **Dominio actual de quien desarrolla.** Una sola persona con cuatro sprints; aprender un ecosistema
   nuevo consumiría el tiempo de construcción.
2. **Soporte transaccional y de restricciones** en el acceso a datos, por ADR-002.
3. **Facilidad de despliegue** sobre la infraestructura de la institución, por RE-03.
4. **Capacidad de escribir pruebas automatizadas** sobre la capa de negocio, por RNF-26.

## Consecuencias

Mientras la decisión siga pendiente, las fases 3 y 4 deben mantenerse independientes del lenguaje:
el diagrama de clases y el modelo de datos se elaboran en notación estándar, sin apoyarse en
construcciones propias de un lenguaje de programación.

El modelo de datos sí depende ya de un motor, por ADR-009. El acoplamiento se acotó a los
disparadores en PL/pgSQL: las tablas, las claves y las restricciones se escribieron en SQL estándar
precisamente para que la decisión del lenguaje del servidor siga siendo libre.

## Alternativas consideradas

Por evaluar durante la Fase 5, junto con una prueba técnica que levante una pantalla, una operación
de negocio y una consulta a la base de datos de extremo a extremo. El resultado de esa prueba se
registrará aquí y el estado del ADR pasará a Aceptada.
