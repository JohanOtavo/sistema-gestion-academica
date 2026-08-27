# Sistema de Gestión Académica (SGA)

Trabajo integrador — **Grupo 6**. Sistema de información web para centralizar la gestión académica
de una institución educativa: estudiantes, docentes, cursos, matrículas y calificaciones.

**Integrantes:** Jannier Johan Otavo · Sergio David Vargas

---

## El problema

La institución administra su información académica en hojas de cálculo independientes, formatos en
papel y la memoria de las personas. La misma información existe en varios lugares y ninguna copia
coincide con otra: la consolidación de notas toma semanas y no se puede responder con certeza
cuántos estudiantes hay matriculados en un curso o cuál es el promedio real de un estudiante.

El objetivo del proyecto es construir una **fuente única de verdad** con control de acceso por rol.

---

## Fases del trabajo

| Fase | Etapa | Entregable | Estado |
|------|-------|------------|--------|
| 1 | Épica y Stories | Épicas + historias de usuario | ✅ Completada |
| 2 | Requerimientos | Documento de requerimientos | ✅ Completada |
| 3 | Diagramas UML | Casos de uso, clases, secuencia, actividades | ⏳ Pendiente |
| 4 | Base de datos | Modelo ER/UML + script SQL | ⏳ Pendiente |
| 5 | Mockup / Prototipo | Prototipo navegable | ⏳ Pendiente |
| 6 | Programa funcional | MVP funcional | ⏳ Pendiente |

---

## Cómo trabajamos

| Documento | Para qué sirve |
|---|---|
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Convención de commits, ramas, pull requests y manejo de los `.docx` |
| [`docs/adr/`](docs/adr/) | Decisiones de arquitectura: por qué el sistema es como es |
| [`docs/seguimiento/velocidad.md`](docs/seguimiento/velocidad.md) | Registro de velocidad por sprint y replanificación |
| [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/) | Plantillas de historia de usuario, tarea técnica y reporte de error |

Los commits siguen **Conventional Commits** en español: `tipo(alcance): descripción`. Toda rama
entra a `main` por pull request revisado por el otro integrante, que es como cumplimos el criterio
de la Definición de Terminado.

---

## Fase 1 — Épicas e historias de usuario

📁 [`fase1-epicas-historias/`](fase1-epicas-historias/)

| Archivo | Descripción |
|---|---|
| [`Fase1-Epicas-e-Historias-SGA-APA7.docx`](fase1-epicas-historias/Fase1-Epicas-e-Historias-SGA-APA7.docx) | Documento formal en normas APA 7.ª edición (portada, resumen, 14 tablas, 8 figuras, referencias) |
| [`fase1-epicas-historias.md`](fase1-epicas-historias/fase1-epicas-historias.md) | Misma información en Markdown, para lectura rápida en el navegador |
| [`diagramas/`](fase1-epicas-historias/diagramas/) | 8 diagramas en PlantUML (fuentes `.puml` y renders `.png`) |

### Contenido de la fase

- Árbol de problemas y formulación del problema central
- Objetivo general y 7 objetivos específicos con métricas
- Alcance, exclusiones y backlog de versiones futuras
- 6 actores, 3 perfiles de usuario y matriz de interesados
- Glosario del dominio y 18 reglas de negocio candidatas
- **9 épicas** y **32 historias de usuario** con criterios de aceptación en formato Dado-Cuando-Entonces
- Priorización MoSCoW + índice valor/esfuerzo
- **MVP: 23 historias, 126 puntos de historia, 4 sprints**
- Definición de Listo y de Terminado, riesgos, métricas de éxito y matriz de trazabilidad

### Resumen del MVP

| Épica | Historias | Puntos |
|---|---|---|
| EP-01 Acceso y seguridad | HU-01 … HU-05 | 23 |
| EP-02 Gestión de estudiantes | HU-06 … HU-09 | 14 |
| EP-03 Gestión de docentes | HU-11, HU-12 | 8 |
| EP-04 Oferta académica | HU-13, HU-14, HU-17 | 18 |
| EP-05 Matrícula | HU-15, HU-16, HU-22 | 21 |
| EP-06 Registro de calificaciones | HU-18, HU-19, HU-21 | 29 |
| EP-07 Consultas del estudiante | HU-23, HU-24, HU-25 | 13 |
| **Total** | **23 historias** | **126** |

---

## Fase 2 — Documento de requerimientos

📁 [`fase2-requerimientos/`](fase2-requerimientos/)

| Archivo | Descripción |
|---|---|
| [`Fase2-Requerimientos-SGA-APA7.docx`](fase2-requerimientos/Fase2-Requerimientos-SGA-APA7.docx) | Documento formal en normas APA 7.ª edición (26 tablas, 6 figuras, referencias) |
| [`fase2-requerimientos.md`](fase2-requerimientos/fase2-requerimientos.md) | Misma información en Markdown, con los diagramas renderizados |
| [`diagramas/`](fase2-requerimientos/diagramas/) | 6 diagramas en PlantUML (fuentes `.puml` y renders `.png`) |

### Contenido de la fase

- **57 requerimientos funcionales** en 6 módulos, cada uno con entradas, proceso, salidas, precondición y postcondición
- **28 requerimientos no funcionales** según las 8 características de la norma ISO/IEC 25010, todos con métrica de verificación
- **27 reglas de negocio** formalizadas y clasificadas por tipo, con su origen institucional
- **10 restricciones** técnicas, de proyecto, de negocio y normativas
- **15 casos de prueba** de aceptación del sistema
- **5 matrices de trazabilidad** con cobertura completa
- Procedimiento de gestión de cambios de los requerimientos

### Requerimientos por módulo

| Módulo | Responsabilidad | RF |
|---|---|---|
| M1 Seguridad y control de acceso | Autenticación, cuentas, roles y autorización | 9 |
| M2 Gestión de personas | Directorio único de estudiantes y docentes | 10 |
| M3 Oferta académica | Períodos, cursos, cupos, cortes y asignación | 11 |
| M4 Matrícula | Vinculación con validaciones de negocio | 9 |
| M5 Calificaciones | Registro, corrección, auditoría y cálculo | 10 |
| M6 Consultas y reportes | Consultas del estudiante y reportes | 8 |

### Diagramas de la fase

| # | Diagrama | Fuente |
|---|---|---|
| 1 | Módulos funcionales y dependencias | [`01-modulos-funcionales.puml`](fase2-requerimientos/diagramas/01-modulos-funcionales.puml) |
| 2 | Requerimientos no funcionales ISO/IEC 25010 | [`02-rnf-iso25010.puml`](fase2-requerimientos/diagramas/02-rnf-iso25010.puml) |
| 3 | Cadena de trazabilidad | [`03-cadena-trazabilidad.puml`](fase2-requerimientos/diagramas/03-cadena-trazabilidad.puml) |
| 4 | Ciclo de vida de la matrícula | [`04-estados-matricula.puml`](fase2-requerimientos/diagramas/04-estados-matricula.puml) |
| 5 | Flujo de validaciones de la matrícula | [`05-flujo-validaciones-matricula.puml`](fase2-requerimientos/diagramas/05-flujo-validaciones-matricula.puml) |
| 6 | Ciclo de vida del período y del curso | [`06-estados-periodo-curso.puml`](fase2-requerimientos/diagramas/06-estados-periodo-curso.puml) |

![Flujo de validaciones de la matrícula](fase2-requerimientos/diagramas/05-flujo-validaciones-matricula.png)

---

## Diagramas de la Fase 1

| # | Diagrama | Fuente |
|---|---|---|
| 1 | Contexto: actores y funciones principales | [`01-actores.puml`](fase1-epicas-historias/diagramas/01-actores.puml) |
| 2 | Árbol de problemas | [`02-arbol-problemas.puml`](fase1-epicas-historias/diagramas/02-arbol-problemas.puml) |
| 3 | Descomposición de épicas en historias | [`03-epicas-historias.puml`](fase1-epicas-historias/diagramas/03-epicas-historias.puml) |
| 4 | Mapa de historias (user story map) | [`04-story-map.puml`](fase1-epicas-historias/diagramas/04-story-map.puml) |
| 5 | Casos de uso del administrador | [`05-casos-uso-administrador.puml`](fase1-epicas-historias/diagramas/05-casos-uso-administrador.puml) |
| 6 | Casos de uso del docente y el estudiante | [`06-casos-uso-docente-estudiante.puml`](fase1-epicas-historias/diagramas/06-casos-uso-docente-estudiante.puml) |
| 7 | Matriz valor / esfuerzo | [`07-matriz-valor-esfuerzo.puml`](fase1-epicas-historias/diagramas/07-matriz-valor-esfuerzo.puml) |
| 8 | Cronograma de sprints (Gantt) | [`08-roadmap-sprints.puml`](fase1-epicas-historias/diagramas/08-roadmap-sprints.puml) |

### Regenerar los diagramas

Requiere Java y [PlantUML](https://plantuml.com/download). Desde la carpeta `diagramas/` de cualquiera de las fases:

```bash
java -jar plantuml.jar -tpng -charset UTF-8 *.puml
```

Los diagramas usan el motor de disposición **Smetana**, incluido en PlantUML, por lo que no es
necesario instalar Graphviz.

---

## Mapa de historias

![Mapa de historias](fase1-epicas-historias/diagramas/04-story-map.png)
