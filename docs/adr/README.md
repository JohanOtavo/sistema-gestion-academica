# Decisiones de arquitectura (ADR)

Un **ADR** (*Architecture Decision Record*) registra una decisión técnica difícil de revertir, junto
con el contexto en que se tomó y las alternativas que se descartaron. Sirve para responder, meses
después, la pregunta que siempre aparece: *¿por qué esto se hizo así?*

Registramos aquí solo las decisiones que cumplen dos condiciones: **son costosas de revertir** y
**afectan a más de un módulo**. Las decisiones reversibles en una tarde no llevan ADR.

## Índice

| ADR | Decisión | Estado | Origen |
|---|---|---|---|
| [ADR-001](ADR-001-aplicacion-web.md) | Aplicación web adaptable en lugar de aplicación móvil nativa | Aceptada | RE-01, RNF-11 |
| [ADR-002](ADR-002-base-de-datos-relacional.md) | Base de datos relacional | Aceptada | RE-02, RNF-15 |
| [ADR-003](ADR-003-autorizacion-en-servidor.md) | Autorización verificada en el servidor | Aceptada | RNF-19, RN-08, RN-23 |
| [ADR-004](ADR-004-inactivacion-logica.md) | Inactivación lógica en lugar de borrado físico | Aceptada | RN-15 |
| [ADR-005](ADR-005-arquitectura-en-capas.md) | Arquitectura en tres capas | Aceptada | RNF-24, RNF-28 |
| [ADR-006](ADR-006-diagramas-como-codigo.md) | Diagramas como código con PlantUML | Aceptada | Decisión del equipo |
| [ADR-007](ADR-007-almacenamiento-de-contrasenas.md) | Contraseñas con función de resumen y sal, y canal cifrado | Aceptada | RNF-17, RNF-22 |
| [ADR-008](ADR-008-stack-tecnologico.md) | Conjunto tecnológico de construcción | **Pendiente** | RE-03, Fase 6 |
| [ADR-009](ADR-009-motor-postgresql.md) | PostgreSQL como motor de base de datos | Aceptada | ADR-002, RN-03, RN-04, RN-10 |
| [ADR-010](ADR-010-mapeo-de-la-herencia.md) | Tabla por clase para la jerarquía Persona | Aceptada | RN-01, Fase 3 |

## Estados posibles

- **Propuesta**: escrita, aún no discutida por el equipo.
- **Pendiente**: hay que decidirla antes de una fecha o hito.
- **Aceptada**: vigente. Es la que se sigue.
- **Reemplazada por ADR-XXX**: ya no se sigue, pero se conserva porque explica el pasado.

Un ADR aceptado **no se edita ni se borra** cuando cambia la decisión: se escribe uno nuevo que lo
reemplaza y se actualiza el estado del anterior. El historial de decisiones es parte del valor.

## Plantilla

```markdown
# ADR-NNN: Título de la decisión

- **Estado:** Propuesta | Pendiente | Aceptada | Reemplazada por ADR-XXX
- **Fecha:** AAAA-MM-DD
- **Decidido por:** nombres
- **Relacionado con:** RF, RNF, RN o restricciones que la originan

## Contexto

Qué problema o fuerza nos obliga a decidir. Hechos, no opiniones.

## Decisión

Qué decidimos hacer, en una frase que empiece con un verbo.

## Consecuencias

Qué se vuelve más fácil y qué se vuelve más difícil. Las dos cosas, siempre.

## Alternativas consideradas

Qué más evaluamos y por qué no lo escogimos.
```
