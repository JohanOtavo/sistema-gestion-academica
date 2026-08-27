# ADR-004: Inactivación lógica en lugar de borrado físico

- **Estado:** Aceptada
- **Fecha:** 2026-08-20
- **Decidido por:** Jannier Johan Otavo, Sergio David Vargas
- **Relacionado con:** RN-15, RE-10, RF-06, RF-16, RF-18, RF-27

## Contexto

El registro académico es información que la institución debe conservar (RE-10). Un estudiante que se
retira sigue teniendo un historial de notas que puede necesitar años después, y un curso cerrado
sigue siendo la referencia de las calificaciones de quienes lo cursaron.

Al mismo tiempo, esos registros no deben seguir apareciendo en las listas de clase ni en las
matrículas nuevas: el dolor D-3 de la Fase 1 es precisamente que hoy las listas contienen nombres de
personas que ya no asisten.

## Decisión

No eliminar físicamente personas ni cursos con historial académico. En su lugar, marcarlos como
inactivos: dejan de aparecer en las operaciones vigentes y conservan todos sus registros asociados.

## Consecuencias

Se vuelve más fácil: cumplir RE-10 sin procedimientos adicionales; reconstruir el historial de
cualquier estudiante; y evitar los errores de integridad referencial que produciría borrar una
persona que tiene matrículas y notas.

Se vuelve más difícil: toda consulta debe filtrar explícitamente por estado, y olvidarlo produce
listados con registros que no deberían aparecer; la base de datos crece de forma monótona; y hay que
decidir caso por caso qué operaciones se bloquean para un registro inactivo, como lo hace RN-06 al
impedir matricular a un estudiante inactivo.

## Alternativas consideradas

**Borrado físico con copia previa a una tabla histórica.** Descartada porque duplica el modelo de
datos: cada entidad necesitaría su tabla espejo, y las consultas de historial tendrían que unir
ambas.

**Borrado físico sin más.** Descartada porque contradice RE-10 y haría irrecuperable el historial
académico ante un borrado equivocado.
