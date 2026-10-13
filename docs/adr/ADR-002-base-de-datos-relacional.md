# ADR-002: Base de datos relacional

- **Estado:** Aceptada
- **Fecha:** 2026-08-20
- **Decidido por:** Jannier Johan Otavo
- **Relacionado con:** RE-02, RF-30, RF-36, RNF-15

## Contexto

La operación central del sistema es la matrícula (RF-30). Registrar una matrícula implica dos
escrituras que deben ocurrir juntas o no ocurrir: crear el registro de la matrícula e incrementar el
contador de matriculados del curso. Si solo se ejecuta la primera, el curso queda con cupos que en
realidad no tiene; si solo se ejecuta la segunda, se pierde un cupo sin que nadie lo ocupe. Lo mismo
sucede al cancelar (RF-36).

Además, el dominio es fuertemente relacional: estudiante, curso, período, matrícula y calificación
están conectados por claves y por reglas de integridad como RN-04, RN-05 y RN-20, que exigen
unicidad sobre combinaciones de campos.

El volumen es modesto: unos 600 estudiantes, 35 docentes y 40 cursos por período.

## Decisión

Usar un motor de base de datos relacional con soporte de transacciones ACID y de restricciones de
unicidad e integridad referencial declaradas en el esquema.

## Consecuencias

Se vuelve más fácil: garantizar RNF-15 apoyándonos en las transacciones del motor en lugar de
programarlas a mano; hacer cumplir RN-01, RN-04 y RN-20 con restricciones del esquema, de modo que
la regla se sostenga incluso si un error de programación la omite en el código; y diseñar la Fase 4
con un modelo entidad-relación estándar.

Se vuelve más difícil: cambiar la forma de los datos exigirá migraciones de esquema; y si en el
futuro apareciera un requerimiento de escala masiva, el modelo relacional obligaría a un rediseño.
Este último riesgo es despreciable con el volumen proyectado en RNF-06.

## Alternativas consideradas

**Base de datos documental.** Descartada porque no ofrece de forma nativa las garantías
transaccionales entre documentos distintos que exige la matrícula, y porque el dominio es
naturalmente tabular.

**Archivos o hojas de cálculo con una capa de programación encima.** Descartada de entrada: es
exactamente el problema que el proyecto busca resolver.
