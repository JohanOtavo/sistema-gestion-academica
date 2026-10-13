# Fase 1 — Épicas e Historias de Usuario
## Sistema de Gestión Académica (SGA)

| Campo | Detalle |
|---|---|
| **Proyecto** | Sistema de Gestión Académica (SGA) |
| **Grupo** | 6 |
| **Integrante** | Jannier Johan Otavo |
| **Fase** | 1 de 6 — Épica y Stories |
| **Entregable** | Épicas + Historias de usuario con criterios de aceptación y priorización |
| **Versión** | 1.0 |
| **Fecha** | 18 de agosto de 2026 |
| **Estado** | Listo para revisión / entrada a Fase 2 (Requerimientos) |

---

## Índice

1. [Contexto y problema](#1-contexto-y-problema)
2. [Objetivos](#2-objetivos)
3. [Alcance del proyecto](#3-alcance-del-proyecto)
4. [Actores, usuarios e interesados](#4-actores-usuarios-e-interesados)
5. [Glosario del dominio](#5-glosario-del-dominio)
6. [Reglas de negocio candidatas](#6-reglas-de-negocio-candidatas)
7. [Mapa de historias (User Story Map)](#7-mapa-de-historias-user-story-map)
8. [Épicas](#8-épicas)
9. [Historias de usuario con criterios de aceptación](#9-historias-de-usuario-con-criterios-de-aceptación)
10. [Priorización](#10-priorización)
11. [Definición del MVP y roadmap](#11-definición-del-mvp-y-roadmap)
12. [Definition of Ready y Definition of Done](#12-definition-of-ready-y-definition-of-done)
13. [Supuestos, restricciones y riesgos](#13-supuestos-restricciones-y-riesgos)
14. [Métricas de éxito](#14-métricas-de-éxito)
15. [Trazabilidad épica → historia](#15-trazabilidad-épica--historia)
16. [Checklist de cierre de la Fase 1](#16-checklist-de-cierre-de-la-fase-1)

---

## 1. Contexto y problema

### 1.1 Situación actual

La **Institución Educativa (IE)** para la que se desarrolla el sistema atiende aproximadamente **600
estudiantes** y **35 docentes**, y ofrece alrededor de **40 cursos** distribuidos en dos períodos
académicos por año. Toda la operación académica se sostiene hoy sobre tres soportes:

1. **Hojas de cálculo sueltas.** Cada docente lleva su propio archivo de notas, con su propio
   formato. Al final del período la secretaría académica pide los archivos por correo y los
   consolida a mano.
2. **Formatos en papel.** La matrícula se hace con un formulario impreso que el estudiante o su
   acudiente diligencia en ventanilla; luego alguien lo transcribe a otra hoja de cálculo.
3. **La memoria de las personas.** Los cupos disponibles de un curso, quién repite materia, qué
   grupo se cerró por falta de estudiantes: mucho de esto vive en la cabeza del coordinador.

El resultado es predecible: **la misma información existe en varios lugares y ninguna copia coincide
con otra.** Un estudiante aparece matriculado en un curso en la hoja de la secretaría pero no en la
lista del docente. Un docente entrega notas de 28 estudiantes cuando el grupo tiene 30. Un boletín
se imprime con un promedio calculado con una fórmula que alguien modificó por error tres semanas
antes.

### 1.2 Árbol de problemas

```
                             EFECTOS
   +------------------+------------------+-----------------------+
   | Boletines con    | Reclamos de      | Decisiones            |
   | errores y        | estudiantes y    | académicas tomadas    |
   | reprocesos       | acudientes       | sobre datos falsos    |
   +--------+---------+--------+---------+----------+------------+
            |                  |                    |
   +--------+------------------+--------------------+------------+
   |  PROBLEMA CENTRAL                                            |
   |  La información académica (estudiantes, docentes, cursos,    |
   |  matrículas y calificaciones) está dispersa, duplicada y     |
   |  sin control de acceso, por lo que no existe una fuente      |
   |  única y confiable de la verdad.                             |
   +--------+------------------+--------------------+------------+
            |                  |                    |
   +--------+---------+--------+---------+----------+------------+
   | No hay un sistema| Procesos         | Sin roles ni permisos:|
   | centralizado:    | manuales:        | cualquiera abre y     |
   | N hojas de       | transcripción    | edita cualquier       |
   | cálculo aisladas | y consolidación  | archivo               |
   +------------------+------------------+-----------------------+
                             CAUSAS
```

### 1.3 Formulación del problema central

> **La institución no cuenta con un sistema centralizado que registre y relacione estudiantes,
> docentes, cursos y matrículas, ni que soporte el registro de calificaciones bajo reglas y permisos
> definidos. Como consecuencia la información se duplica, se contradice y se pierde; la
> consolidación de notas toma semanas de trabajo manual; y la institución no puede responder con
> certeza preguntas básicas como "¿cuántos estudiantes hay matriculados en este curso?" o "¿cuál es
> el promedio real de este estudiante?".**

### 1.4 Dolores concretos que se van a atacar

| # | Dolor observado | Impacto actual | Historias que lo resuelven |
|---|---|---|---|
| D-1 | Cada docente usa su propio formato de notas | ~3 semanas para consolidar el período | HU-18, HU-19, HU-20 |
| D-2 | Se matriculan estudiantes en cursos sin cupo | 4–6 sobrecupos por período que hay que deshacer | HU-15, RN-05 |
| D-3 | No se sabe qué estudiante está activo o retirado | Listas de clase con nombres que ya no asisten | HU-07, HU-09 |
| D-4 | Cualquiera puede editar cualquier archivo de notas | Al menos un incidente de nota alterada por período | HU-01, HU-04 |
| D-5 | El estudiante debe ir a ventanilla para ver sus notas | Fila permanente en secretaría al cierre de período | HU-23, HU-24 |
| D-6 | Los promedios se calculan a mano en cada boletín | Errores de cálculo detectados en la revisión final | HU-21, HU-25 |
| D-7 | Un mismo estudiante se registra dos veces con datos distintos | Historial académico partido en dos registros | HU-06, RN-01 |

---

## 2. Objetivos

### 2.1 Objetivo general

Desarrollar un sistema de información web que **centralice la gestión académica** de la institución
—estudiantes, docentes, cursos y matrículas— y soporte el **registro y consulta de calificaciones**
bajo un esquema de roles y reglas de negocio, de modo que exista una **única fuente de verdad**
accesible según el perfil de cada usuario.

### 2.2 Objetivos específicos (SMART)

| ID | Objetivo específico | Métrica de cumplimiento |
|---|---|---|
| OE-1 | Implementar autenticación con tres roles (administrador, docente, estudiante) y control de acceso por rol | 100 % de las operaciones sensibles exigen sesión activa y rol autorizado |
| OE-2 | Centralizar el registro de estudiantes y docentes con identificación única | 0 registros duplicados por número de documento |
| OE-3 | Administrar la oferta académica: cursos, períodos, cupo y docente asignado | 100 % de los cursos activos tienen período, cupo y docente |
| OE-4 | Automatizar la matrícula validando cupo, período activo y no duplicidad | 0 sobrecupos y 0 matrículas duplicadas |
| OE-5 | Permitir al docente registrar calificaciones solo de los cursos que dicta | 100 % de las notas quedan con autor y fecha de registro |
| OE-6 | Ofrecer al estudiante consulta en línea de horario, notas y promedio | El estudiante consulta sus notas sin pasar por secretaría |
| OE-7 | Entregar tres reportes base: lista de clase, boletín por estudiante y ocupación por curso | 3 reportes disponibles al cierre del MVP |

---

## 3. Alcance del proyecto

### 3.1 Dentro del alcance (versión 1 / MVP)

- Autenticación, sesión y gestión de usuarios con roles.
- CRUD de **estudiantes**, **docentes**, **cursos** y **períodos académicos**.
- Asignación de docente a curso.
- **Matrícula** de estudiantes en cursos, con validaciones de negocio.
- **Registro y edición de calificaciones** por parte del docente.
- Cálculo automático de la nota definitiva por curso y del promedio general.
- Consultas del estudiante (cursos, notas, promedio) y reportes del administrador.

### 3.2 Fuera del alcance de la versión 1

| Excluido | Razón |
|---|---|
| Cobros, facturación y pagos de matrícula | Es un dominio financiero completo; el proyecto se centra en lo académico |
| Aula virtual, tareas y material de clase | Corresponde a un LMS, no a un sistema de gestión académica |
| Aplicación móvil nativa | El sistema será web responsive; una app nativa duplicaría el esfuerzo |
| Reportes oficiales ante entes gubernamentales | Requiere formatos legales aún desconocidos |
| Firma digital de boletines | Requiere infraestructura de certificados fuera del alcance |
| Mensajería interna / chat | No resuelve el problema central identificado |

### 3.3 Candidatos a versiones futuras

Control de asistencia por sesión, portal del acudiente, notificaciones por correo, prerrequisitos
entre cursos, generación automática de horarios con detección de choques, histórico académico
multi-año, exportación a PDF con plantilla institucional.

---

## 4. Actores, usuarios e interesados

### 4.1 Actores del sistema

| Actor | Tipo | Descripción | Nivel de acceso |
|---|---|---|---|
| **Administrador académico** | Primario, humano | Coordinación o secretaría académica. Configura la oferta y administra personas y matrículas. | Total |
| **Docente** | Primario, humano | Dicta uno o más cursos. Registra calificaciones y consulta sus grupos. | Restringido a sus cursos |
| **Estudiante** | Primario, humano | Cursa las asignaturas en las que está matriculado. Consulta su información. | Solo lectura de sus datos |
| **Acudiente** | Secundario, humano | Responsable del estudiante menor de edad. *(Fuera del MVP)* | Solo lectura, futuro |
| **Servicio de autenticación** | Secundario, software | Valida credenciales y administra la sesión. | Interno |
| **Motor de reportes** | Secundario, software | Genera listas, boletines y consolidados. | Interno |

### 4.2 Perfiles de usuario (personas)

**Marta — Coordinadora académica, 45 años.**
Lleva doce años en la institución. Maneja hojas de cálculo con soltura pero no es técnica. Su semana
pico es la de matrícula: atiende ventanilla, revisa cupos y llama a docentes para confirmar grupos.
*Necesita:* ver de un vistazo cuántos cupos quedan y matricular sin equivocarse.
*Le frustra:* descubrir un sobrecupo cuando el curso ya empezó.
*Frase típica:* "Necesito saber ya mismo cuántos hay en ese grupo, no dentro de dos días".

**Carlos — Docente de matemáticas, 38 años.**
Dicta cuatro cursos, unos 120 estudiantes en total. Registra notas al final de cada corte, casi
siempre a contrarreloj.
*Necesita:* una pantalla donde vea su lista de clase y escriba las notas rápido, sin buscar nombres.
*Le frustra:* que le devuelvan el archivo porque el formato no era el que pedía secretaría.
*Frase típica:* "Yo ya mandé esas notas, no sé en qué correo se perdieron".

**Valentina — Estudiante, 17 años.**
Vive conectada al celular. Quiere saber su promedio antes de que el boletín llegue a la casa.
*Necesita:* entrar, ver sus notas y su horario, y salir.
*Le frustra:* ir a secretaría en horario de clase para preguntar una nota.
*Frase típica:* "¿Ya subieron las notas de sociales?".

### 4.3 Matriz de interesados

| Interesado | Interés | Influencia | Estrategia de manejo |
|---|---|---|---|
| Rectoría | Información confiable para tomar decisiones | Alta | Informar en cada demo de sprint |
| Coordinación académica | Usuario principal del día a día | Alta | Involucrar en refinamiento y validación |
| Cuerpo docente | Menos trabajo manual, pero resistencia al cambio | Media | Prototipo temprano (Fase 5) y capacitación |
| Estudiantes y acudientes | Acceso a su propia información | Media | Validar usabilidad del mockup |
| Soporte / TI de la institución | Despliegue y mantenimiento | Baja | Definir requisitos técnicos en Fase 2 |
| Equipo de desarrollo (grupo 6) | Ejecutar las seis fases | Alta | Ceremonias del equipo |

---

## 5. Glosario del dominio

Lenguaje común para todo el proyecto: estos términos deben usarse igual en las historias, en el
modelo UML (Fase 3), en las tablas de la base de datos (Fase 4) y en la interfaz (Fase 5).

| Término | Definición |
|---|---|
| **Estudiante** | Persona registrada en la institución que puede matricularse en cursos. Se identifica por su documento y por un código interno. |
| **Docente** | Persona registrada que dicta uno o más cursos en un período. |
| **Usuario** | Cuenta de acceso al sistema. Todo docente, estudiante o administrador tiene exactamente un usuario. |
| **Rol** | Conjunto de permisos: `ADMINISTRADOR`, `DOCENTE`, `ESTUDIANTE`. |
| **Curso / Asignatura** | Unidad académica que se dicta en un período, con un código, un número de créditos, un cupo máximo y un docente asignado. |
| **Período académico** | Intervalo con fecha de inicio y fin (ej. `2026-1`). Solo uno puede estar en estado `ACTIVO`. |
| **Matrícula** | Vínculo entre un estudiante y un curso dentro de un período. Es la entidad que "convierte" a un estudiante en parte de una lista de clase. |
| **Estado de matrícula** | `ACTIVA`, `CANCELADA` o `FINALIZADA`. |
| **Calificación / Nota** | Valor numérico entre 0.0 y 5.0 asociado a una matrícula y a un corte evaluativo. |
| **Corte** | Momento de evaluación dentro del período (Corte 1, Corte 2, Corte 3), cada uno con un porcentaje. |
| **Nota definitiva** | Promedio ponderado de los cortes de una matrícula. |
| **Promedio general** | Promedio de las notas definitivas del estudiante en el período, ponderado por créditos. |
| **Cupo** | Número máximo de estudiantes que admite un curso. |
| **Lista de clase** | Conjunto de estudiantes con matrícula `ACTIVA` en un curso. |
| **Boletín** | Reporte por estudiante con sus cursos, notas por corte, definitiva y promedio. |

---

## 6. Reglas de negocio candidatas

Estas reglas nacen en la Fase 1 porque condicionan los criterios de aceptación; se formalizan y se
completan en la Fase 2.

| ID | Regla de negocio | Historias afectadas |
|---|---|---|
| RN-01 | El número de documento de una persona (estudiante o docente) es único en el sistema. | HU-06, HU-11 |
| RN-02 | El correo de un usuario es único y sirve como nombre de usuario para iniciar sesión. | HU-01, HU-03 |
| RN-03 | Solo puede existir **un** período académico en estado `ACTIVO` al mismo tiempo. | HU-13 |
| RN-04 | Un estudiante no puede matricularse dos veces en el mismo curso dentro del mismo período. | HU-15 |
| RN-05 | No se puede matricular a un estudiante si el curso alcanzó su cupo máximo. | HU-15 |
| RN-06 | Solo se puede matricular a estudiantes con estado `ACTIVO`. | HU-15 |
| RN-07 | Las matrículas solo se registran sobre el período `ACTIVO`. | HU-15 |
| RN-08 | Un docente solo puede registrar o modificar notas de los cursos que tiene asignados. | HU-18, HU-19 |
| RN-09 | Una calificación debe estar entre 0.0 y 5.0, con máximo un decimal. | HU-18 |
| RN-10 | Los porcentajes de los cortes de un curso deben sumar exactamente 100 %. | HU-17 |
| RN-11 | La nota definitiva se calcula como la suma de (nota del corte × porcentaje del corte). | HU-21 |
| RN-12 | Se aprueba un curso con nota definitiva mayor o igual a 3.0. | HU-21, HU-24 |
| RN-13 | El promedio general del período se pondera por los créditos de cada curso. | HU-25 |
| RN-14 | Un estudiante no puede matricular más de 7 cursos en un mismo período. | HU-15 |
| RN-15 | No se elimina físicamente a una persona ni a un curso con historial: se inactiva. | HU-09, HU-14 |
| RN-16 | Cancelar una matrícula libera un cupo del curso. | HU-16 |
| RN-17 | Una vez cerrado el período, las notas quedan en modo solo lectura. | HU-20 |
| RN-18 | Toda modificación de una nota ya registrada queda con autor, fecha y valor anterior. | HU-19 |

---

## 7. Mapa de historias (User Story Map)

Lectura horizontal: el flujo de la operación académica. Lectura vertical: de arriba hacia abajo,
de lo imprescindible a lo deseable. La línea `MVP` marca el corte de la primera entrega.

```
ACTIVIDADES  Acceder      Administrar   Configurar    Matricular   Calificar     Consultar
DEL USUARIO  al sistema   personas      la oferta                                y reportar
             ---------    ----------    -----------   ----------   ---------     ----------
             HU-01        HU-06         HU-12         HU-15        HU-18         HU-22
  MVP        HU-02        HU-07         HU-13         HU-16        HU-19         HU-23
             HU-03        HU-11         HU-14         HU-17        HU-21         HU-24
             HU-04                                                               HU-25
=========================================================================================
             HU-05        HU-08         HU-28         HU-27        HU-20         HU-26
 Versión 2                HU-09                                                  HU-29
             .            HU-10                                                  HU-30
=========================================================================================
             Recuperar    Portal del    Horarios y    Prerre-      Asistencia    Notificaciones
 Futuro      contraseña   acudiente     choques       quisitos     por sesión    y PDF oficial
             por correo
```

---

## 8. Épicas

> **Épica** = funcionalidad grande, con valor de negocio claro, que no cabe en un sprint y se
> descompone en historias.

### EP-01 — Acceso y seguridad

| Campo | Detalle |
|---|---|
| **Descripción** | Como institución necesitamos que cada persona entre al sistema con su propia cuenta y vea únicamente lo que su rol le permite. |
| **Valor de negocio** | Protege la integridad de las notas y da trazabilidad: se sabe quién hizo qué. |
| **Actores** | Administrador, docente, estudiante |
| **Criterio de éxito** | Ninguna funcionalidad sensible es accesible sin sesión válida y rol autorizado. |
| **Historias** | HU-01, HU-02, HU-03, HU-04, HU-05 |
| **Prioridad** | Must have — es la base de todo lo demás |

### EP-02 — Gestión de estudiantes

| Campo | Detalle |
|---|---|
| **Descripción** | Como administrador necesito registrar, consultar, actualizar e inactivar estudiantes para tener un directorio único y confiable. |
| **Valor de negocio** | Elimina el registro duplicado y da la base de la matrícula. |
| **Actores** | Administrador |
| **Criterio de éxito** | Cero duplicados por documento; toda matrícula apunta a un estudiante existente y activo. |
| **Historias** | HU-06, HU-07, HU-08, HU-09, HU-10 |
| **Prioridad** | Must have |

### EP-03 — Gestión de docentes

| Campo | Detalle |
|---|---|
| **Descripción** | Como administrador necesito registrar docentes y asignarlos a los cursos que dictan. |
| **Valor de negocio** | Permite delegar el registro de notas y saber quién responde por cada curso. |
| **Actores** | Administrador |
| **Criterio de éxito** | Todo curso activo tiene exactamente un docente responsable. |
| **Historias** | HU-11, HU-12 |
| **Prioridad** | Must have |

### EP-04 — Oferta académica (cursos y períodos)

| Campo | Detalle |
|---|---|
| **Descripción** | Como administrador necesito definir los períodos académicos y los cursos que se ofrecen en cada uno, con su cupo, sus créditos y su esquema de evaluación. |
| **Valor de negocio** | Es el catálogo sobre el que ocurre todo lo demás; sin él no hay matrícula ni notas. |
| **Actores** | Administrador |
| **Criterio de éxito** | Existe un período activo y un conjunto de cursos con cupo y docente asignado. |
| **Historias** | HU-13, HU-14, HU-17, HU-28 |
| **Prioridad** | Must have |

### EP-05 — Matrícula

| Campo | Detalle |
|---|---|
| **Descripción** | Como administrador necesito matricular estudiantes en cursos aplicando las reglas de cupo, período y no duplicidad, y poder cancelar una matrícula cuando corresponda. |
| **Valor de negocio** | Es el corazón del sistema: convierte datos sueltos en listas de clase reales. Elimina los sobrecupos. |
| **Actores** | Administrador, estudiante (consulta) |
| **Criterio de éxito** | 0 sobrecupos, 0 matrículas duplicadas, cupos liberados al cancelar. |
| **Historias** | HU-15, HU-16, HU-22, HU-27 |
| **Prioridad** | Must have |

### EP-06 — Registro de calificaciones

| Campo | Detalle |
|---|---|
| **Descripción** | Como docente necesito registrar y corregir las notas de los estudiantes de mis cursos, y que el sistema calcule la nota definitiva. |
| **Valor de negocio** | Reemplaza las hojas de cálculo dispersas; reduce de semanas a minutos la consolidación. |
| **Actores** | Docente, administrador |
| **Criterio de éxito** | El 100 % de las notas del período quedan en el sistema con autor y fecha. |
| **Historias** | HU-18, HU-19, HU-20, HU-21 |
| **Prioridad** | Must have |

### EP-07 — Consultas del estudiante

| Campo | Detalle |
|---|---|
| **Descripción** | Como estudiante quiero consultar en línea mis cursos, mis notas y mi promedio sin depender de secretaría. |
| **Valor de negocio** | Descongestiona la ventanilla y da transparencia al proceso evaluativo. |
| **Actores** | Estudiante |
| **Criterio de éxito** | El estudiante ve sus notas publicadas sin intervención de un funcionario. |
| **Historias** | HU-23, HU-24, HU-25 |
| **Prioridad** | Must have (versión mínima) |

### EP-08 — Reportes y tablero

| Campo | Detalle |
|---|---|
| **Descripción** | Como administrador necesito reportes operativos: lista de clase, boletín por estudiante y ocupación por curso. |
| **Valor de negocio** | Da a coordinación la foto real de la institución en cualquier momento. |
| **Actores** | Administrador, docente |
| **Criterio de éxito** | Tres reportes disponibles y exportables. |
| **Historias** | HU-22, HU-26, HU-29, HU-30 |
| **Prioridad** | Should have (uno de ellos en el MVP) |

### EP-09 — Notificaciones *(fuera del MVP)*

| Campo | Detalle |
|---|---|
| **Descripción** | Como estudiante quiero enterarme por correo de la publicación de notas y de cambios en mi matrícula. |
| **Valor de negocio** | Mejora la experiencia, pero no resuelve el problema central. |
| **Actores** | Estudiante, docente |
| **Historias** | HU-31, HU-32 |
| **Prioridad** | Could have — versión 2 |

---

## 9. Historias de usuario con criterios de aceptación

**Formato de cada historia:** identificador, épica, rol, funcionalidad, beneficio, criterios de
aceptación en formato Gherkin (`Dado / Cuando / Entonces`), prioridad MoSCoW, estimación en puntos
de historia (escala Fibonacci) y dependencias.

---

### EP-01 · Acceso y seguridad

---

#### HU-01 — Iniciar sesión

> **Como** usuario registrado (administrador, docente o estudiante)
> **quiero** iniciar sesión con mi correo y mi contraseña
> **para** acceder a las funciones que me corresponden según mi rol.

**Criterios de aceptación**

- **CA-1 · Credenciales válidas**
  *Dado* que soy un usuario activo con correo `docente@ie.edu.co` y contraseña correcta,
  *cuando* envío el formulario de inicio de sesión,
  *entonces* el sistema crea mi sesión y me redirige al panel correspondiente a mi rol.
- **CA-2 · Credenciales inválidas**
  *Dado* que escribo una contraseña incorrecta,
  *cuando* envío el formulario,
  *entonces* el sistema muestra el mensaje "Usuario o contraseña incorrectos" **sin indicar cuál de
  los dos falló** y no crea sesión.
- **CA-3 · Usuario inactivo**
  *Dado* que mi usuario está inactivo,
  *cuando* intento iniciar sesión con credenciales correctas,
  *entonces* el sistema me informa que la cuenta está inactiva y no crea sesión.
- **CA-4 · Campos vacíos**
  *Dado* que dejo el correo o la contraseña en blanco,
  *cuando* envío el formulario,
  *entonces* el sistema marca el campo faltante y no envía la solicitud al servidor.
- **CA-5 · Almacenamiento seguro**
  *Dado* cualquier usuario del sistema,
  *cuando* se consulta la base de datos,
  *entonces* la contraseña aparece cifrada (hash), nunca en texto plano.

**Prioridad:** Must have · **Estimación:** 5 SP · **Depende de:** HU-03

---

#### HU-02 — Cerrar sesión

> **Como** usuario autenticado
> **quiero** cerrar mi sesión
> **para** evitar que otra persona use mi cuenta en un equipo compartido.

**Criterios de aceptación**

- **CA-1** *Dado* que tengo sesión activa, *cuando* pulso "Cerrar sesión", *entonces* la sesión se
  invalida y soy redirigido a la pantalla de acceso.
- **CA-2** *Dado* que cerré sesión, *cuando* uso el botón "atrás" del navegador o pego una URL
  interna, *entonces* el sistema me devuelve a la pantalla de acceso.
- **CA-3** *Dado* que permanezco inactivo 30 minutos, *cuando* intento una acción, *entonces* la
  sesión ha expirado y debo autenticarme de nuevo.

**Prioridad:** Must have · **Estimación:** 2 SP · **Depende de:** HU-01

---

#### HU-03 — Administrar usuarios y roles

> **Como** administrador
> **quiero** crear cuentas de usuario y asignarles un rol
> **para** que cada persona acceda solo a lo que le corresponde.

**Criterios de aceptación**

- **CA-1** *Dado* que registro un nuevo usuario con correo, nombre y rol, *cuando* guardo,
  *entonces* el sistema crea la cuenta con una contraseña temporal y estado `ACTIVO`.
- **CA-2** *Dado* que el correo ya está registrado (RN-02), *cuando* intento guardar, *entonces* el
  sistema rechaza la operación con el mensaje "El correo ya está registrado".
- **CA-3** *Dado* un usuario existente, *cuando* cambio su rol, *entonces* los permisos se aplican
  en su siguiente inicio de sesión.
- **CA-4** *Dado* un usuario existente, *cuando* lo inactivo, *entonces* no puede iniciar sesión
  pero su información histórica se conserva.
- **CA-5** *Dado* que no soy administrador, *cuando* intento entrar a la gestión de usuarios,
  *entonces* el sistema responde "No tiene permisos para esta operación".

**Prioridad:** Must have · **Estimación:** 8 SP · **Depende de:** —

---

#### HU-04 — Restringir funcionalidades por rol

> **Como** institución
> **quiero** que cada rol vea y ejecute únicamente sus operaciones
> **para** proteger la integridad de la información académica.

**Criterios de aceptación**

- **CA-1** *Dado* que ingreso como estudiante, *cuando* veo el menú, *entonces* solo aparecen "Mis
  cursos", "Mis notas" y "Mi perfil".
- **CA-2** *Dado* que ingreso como docente, *cuando* veo el menú, *entonces* aparecen "Mis cursos",
  "Registrar notas" y "Mi perfil", y no aparece la gestión de estudiantes.
- **CA-3** *Dado* que ingreso como estudiante, *cuando* invoco directamente una URL de
  administración, *entonces* el sistema responde con error de autorización y registra el intento.
- **CA-4** *Dado* que ingreso como docente, *cuando* consulto la lista de cursos, *entonces* solo
  veo los cursos que tengo asignados (RN-08).

**Prioridad:** Must have · **Estimación:** 5 SP · **Depende de:** HU-01, HU-03

---

#### HU-05 — Cambiar mi contraseña

> **Como** usuario autenticado
> **quiero** cambiar mi contraseña
> **para** dejar de usar la temporal que me asignó el administrador.

**Criterios de aceptación**

- **CA-1** *Dado* que ingreso la contraseña actual correcta y una nueva válida, *cuando* confirmo,
  *entonces* el sistema actualiza la contraseña y pide iniciar sesión de nuevo.
- **CA-2** *Dado* que la contraseña actual es incorrecta, *cuando* confirmo, *entonces* el sistema
  rechaza el cambio.
- **CA-3** *Dado* que la nueva contraseña tiene menos de 8 caracteres o no coincide con su
  confirmación, *cuando* envío, *entonces* el sistema muestra el error correspondiente.

**Prioridad:** Should have · **Estimación:** 3 SP · **Depende de:** HU-01

---

### EP-02 · Gestión de estudiantes

---

#### HU-06 — Registrar un estudiante

> **Como** administrador
> **quiero** registrar un estudiante con sus datos personales y de contacto
> **para** incorporarlo al directorio único de la institución y poder matricularlo.

**Criterios de aceptación**

- **CA-1 · Registro exitoso**
  *Dado* que diligencio tipo y número de documento, nombres, apellidos, fecha de nacimiento, correo
  y teléfono,
  *cuando* guardo,
  *entonces* el sistema crea el estudiante con estado `ACTIVO`, le genera un código interno y
  muestra "Estudiante registrado correctamente".
- **CA-2 · Documento duplicado (RN-01)**
  *Dado* que el número de documento ya existe,
  *cuando* intento guardar,
  *entonces* el sistema rechaza el registro con "Ya existe un estudiante con ese documento".
- **CA-3 · Campos obligatorios**
  *Dado* que omito un campo obligatorio,
  *cuando* intento guardar,
  *entonces* el sistema señala el campo y no persiste nada.
- **CA-4 · Formato de datos**
  *Dado* que escribo un correo sin formato válido o un documento con letras,
  *cuando* intento guardar,
  *entonces* el sistema muestra el error de formato correspondiente.
- **CA-5 · Cuenta de acceso**
  *Dado* que el estudiante se registró correctamente,
  *cuando* consulto la lista de usuarios,
  *entonces* existe un usuario con rol `ESTUDIANTE` asociado a ese estudiante.

**Prioridad:** Must have · **Estimación:** 5 SP · **Depende de:** HU-03

---

#### HU-07 — Consultar y buscar estudiantes

> **Como** administrador
> **quiero** ver el listado de estudiantes y buscar por documento, nombre o estado
> **para** encontrar rápido a una persona sin recorrer toda la lista.

**Criterios de aceptación**

- **CA-1** *Dado* que hay estudiantes registrados, *cuando* abro el listado, *entonces* veo código,
  documento, nombre completo, correo y estado, paginados de 20 en 20.
- **CA-2** *Dado* que escribo un texto en el buscador, *cuando* ejecuto la búsqueda, *entonces* el
  sistema filtra por coincidencia parcial en nombre, apellido o documento.
- **CA-3** *Dado* que filtro por estado `ACTIVO`, *cuando* aplico el filtro, *entonces* solo se
  listan estudiantes activos.
- **CA-4** *Dado* que la búsqueda no arroja coincidencias, *cuando* se muestra el resultado,
  *entonces* aparece "No se encontraron estudiantes con ese criterio".

**Prioridad:** Must have · **Estimación:** 3 SP · **Depende de:** HU-06

---

#### HU-08 — Actualizar datos de un estudiante

> **Como** administrador
> **quiero** modificar los datos de un estudiante
> **para** mantener la información al día cuando cambia de dirección, teléfono o correo.

**Criterios de aceptación**

- **CA-1** *Dado* que abro un estudiante existente, *cuando* modifico un campo editable y guardo,
  *entonces* el sistema persiste el cambio y confirma la actualización.
- **CA-2** *Dado* que intento cambiar el número de documento por uno ya usado, *cuando* guardo,
  *entonces* el sistema rechaza el cambio (RN-01).
- **CA-3** *Dado* que un estudiante tiene matrículas registradas, *cuando* edito sus datos
  personales, *entonces* sus matrículas y notas se conservan intactas.

**Prioridad:** Must have · **Estimación:** 3 SP · **Depende de:** HU-06

---

#### HU-09 — Inactivar un estudiante

> **Como** administrador
> **quiero** inactivar a un estudiante que se retiró
> **para** que deje de aparecer en las listas y matrículas nuevas sin borrar su historial.

**Criterios de aceptación**

- **CA-1** *Dado* un estudiante activo, *cuando* lo inactivo y confirmo, *entonces* su estado pasa a
  `INACTIVO` y no puede iniciar sesión.
- **CA-2** *Dado* un estudiante inactivo, *cuando* intento matricularlo, *entonces* el sistema lo
  impide (RN-06).
- **CA-3** *Dado* un estudiante inactivo, *cuando* consulto su ficha, *entonces* su historial
  académico sigue disponible (RN-15).
- **CA-4** *Dado* que la acción es irreversible desde la lista, *cuando* pulso inactivar, *entonces*
  el sistema pide confirmación explícita antes de aplicar el cambio.

**Prioridad:** Should have · **Estimación:** 3 SP · **Depende de:** HU-06

---

#### HU-10 — Ver la ficha completa de un estudiante

> **Como** administrador
> **quiero** abrir la ficha de un estudiante con sus datos, sus matrículas y sus notas
> **para** responder consultas de acudientes sin abrir tres pantallas distintas.

**Criterios de aceptación**

- **CA-1** *Dado* que abro la ficha, *cuando* carga, *entonces* veo datos personales, cursos
  matriculados del período activo, notas por corte y promedio.
- **CA-2** *Dado* que el estudiante no tiene matrículas, *cuando* abro la ficha, *entonces* aparece
  "El estudiante no tiene matrículas en el período actual".

**Prioridad:** Should have · **Estimación:** 5 SP · **Depende de:** HU-07, HU-15, HU-21

---

### EP-03 · Gestión de docentes

---

#### HU-11 — Registrar y administrar docentes

> **Como** administrador
> **quiero** registrar docentes con sus datos y su área de conocimiento
> **para** poder asignarles cursos y darles acceso al registro de notas.

**Criterios de aceptación**

- **CA-1** *Dado* que diligencio documento, nombres, apellidos, correo, teléfono y área, *cuando*
  guardo, *entonces* el sistema crea el docente en estado `ACTIVO` con su usuario rol `DOCENTE`.
- **CA-2** *Dado* que el documento ya existe (RN-01), *cuando* guardo, *entonces* el sistema rechaza
  el registro.
- **CA-3** *Dado* un docente existente, *cuando* edito sus datos y guardo, *entonces* los cambios se
  reflejan en el listado.
- **CA-4** *Dado* un docente con cursos asignados en el período activo, *cuando* intento
  inactivarlo, *entonces* el sistema advierte "El docente tiene N cursos asignados" y exige
  reasignarlos antes de continuar.

**Prioridad:** Must have · **Estimación:** 5 SP · **Depende de:** HU-03

---

#### HU-12 — Asignar un docente a un curso

> **Como** administrador
> **quiero** asignar el docente responsable de cada curso
> **para** que pueda ver su lista de clase y registrar las notas.

**Criterios de aceptación**

- **CA-1** *Dado* un curso sin docente, *cuando* selecciono un docente activo y guardo, *entonces*
  el curso queda asociado a él y el docente ve el curso en "Mis cursos".
- **CA-2** *Dado* un curso con docente asignado, *cuando* lo reasigno a otro docente, *entonces* el
  docente anterior pierde acceso al registro de notas de ese curso y el nuevo lo obtiene.
- **CA-3** *Dado* un docente inactivo, *cuando* intento asignarlo, *entonces* no aparece entre las
  opciones seleccionables.
- **CA-4** *Dado* un curso sin docente asignado, *cuando* el administrador intenta activarlo para
  matrícula, *entonces* el sistema advierte que el curso no tiene docente responsable.

**Prioridad:** Must have · **Estimación:** 3 SP · **Depende de:** HU-11, HU-14

---

### EP-04 · Oferta académica

---

#### HU-13 — Administrar períodos académicos

> **Como** administrador
> **quiero** crear períodos académicos y marcar cuál está activo
> **para** que las matrículas y las notas queden asociadas al período correcto.

**Criterios de aceptación**

- **CA-1** *Dado* que registro un período con código `2026-1`, fecha de inicio y fecha de fin,
  *cuando* guardo, *entonces* el período se crea en estado `PLANEADO`.
- **CA-2** *Dado* un período `PLANEADO`, *cuando* lo activo, *entonces* pasa a `ACTIVO` y cualquier
  otro período activo pasa automáticamente a `CERRADO` (RN-03).
- **CA-3** *Dado* que la fecha de fin es anterior a la de inicio, *cuando* guardo, *entonces* el
  sistema muestra un error de validación.
- **CA-4** *Dado* que cierro un período, *cuando* un docente intenta modificar notas de ese período,
  *entonces* el sistema lo impide (RN-17).

**Prioridad:** Must have · **Estimación:** 5 SP · **Depende de:** HU-04

---

#### HU-14 — Administrar cursos

> **Como** administrador
> **quiero** crear, editar e inactivar cursos con su código, nombre, créditos y cupo
> **para** definir la oferta académica del período.

**Criterios de aceptación**

- **CA-1** *Dado* que registro un curso con código, nombre, créditos, cupo y período, *cuando*
  guardo, *entonces* el curso queda creado con 0 matriculados.
- **CA-2** *Dado* que el código de curso ya existe en el mismo período, *cuando* guardo, *entonces*
  el sistema rechaza el registro.
- **CA-3** *Dado* que ingreso un cupo igual a 0 o negativo, o créditos no positivos, *cuando*
  guardo, *entonces* el sistema muestra un error de validación.
- **CA-4** *Dado* un curso con 15 matriculados, *cuando* intento reducir el cupo a 10, *entonces* el
  sistema lo impide e informa que ya hay 15 estudiantes matriculados.
- **CA-5** *Dado* un curso con matrículas activas, *cuando* intento eliminarlo, *entonces* el
  sistema solo permite inactivarlo (RN-15).

**Prioridad:** Must have · **Estimación:** 8 SP · **Depende de:** HU-13

---

#### HU-17 — Configurar los cortes evaluativos de un curso

> **Como** administrador
> **quiero** definir los cortes de evaluación y su porcentaje
> **para** que el sistema pueda calcular la nota definitiva automáticamente.

**Criterios de aceptación**

- **CA-1** *Dado* un curso, *cuando* defino tres cortes con 30 %, 30 % y 40 %, *entonces* el sistema
  guarda la configuración.
- **CA-2** *Dado* que los porcentajes suman 90 % o 110 %, *cuando* guardo, *entonces* el sistema
  rechaza la configuración con "Los porcentajes deben sumar 100 %" (RN-10).
- **CA-3** *Dado* que ya existen notas registradas, *cuando* modifico los porcentajes, *entonces* el
  sistema recalcula las definitivas y advierte del impacto antes de guardar.

**Prioridad:** Must have · **Estimación:** 5 SP · **Depende de:** HU-14

---

#### HU-28 — Definir el horario de un curso *(versión 2)*

> **Como** administrador
> **quiero** registrar el día y la hora en que se dicta cada curso
> **para** que estudiantes y docentes consulten su horario.

**Criterios de aceptación (resumen)**

- El sistema permite registrar día, hora de inicio y hora de fin por curso.
- El sistema advierte cuando un docente queda con dos cursos en el mismo bloque horario.

**Prioridad:** Could have · **Estimación:** 8 SP · **Depende de:** HU-14

---

### EP-05 · Matrícula

---

#### HU-15 — Matricular un estudiante en un curso

> **Como** administrador
> **quiero** matricular a un estudiante en un curso del período activo
> **para** conformar la lista de clase con las reglas de la institución aplicadas automáticamente.

**Criterios de aceptación**

- **CA-1 · Matrícula exitosa**
  *Dado* un estudiante activo, un curso del período activo con cupos disponibles y sin matrícula
  previa en ese curso,
  *cuando* confirmo la matrícula,
  *entonces* el sistema la crea en estado `ACTIVA`, incrementa en 1 los matriculados del curso y
  muestra "Matrícula registrada correctamente".
- **CA-2 · Curso sin cupo (RN-05)**
  *Dado* un curso cuyo número de matriculados es igual a su cupo,
  *cuando* intento matricular,
  *entonces* el sistema rechaza la operación con "El curso no tiene cupos disponibles" y el conteo
  no cambia.
- **CA-3 · Matrícula duplicada (RN-04)**
  *Dado* un estudiante ya matriculado en ese curso y período,
  *cuando* intento matricularlo otra vez,
  *entonces* el sistema rechaza la operación con "El estudiante ya está matriculado en este curso".
- **CA-4 · Estudiante inactivo (RN-06)**
  *Dado* un estudiante con estado `INACTIVO`,
  *cuando* intento matricularlo,
  *entonces* el sistema lo impide e informa que el estudiante no está activo.
- **CA-5 · Sin período activo (RN-07)**
  *Dado* que no hay ningún período en estado `ACTIVO`,
  *cuando* entro a matrícula,
  *entonces* el sistema informa "No hay un período académico activo" y deshabilita la operación.
- **CA-6 · Tope de cursos (RN-14)**
  *Dado* un estudiante con 7 matrículas activas en el período,
  *cuando* intento matricularlo en un octavo curso,
  *entonces* el sistema rechaza la operación indicando el tope permitido.
- **CA-7 · Registro de la operación**
  *Dado* que la matrícula se registró,
  *cuando* consulto el detalle,
  *entonces* aparecen la fecha de matrícula y el usuario que la realizó.

**Prioridad:** Must have · **Estimación:** 13 SP · **Depende de:** HU-06, HU-13, HU-14

---

#### HU-16 — Cancelar una matrícula

> **Como** administrador
> **quiero** cancelar la matrícula de un estudiante en un curso
> **para** liberar el cupo cuando el estudiante se retira de la asignatura.

**Criterios de aceptación**

- **CA-1** *Dado* una matrícula `ACTIVA`, *cuando* la cancelo y confirmo, *entonces* su estado pasa
  a `CANCELADA` y el curso recupera un cupo (RN-16).
- **CA-2** *Dado* una matrícula cancelada, *cuando* consulto la lista de clase del curso, *entonces*
  el estudiante ya no aparece.
- **CA-3** *Dado* una matrícula cancelada con notas registradas, *cuando* consulto el historial,
  *entonces* las notas se conservan marcadas como pertenecientes a una matrícula cancelada.
- **CA-4** *Dado* que el período está cerrado, *cuando* intento cancelar una matrícula, *entonces*
  el sistema lo impide.

**Prioridad:** Must have · **Estimación:** 5 SP · **Depende de:** HU-15

---

#### HU-22 — Consultar la lista de clase de un curso

> **Como** docente o administrador
> **quiero** ver los estudiantes matriculados en un curso
> **para** saber exactamente quiénes conforman el grupo.

**Criterios de aceptación**

- **CA-1** *Dado* un curso con matrículas activas, *cuando* abro la lista de clase, *entonces* veo
  código, nombre completo y estado de cada estudiante, ordenados alfabéticamente.
- **CA-2** *Dado* que soy docente, *cuando* intento abrir la lista de un curso que no dicto,
  *entonces* el sistema lo impide (RN-08).
- **CA-3** *Dado* un curso sin matriculados, *cuando* abro la lista, *entonces* aparece "Este curso
  aún no tiene estudiantes matriculados".
- **CA-4** *Dado* que abro la lista, *cuando* se muestra el encabezado, *entonces* veo el total de
  matriculados y los cupos disponibles.

**Prioridad:** Must have · **Estimación:** 3 SP · **Depende de:** HU-15

---

#### HU-27 — Autogestión de matrícula por el estudiante *(versión 2)*

> **Como** estudiante
> **quiero** matricularme yo mismo en los cursos disponibles
> **para** no depender de la ventanilla de secretaría.

**Criterios de aceptación (resumen)**

- El estudiante ve solo los cursos con cupo del período activo.
- Se aplican las mismas reglas RN-04, RN-05, RN-06, RN-07 y RN-14.
- La matrícula queda registrada con autor = el propio estudiante.

**Prioridad:** Could have · **Estimación:** 8 SP · **Depende de:** HU-15

---

### EP-06 · Registro de calificaciones

---

#### HU-18 — Registrar calificaciones de un corte

> **Como** docente
> **quiero** registrar las notas de un corte para los estudiantes de mi curso
> **para** dejar la evaluación en el sistema sin usar hojas de cálculo externas.

**Criterios de aceptación**

- **CA-1 · Registro exitoso**
  *Dado* que abro un curso que dicto y selecciono el Corte 1,
  *cuando* ingreso la nota de cada estudiante y guardo,
  *entonces* el sistema almacena las notas y confirma "Notas registradas correctamente".
- **CA-2 · Rango válido (RN-09)**
  *Dado* que ingreso una nota de 5.5 o de -1,
  *cuando* intento guardar,
  *entonces* el sistema marca el campo con "La nota debe estar entre 0.0 y 5.0" y no guarda ninguna
  fila.
- **CA-3 · Curso ajeno (RN-08)**
  *Dado* que soy docente,
  *cuando* intento registrar notas en un curso que no tengo asignado,
  *entonces* el sistema deniega la operación.
- **CA-4 · Guardado parcial**
  *Dado* que dejo notas en blanco para algunos estudiantes,
  *cuando* guardo,
  *entonces* el sistema guarda las diligenciadas y deja las demás pendientes, indicando cuántas
  faltan.
- **CA-5 · Trazabilidad**
  *Dado* que guardé una nota,
  *cuando* se consulta el registro,
  *entonces* quedan almacenados el docente que la registró y la fecha y hora.

**Prioridad:** Must have · **Estimación:** 13 SP · **Depende de:** HU-12, HU-17, HU-22

---

#### HU-19 — Modificar una calificación registrada

> **Como** docente
> **quiero** corregir una nota que registré mal
> **para** subsanar errores de digitación antes del cierre del período.

**Criterios de aceptación**

- **CA-1** *Dado* una nota registrada en un período abierto, *cuando* la modifico y guardo,
  *entonces* el sistema actualiza el valor y recalcula la definitiva.
- **CA-2** *Dado* que modifico una nota, *cuando* se guarda, *entonces* el sistema conserva el valor
  anterior, el nuevo, el autor y la fecha del cambio (RN-18).
- **CA-3** *Dado* un período cerrado, *cuando* intento modificar una nota, *entonces* el sistema lo
  impide con "El período está cerrado" (RN-17).
- **CA-4** *Dado* que soy administrador, *cuando* modifico una nota de cualquier curso, *entonces*
  el sistema lo permite y lo registra como cambio administrativo.

**Prioridad:** Must have · **Estimación:** 8 SP · **Depende de:** HU-18

---

#### HU-21 — Calcular la nota definitiva

> **Como** docente
> **quiero** que el sistema calcule la nota definitiva de cada estudiante
> **para** no hacer el promedio ponderado a mano en una hoja de cálculo.

**Criterios de aceptación**

- **CA-1** *Dado* un curso con cortes 30/30/40 y un estudiante con notas 4.0, 3.0 y 5.0, *cuando*
  consulto su definitiva, *entonces* el sistema muestra **4.1** (RN-11).
- **CA-2** *Dado* que faltan notas de algún corte, *cuando* consulto la definitiva, *entonces* el
  sistema muestra el valor parcial y la marca "Pendiente".
- **CA-3** *Dado* una definitiva de 3.0 o superior, *cuando* se muestra el resultado, *entonces*
  aparece como `APROBADO`; por debajo de 3.0 aparece como `REPROBADO` (RN-12).
- **CA-4** *Dado* que se redondea el resultado, *cuando* se presenta, *entonces* se muestra con un
  decimal aplicando redondeo estándar.

**Prioridad:** Must have · **Estimación:** 8 SP · **Depende de:** HU-17, HU-18

---

#### HU-20 — Cerrar el registro de notas de un curso

> **Como** docente
> **quiero** cerrar el registro de notas de mi curso
> **para** declarar formalmente que las calificaciones están completas.

**Criterios de aceptación**

- **CA-1** *Dado* un curso con todas las notas registradas, *cuando* pulso "Cerrar registro",
  *entonces* el curso pasa a estado `NOTAS CERRADAS` y las notas quedan en solo lectura.
- **CA-2** *Dado* un curso con notas faltantes, *cuando* intento cerrar, *entonces* el sistema
  informa cuántos estudiantes tienen notas pendientes y no permite cerrar.
- **CA-3** *Dado* un curso cerrado, *cuando* el administrador necesita corregir, *entonces* puede
  reabrirlo dejando constancia del motivo.

**Prioridad:** Should have · **Estimación:** 5 SP · **Depende de:** HU-18, HU-21

---

### EP-07 · Consultas del estudiante

---

#### HU-23 — Consultar mis cursos matriculados

> **Como** estudiante
> **quiero** ver los cursos en los que estoy matriculado en el período activo
> **para** confirmar que mi matrícula quedó bien registrada.

**Criterios de aceptación**

- **CA-1** *Dado* que ingreso con mi cuenta, *cuando* abro "Mis cursos", *entonces* veo código,
  nombre, créditos y docente de cada curso con matrícula `ACTIVA`.
- **CA-2** *Dado* que no tengo matrículas en el período, *cuando* abro la pantalla, *entonces*
  aparece "No tienes cursos matriculados en el período actual".
- **CA-3** *Dado* que otro estudiante tiene matrículas, *cuando* consulto, *entonces* nunca veo
  información que no sea la mía.

**Prioridad:** Must have · **Estimación:** 3 SP · **Depende de:** HU-15

---

#### HU-24 — Consultar mis calificaciones

> **Como** estudiante
> **quiero** consultar mis notas por curso y por corte
> **para** conocer mi desempeño sin ir a secretaría.

**Criterios de aceptación**

- **CA-1** *Dado* que tengo notas registradas, *cuando* abro "Mis notas", *entonces* veo por cada
  curso la nota de cada corte, la definitiva y el estado `APROBADO` / `REPROBADO`.
- **CA-2** *Dado* que un docente aún no registra un corte, *cuando* consulto, *entonces* ese corte
  aparece como "Pendiente" y no como 0.0.
- **CA-3** *Dado* que consulto mis notas, *cuando* se muestran, *entonces* no puedo modificarlas de
  ninguna forma.

**Prioridad:** Must have · **Estimación:** 5 SP · **Depende de:** HU-18, HU-21

---

#### HU-25 — Consultar mi promedio general

> **Como** estudiante
> **quiero** ver mi promedio general del período
> **para** saber si estoy en riesgo académico.

**Criterios de aceptación**

- **CA-1** *Dado* que tengo definitivas en todos mis cursos, *cuando* abro mi resumen, *entonces*
  veo el promedio ponderado por créditos (RN-13).
- **CA-2** *Dado* que tengo cursos sin definitiva, *cuando* consulto, *entonces* el sistema muestra
  el promedio parcial y advierte que hay cursos pendientes.
- **CA-3** *Dado* que mi promedio es inferior a 3.0, *cuando* se muestra, *entonces* aparece un
  aviso de riesgo académico.

**Prioridad:** Should have · **Estimación:** 5 SP · **Depende de:** HU-21

---

### EP-08 · Reportes

---

#### HU-26 — Generar el boletín de un estudiante

> **Como** administrador
> **quiero** generar el boletín de un estudiante del período
> **para** entregar un consolidado formal a él o a su acudiente.

**Criterios de aceptación**

- **CA-1** *Dado* un estudiante con matrículas y notas, *cuando* genero el boletín, *entonces* el
  documento incluye datos del estudiante, período, cursos, notas por corte, definitiva, estado y
  promedio general.
- **CA-2** *Dado* que genero el boletín, *cuando* se produce, *entonces* puedo exportarlo o
  imprimirlo.
- **CA-3** *Dado* un estudiante sin matrículas, *cuando* intento generar el boletín, *entonces* el
  sistema informa que no hay información para el período.

**Prioridad:** Should have · **Estimación:** 8 SP · **Depende de:** HU-21, HU-25

---

#### HU-29 — Consultar la ocupación de los cursos *(versión 2)*

> **Como** administrador
> **quiero** ver cuántos cupos ocupados y disponibles tiene cada curso
> **para** decidir si abro otro grupo o cierro un curso con baja demanda.

**Criterios de aceptación (resumen)**

- El reporte lista todos los cursos del período con cupo, matriculados, disponibles y % de
  ocupación.
- Los cursos con ocupación inferior al 30 % se resaltan como candidatos a cierre.

**Prioridad:** Should have · **Estimación:** 5 SP · **Depende de:** HU-15

---

#### HU-30 — Tablero resumen del administrador *(versión 2)*

> **Como** administrador
> **quiero** un tablero con los indicadores del período
> **para** tener la foto de la institución al entrar al sistema.

**Criterios de aceptación (resumen)**

- Muestra total de estudiantes activos, docentes activos, cursos abiertos y matrículas del período.
- Muestra el porcentaje de cursos con notas cerradas.

**Prioridad:** Could have · **Estimación:** 8 SP · **Depende de:** HU-15, HU-20

---

### EP-09 · Notificaciones *(fuera del MVP)*

---

#### HU-31 — Notificar publicación de notas

> **Como** estudiante **quiero** recibir un correo cuando mi docente publique las notas de un corte
> **para** enterarme sin revisar el sistema todos los días.
> **Prioridad:** Won't have (esta versión) · **Estimación:** 8 SP

#### HU-32 — Recuperar contraseña por correo

> **Como** usuario **quiero** recuperar mi contraseña desde un enlace enviado a mi correo
> **para** no depender del administrador cuando la olvide.
> **Prioridad:** Won't have (esta versión) · **Estimación:** 8 SP

---

## 10. Priorización

### 10.1 Criterio de priorización

Se combinan dos técnicas:

1. **MoSCoW** — clasificación cualitativa: *Must / Should / Could / Won't*.
2. **Valor vs. esfuerzo** — puntaje de 1 a 5 en valor de negocio, riesgo si no se hace y esfuerzo.
   El índice de prioridad se calcula como:

```
Prioridad = (Valor de negocio + Riesgo si no se implementa) / Esfuerzo
```

A mayor índice, antes se implementa.

### 10.2 Tabla de priorización

| HU | Historia | Épica | Valor | Riesgo | Esfuerzo (SP) | Índice | MoSCoW | Sprint |
|---|---|---|---|---|---|---|---|---|
| HU-03 | Administrar usuarios y roles | EP-01 | 5 | 5 | 8 | 1.25 | Must | 1 |
| HU-01 | Iniciar sesión | EP-01 | 5 | 5 | 5 | 2.00 | Must | 1 |
| HU-02 | Cerrar sesión | EP-01 | 3 | 4 | 2 | 3.50 | Must | 1 |
| HU-04 | Restringir por rol | EP-01 | 5 | 5 | 5 | 2.00 | Must | 1 |
| HU-06 | Registrar estudiante | EP-02 | 5 | 5 | 5 | 2.00 | Must | 1 |
| HU-07 | Consultar/buscar estudiantes | EP-02 | 4 | 3 | 3 | 2.33 | Must | 1 |
| HU-08 | Actualizar estudiante | EP-02 | 3 | 3 | 3 | 2.00 | Must | 2 |
| HU-11 | Registrar docentes | EP-03 | 5 | 4 | 5 | 1.80 | Must | 2 |
| HU-13 | Administrar períodos | EP-04 | 5 | 5 | 5 | 2.00 | Must | 2 |
| HU-14 | Administrar cursos | EP-04 | 5 | 5 | 8 | 1.25 | Must | 2 |
| HU-12 | Asignar docente a curso | EP-03 | 4 | 4 | 3 | 2.67 | Must | 2 |
| HU-17 | Configurar cortes | EP-04 | 4 | 4 | 5 | 1.60 | Must | 2 |
| HU-15 | Matricular estudiante | EP-05 | 5 | 5 | 13 | 0.77 | Must | 3 |
| HU-16 | Cancelar matrícula | EP-05 | 4 | 4 | 5 | 1.60 | Must | 3 |
| HU-22 | Lista de clase | EP-05 | 4 | 3 | 3 | 2.33 | Must | 3 |
| HU-23 | Mis cursos (estudiante) | EP-07 | 4 | 3 | 3 | 2.33 | Must | 3 |
| HU-18 | Registrar calificaciones | EP-06 | 5 | 5 | 13 | 0.77 | Must | 4 |
| HU-21 | Calcular definitiva | EP-06 | 5 | 4 | 8 | 1.13 | Must | 4 |
| HU-19 | Modificar calificación | EP-06 | 4 | 4 | 8 | 1.00 | Must | 4 |
| HU-24 | Mis notas (estudiante) | EP-07 | 5 | 4 | 5 | 1.80 | Must | 4 |
| HU-09 | Inactivar estudiante | EP-02 | 3 | 3 | 3 | 2.00 | Should | 4 |
| HU-25 | Mi promedio | EP-07 | 4 | 3 | 5 | 1.40 | Should | 4 |
| HU-05 | Cambiar contraseña | EP-01 | 3 | 3 | 3 | 2.00 | Should | 4 |
| HU-26 | Boletín del estudiante | EP-08 | 4 | 3 | 8 | 0.88 | Should | v2 |
| HU-20 | Cerrar registro de notas | EP-06 | 3 | 3 | 5 | 1.20 | Should | v2 |
| HU-10 | Ficha completa | EP-02 | 3 | 2 | 5 | 1.00 | Should | v2 |
| HU-29 | Ocupación de cursos | EP-08 | 3 | 2 | 5 | 1.00 | Should | v2 |
| HU-27 | Automatrícula | EP-05 | 3 | 2 | 8 | 0.63 | Could | v2 |
| HU-28 | Horario del curso | EP-04 | 3 | 2 | 8 | 0.63 | Could | v2 |
| HU-30 | Tablero del administrador | EP-08 | 2 | 1 | 8 | 0.38 | Could | v2 |
| HU-31 | Notificar notas | EP-09 | 2 | 1 | 8 | 0.38 | Won't | — |
| HU-32 | Recuperar contraseña | EP-09 | 2 | 2 | 8 | 0.50 | Won't | — |

> **Nota sobre HU-15 y HU-18:** su índice es bajo únicamente por su tamaño (13 SP), no por su
> importancia. Son el núcleo del sistema y por eso se ubican en sprints propios; si el equipo
> requiere, se dividen en historias más pequeñas durante el refinamiento.

### 10.3 Matriz valor / esfuerzo

```
  ALTO  |  HU-01 HU-02 HU-04     |  HU-03 HU-14 HU-15
 VALOR  |  HU-06 HU-07 HU-12     |  HU-18 HU-19 HU-21
        |  HU-13 HU-22 HU-23     |  HU-26
        |  HU-24 HU-17           |
        |------------------------+------------------------
  BAJO  |  HU-05 HU-08 HU-09     |  HU-10 HU-27 HU-28
 VALOR  |  HU-25                 |  HU-29 HU-30 HU-31 HU-32
        |    BAJO ESFUERZO       |    ALTO ESFUERZO
           (hacer primero)          (planear y dividir)
```

---

## 11. Definición del MVP y roadmap

### 11.1 Qué entra en el MVP

El MVP es la versión más pequeña del sistema que **resuelve el problema central**: tener una fuente
única de verdad para estudiantes, docentes, cursos, matrículas y notas.

**23 historias · 126 puntos de historia · 4 sprints de 2 semanas.**

| Épica | Historias del MVP | SP |
|---|---|---|
| EP-01 Acceso y seguridad | HU-01, HU-02, HU-03, HU-04, HU-05 | 23 |
| EP-02 Estudiantes | HU-06, HU-07, HU-08, HU-09 | 14 |
| EP-03 Docentes | HU-11, HU-12 | 8 |
| EP-04 Oferta académica | HU-13, HU-14, HU-17 | 18 |
| EP-05 Matrícula | HU-15, HU-16, HU-22 | 21 |
| EP-06 Calificaciones | HU-18, HU-19, HU-21 | 29 |
| EP-07 Consultas del estudiante | HU-23, HU-24, HU-25 | 13 |
| **Total** | **23 historias** | **126** |

### 11.2 Qué no entra y por qué

| Historia | Razón de exclusión |
|---|---|
| HU-10 Ficha completa | Se puede resolver combinando HU-07 y HU-24 en la v1 |
| HU-20 Cerrar notas | El cierre puede hacerse manualmente cerrando el período (HU-13) |
| HU-26 Boletín | El estudiante ya ve sus notas en pantalla (HU-24); el PDF puede esperar |
| HU-27 Automatrícula | La matrícula por ventanilla (HU-15) cubre la necesidad inicial |
| HU-28 Horarios | Requiere un modelo de bloques horarios que multiplica el alcance |
| HU-29, HU-30 Reportes | Son analítica, no operación: el sistema funciona sin ellos |
| HU-31, HU-32 Notificaciones | Dependen de infraestructura de correo, fuera del alcance académico |

### 11.3 Roadmap por sprints

| Sprint | Objetivo (Sprint Goal) | Historias | SP | Demo al final |
|---|---|---|---|---|
| **1** | Un usuario puede entrar al sistema con su rol y el administrador puede registrar estudiantes | HU-03, HU-01, HU-02, HU-04, HU-06, HU-07 | 28 | Inicio de sesión con tres roles y CRUD de estudiantes |
| **2** | La institución puede configurar su oferta académica completa | HU-08, HU-11, HU-13, HU-14, HU-12, HU-17 | 29 | Período activo con cursos, cupos, docentes y cortes |
| **3** | Se pueden conformar las listas de clase con las reglas de negocio aplicadas | HU-15, HU-16, HU-22, HU-23 | 24 | Matrícula con validación de cupo y duplicidad; el estudiante ve sus cursos |
| **4** | El docente califica y el estudiante consulta su resultado | HU-18, HU-21, HU-19, HU-24, HU-25, HU-05, HU-09 | 45 | Ciclo completo: matrícula → nota → definitiva → consulta del estudiante |

> El sprint 4 está sobrecargado respecto a los anteriores. En el refinamiento se evaluará mover
> HU-05, HU-09 y HU-25 al backlog de la v2 si la velocidad medida en los sprints 1–3 no lo permite.

### 11.4 Escenario de humo del MVP (prueba de aceptación de extremo a extremo)

Al terminar el sprint 4 este recorrido debe funcionar completo:

1. El administrador entra al sistema y crea el período `2026-2` y lo activa.
2. Crea el curso `MAT-101 Matemáticas I`, 3 créditos, cupo 30, cortes 30/30/40.
3. Registra al docente Carlos y lo asigna al curso.
4. Registra a la estudiante Valentina.
5. Matricula a Valentina en `MAT-101`. El curso pasa a 1/30.
6. Intenta matricularla otra vez: **el sistema lo impide.**
7. Carlos entra con su cuenta, ve a Valentina en su lista de clase y registra 4.0 en el Corte 1.
8. Intenta registrar 5.8: **el sistema lo impide.**
9. Valentina entra con su cuenta, ve `MAT-101`, su nota 4.0 y su definitiva parcial.
10. Valentina intenta abrir la gestión de estudiantes por URL: **el sistema lo impide.**

---

## 12. Definition of Ready y Definition of Done

### 12.1 Definition of Ready (DoR) — una historia puede entrar a un sprint si:

- [ ] Está escrita en formato "Como… quiero… para…" con rol, funcionalidad y beneficio claros.
- [ ] Tiene al menos tres criterios de aceptación verificables en formato Gherkin.
- [ ] Está estimada por el equipo y no supera los 13 SP (si los supera, se divide).
- [ ] Tiene identificadas sus dependencias y estas ya están resueltas o planificadas antes.
- [ ] Referencia las reglas de negocio que la condicionan.
- [ ] La historia se entiende sin consultar a su autor: lo escrito basta para implementarla.
- [ ] Tiene definido qué se muestra al usuario cuando la operación falla.

### 12.2 Definition of Done (DoD) — una historia está terminada si:

- [ ] El código está en la rama principal, integrado por un pull request con su autorrevisión escrita.
- [ ] Todos los criterios de aceptación pasan la prueba manual documentada.
- [ ] Se aplicaron las validaciones de negocio correspondientes, no solo el "camino feliz".
- [ ] Los mensajes de error son claros y en español.
- [ ] La funcionalidad respeta el control de acceso por rol.
- [ ] No rompe funcionalidades entregadas en sprints anteriores (prueba de regresión mínima).
- [ ] Está documentada en el repositorio y demostrada en la revisión del sprint.

---

## 13. Supuestos, restricciones y riesgos

### 13.1 Supuestos

| ID | Supuesto | Cómo se valida |
|---|---|---|
| S-1 | Cada estudiante y cada docente tiene un correo electrónico propio | Confirmar con secretaría en Fase 2 |
| S-2 | La institución trabaja con dos períodos académicos al año | Confirmar con coordinación |
| S-3 | La escala de calificación es de 0.0 a 5.0 y se aprueba con 3.0 | Confirmar con el reglamento estudiantil |
| S-4 | Un curso lo dicta un único docente responsable | Confirmar; si hay codocencia cambia el modelo de datos |
| S-5 | La institución cuenta con conexión a internet estable en secretaría | Verificar antes del despliegue |

### 13.2 Restricciones

| ID | Restricción | Origen |
|---|---|---|
| R-1 | El proyecto se desarrolla en seis fases con entregables definidos | Metodología del curso |
| R-2 | El equipo dispone de un tiempo limitado (4 sprints para el MVP) | Cronograma académico |
| R-3 | El sistema debe ser web y funcionar en navegadores actuales | Definido en el alcance |
| R-4 | No se manejará información de pagos ni datos financieros | Alcance del proyecto |
| R-5 | Los datos personales de menores exigen manejo responsable | Normativa de protección de datos |

### 13.3 Riesgos

| ID | Riesgo | Prob. | Impacto | Mitigación |
|---|---|---|---|---|
| RG-1 | El alcance crece con peticiones nuevas ("y también que haga…") | Alta | Alto | Backlog congelado para el MVP; lo nuevo entra al backlog de la v2 |
| RG-2 | Las historias grandes (HU-15, HU-18) no caben en un sprint | Media | Alto | Dividirlas en refinamiento antes del sprint 3 |
| RG-3 | Las reglas de negocio reales difieren de las supuestas (escala de notas, cortes) | Media | Alto | Validar S-3 y S-4 antes del sprint 2 |
| RG-4 | Resistencia de los docentes a abandonar sus hojas de cálculo | Media | Medio | Prototipo temprano en Fase 5 y capacitación con Carlos como usuario piloto |
| RG-5 | El equipo aún no domina la tecnología elegida | Media | Medio | Definir el stack en Fase 2 y hacer una prueba técnica antes del sprint 1 |
| RG-6 | Los datos de prueba no representan casos reales (nombres repetidos, documentos raros) | Baja | Medio | Cargar datos realistas en la Fase 4 |

---

## 14. Métricas de éxito

| Indicador | Situación actual | Meta con el MVP | Cómo se mide |
|---|---|---|---|
| Tiempo de consolidación de notas del período | ~3 semanas | < 1 día | Fecha de cierre de notas vs. fecha de boletines |
| Sobrecupos por período | 4–6 | 0 | Consulta de matriculados vs. cupo |
| Registros de estudiante duplicados | Desconocido, se detectan a mano | 0 | Restricción de unicidad por documento |
| Consultas de nota atendidas en ventanilla | Alta al cierre del período | Reducción del 70 % | Conteo en secretaría antes y después |
| Notas registradas fuera del sistema | 100 % | < 5 % | % de cursos con notas completas en el sistema |
| Docentes que usan el sistema para registrar notas | 0 | ≥ 90 % | Usuarios docentes con al menos un registro |
| Errores de cálculo en boletines | Recurrentes | 0 | Revisión de muestra de boletines |

---

## 15. Trazabilidad épica → historia

Esta matriz es la entrada directa de la Fase 2, donde cada historia se convertirá en uno o más
requerimientos funcionales.

| Épica | Historias | ¿En el MVP? | Objetivo específico que cumple |
|---|---|---|---|
| EP-01 Acceso y seguridad | HU-01, HU-02, HU-03, HU-04, HU-05 | Sí | OE-1 |
| EP-02 Gestión de estudiantes | HU-06, HU-07, HU-08, HU-09 / HU-10 (v2) | Sí (parcial) | OE-2 |
| EP-03 Gestión de docentes | HU-11, HU-12 | Sí | OE-2, OE-3 |
| EP-04 Oferta académica | HU-13, HU-14, HU-17 / HU-28 (v2) | Sí (parcial) | OE-3 |
| EP-05 Matrícula | HU-15, HU-16, HU-22 / HU-27 (v2) | Sí (parcial) | OE-4 |
| EP-06 Calificaciones | HU-18, HU-19, HU-21 / HU-20 (v2) | Sí (parcial) | OE-5 |
| EP-07 Consultas del estudiante | HU-23, HU-24, HU-25 | Sí | OE-6 |
| EP-08 Reportes | HU-22 / HU-26, HU-29, HU-30 (v2) | Parcial | OE-7 |
| EP-09 Notificaciones | HU-31, HU-32 | No | — |

**Resumen:** 9 épicas · 32 historias de usuario · 23 en el MVP · 126 puntos de historia.

---

## 16. Checklist de cierre de la Fase 1

| Actividad solicitada | Estado | Dónde está en este documento |
|---|---|---|
| Identificar el problema que resolverá el proyecto | ✅ | Sección 1 (árbol de problemas y formulación) |
| Definir el objetivo general | ✅ | Sección 2.1 |
| Identificar actores / usuarios | ✅ | Sección 4 (actores, personas y stakeholders) |
| Crear las épicas | ✅ | Sección 8 (9 épicas) |
| Crear historias de usuario | ✅ | Sección 9 (32 historias) |
| Definir criterios de aceptación | ✅ | Sección 9 (formato Gherkin por historia) |
| Priorizar las historias para determinar el MVP | ✅ | Secciones 10 y 11 |

**Entradas listas para la Fase 2 (Requerimientos):** glosario (sección 5), reglas de negocio
candidatas (sección 6), restricciones (sección 13.2), criterios de aceptación (sección 9) y matriz
de trazabilidad (sección 15).
