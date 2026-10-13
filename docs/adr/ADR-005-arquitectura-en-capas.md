# ADR-005: Arquitectura en tres capas

- **Estado:** Aceptada
- **Fecha:** 2026-08-20
- **Decidido por:** Jannier Johan Otavo
- **Relacionado con:** RNF-24, RNF-26, RNF-28

## Contexto

Las reglas de negocio son el centro de este sistema: 27 reglas condicionan casi todos los
requerimientos funcionales, y varias de ellas —RN-04, RN-05, RN-11, RN-13— son las que dan valor al
producto. RNF-26 nos obliga a cubrirlas con pruebas automatizadas.

Una regla escrita dentro del código de una pantalla no se puede probar sin simular la pantalla, y
tiende a duplicarse cuando la misma regla hace falta en otro lugar. Por ejemplo, la validación de
cupo (RN-05) interviene en la matrícula administrativa (RF-30) y también en la autogestión del
estudiante (RF-56).

## Decisión

Separar el sistema en tres capas: presentación, lógica de negocio y acceso a datos. Las reglas de
negocio viven exclusivamente en la capa intermedia. La capa de presentación no contiene sentencias
SQL ni decisiones de negocio.

## Consecuencias

Se vuelve más fácil: probar las reglas sin interfaz, que es lo que exige RNF-26; reutilizar una
misma validación desde dos puntos de entrada distintos; y cambiar de motor de base de datos tocando
solo la capa inferior, según RNF-28.

Se vuelve más difícil: hay que escribir más código de traspaso entre capas, lo que en operaciones
triviales se siente como ceremonia; y el equipo debe resistir la tentación de tomar el atajo de
consultar la base de datos directamente desde una pantalla cuando el sprint va ajustado.

Adoptamos como verificación concreta de RNF-24 una regla simple: si aparece una sentencia SQL en la
capa de presentación, el pull request no se aprueba.

## Alternativas consideradas

**Todo en una sola capa.** Es más rápido al comienzo y por eso resulta tentador con una sola persona y
cuatro sprints. Descartada porque haría imposible cumplir RNF-26 y volvería a duplicar las reglas,
que es la causa raíz del problema original del proyecto.

**Arquitectura hexagonal o por puertos y adaptadores.** Aporta un aislamiento aún mayor, pero su
costo de estructura no se justifica para el tamaño de este sistema ni para el nivel de experiencia
actual del equipo.
