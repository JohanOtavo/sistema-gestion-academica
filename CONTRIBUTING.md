# Cómo trabajamos en este repositorio

Somos un equipo de dos: **Jannier Johan Otavo** y **Sergio David Vargas**. Este documento fija los
acuerdos que seguimos para que el trabajo de ambos se integre sin pisarse y para que el historial
del repositorio cuente lo que pasó en el proyecto.

---

## 1. Estructura del repositorio

```
sistema-gestion-academica/
├── README.md                     Portada: problema, fases y estado
├── CONTRIBUTING.md               Este documento
├── docs/
│   ├── adr/                      Decisiones de arquitectura (una por archivo)
│   └── seguimiento/
│       └── velocidad.md          Registro de velocidad por sprint
├── fase1-epicas-historias/       Entregable de la Fase 1
├── fase2-requerimientos/         Entregable de la Fase 2
└── .github/
    ├── ISSUE_TEMPLATE/           Plantillas de historias, tareas y errores
    └── pull_request_template.md
```

Cada fase vive en su carpeta, con el documento en Word, el mismo contenido en Markdown y una
subcarpeta `diagramas/` con las fuentes `.puml` y sus renders `.png`.

---

## 2. Convención de commits

Usamos **Conventional Commits** en español. El formato es:

```
tipo(alcance): descripción en imperativo y minúscula

Cuerpo opcional que explica el porqué del cambio, no el qué.
El qué ya se ve en el diff.

Refs #12
```

### Tipos permitidos

| Tipo | Cuándo usarlo |
|---|---|
| `feat` | Funcionalidad nueva del sistema o contenido nuevo de un entregable |
| `fix` | Corrección de un error, de un dato equivocado o de una inconsistencia |
| `docs` | Cambios de redacción, formato o documentación que no alteran datos |
| `diagram` | Cambios en los diagramas PlantUML |
| `refactor` | Reorganización sin cambiar el resultado visible |
| `test` | Casos de prueba y su ejecución |
| `chore` | Configuración del repositorio, plantillas, dependencias |

### Alcances

`fase1`, `fase2`, `fase3`, `fase4`, `fase5`, `fase6`, `adr`, `diagramas`, `repo`, `seguimiento`.

### Ejemplos

```
feat(fase2): agregar los 15 casos de prueba de aceptación
fix(fase2): corregir la referencia a las tablas 22 y 23
docs(fase1): reescribir el planteamiento del problema en primera persona
diagram(fase2): dividir el flujo de matrícula en ramas paralelas
chore(repo): agregar plantillas de issues
```

### Lo que evitamos

Mensajes que no dicen nada: `g`, `cambios`, `actualización`, `complemento`, `.`, `asdf`. Quien lea
el historial dentro de tres meses —o quien lo evalúe— debe entender qué pasó sin abrir el diff.

Regla práctica: si el mensaje sirve igual para cualquier commit del proyecto, está mal escrito.

---

## 3. Ramas

| Rama | Uso |
|---|---|
| `main` | Siempre en estado entregable. No se trabaja directamente sobre ella |
| `feat/HU-15-matricular` | Una historia de usuario |
| `docs/fase3-diagramas-clases` | Un bloque de documentación |
| `fix/RF-31-validacion-cupo` | Una corrección puntual |

El nombre de la rama lleva el identificador del elemento que se trabaja (HU, RF, ADR), para que la
trazabilidad llegue hasta el historial de Git.

```bash
git checkout -b feat/HU-15-matricular
# ... trabajo y commits ...
git push -u origin feat/HU-15-matricular
```

---

## 4. Pull requests

Toda rama entra a `main` por pull request, nunca por merge directo. Esto no es burocracia: es lo
que hace cumplible el criterio de la Definición de Terminado que dice *"revisado por al menos otro
integrante del equipo"*.

Quien revisa verifica tres cosas:

1. Que los criterios de aceptación de la historia se cumplan.
2. Que las validaciones de negocio estén aplicadas y no solo el camino feliz.
3. Que los mensajes de error sean claros y estén en español.

El PR se abre con la plantilla del repositorio, que ya trae la lista de verificación.

---

## 5. Issues

Toda unidad de trabajo se registra como issue antes de empezar. Hay tres plantillas:

| Plantilla | Para qué |
|---|---|
| Historia de usuario | Una HU del backlog, con sus criterios de aceptación |
| Tarea técnica | Trabajo necesario que no es una historia (configuración, diagramas, documentación) |
| Reporte de error | Algo que no funciona como lo especificamos |

El issue se cierra desde el commit o el PR que lo resuelve, escribiendo `Closes #12` en el cuerpo.

---

## 6. Regenerar los diagramas

Los diagramas se editan en su archivo `.puml` y se vuelven a renderizar; **nunca se retoca el
`.png` a mano**, porque el siguiente render borraría el cambio.

```bash
java -jar plantuml.jar -tpng -charset UTF-8 *.puml
```

Se requiere Java. Los diagramas usan el motor de disposición Smetana, incluido en PlantUML, así que
no hace falta instalar Graphviz.

Cuando cambies un diagrama, commitea el `.puml` y el `.png` juntos en el mismo commit.

---

## 7. Documentos de las fases

Los archivos `.docx` son binarios: Git no puede fusionarlos. Si dos personas editan el mismo Word al
tiempo, uno de los dos pierde su trabajo y el conflicto no se puede resolver línea por línea.

Para evitarlo:

- Solo una persona edita un `.docx` a la vez. Avisar antes de empezar.
- Hacer `git pull` inmediatamente antes de abrir el documento en Word.
- Commitear y subir apenas se termine la sesión de edición, sin dejarlo abierto días.
- Al actualizar la tabla de contenido con `F9`, hacerlo justo antes del commit final.

Los cambios de fondo se discuten sobre el `.md`, que sí es diferenciable línea por línea.

---

## 8. Decisiones de arquitectura

Cuando tomemos una decisión que sea costosa de revertir —el motor de base de datos, la forma de
autorizar, el lenguaje— se registra como un ADR en [`docs/adr/`](docs/adr/), siguiendo la plantilla
que hay allí. Un ADR es corto: contexto, decisión, consecuencias y alternativas descartadas.

No se documentan las decisiones triviales ni las reversibles en una tarde.

---

## 9. Antes de empezar una historia

Verificar que cumpla la **Definición de Listo** de la Fase 1: está escrita con rol, funcionalidad y
beneficio; tiene al menos tres criterios de aceptación verificables; está estimada y no supera los
13 puntos; sus dependencias están resueltas; y referencia las reglas de negocio que la condicionan.

Si no la cumple, se refina primero. Empezar una historia que no está lista es la forma más rápida de
tener que rehacerla.
