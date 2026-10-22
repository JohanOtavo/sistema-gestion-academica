# Fase 5 — Mockup y Prototipo Navegable
## Sistema de Gestión Académica (SGA)

| Campo | Detalle |
|---|---|
| **Proyecto** | Sistema de Gestión Académica (SGA) |
| **Grupo** | 6 |
| **Integrante** | Jannier Johan Otavo |
| **Fase** | 5 de 6 — Mockup / Prototipo |
| **Entregable** | Estructura de navegación, sistema de diseño, 24 pantallas y prototipo navegable |
| **Versión** | 1.0 |
| **Fecha** | 15 de octubre de 2026 |
| **Fase anterior** | [Fase 4 — Diseño de la base de datos](../fase4-base-de-datos/fase4-base-de-datos.md) |
| **Estado** | Listo para revisión / entrada a Fase 6 (Programa funcional) |

---

## Índice

1. [Introducción](#1-introduccion)
2. [Estructura de Navegación](#2-estructura-de-navegacion)
3. [Sistema de Diseño](#3-sistema-de-diseno)
4. [Inventario de Pantallas](#4-inventario-de-pantallas)
5. [Formularios y Validación](#5-formularios-y-validacion)
6. [Listados y Consultas](#6-listados-y-consultas)
7. [Detalle de Registros](#7-detalle-de-registros)
8. [Catálogo de Mensajes](#8-catalogo-de-mensajes)
9. [Flujos Principales](#9-flujos-principales)
10. [Accesibilidad y Adaptación](#10-accesibilidad-y-adaptacion)
11. [El Prototipo Navegable](#11-el-prototipo-navegable)
12. [Trazabilidad](#12-trazabilidad)
13. [Plan de Validación con Usuarios](#13-plan-de-validacion-con-usuarios)
14. [Decisiones de Diseño de Interfaz](#14-decisiones-de-diseno-de-interfaz)
15. [Conclusiones](#15-conclusiones)
16. [Referencias](#16-referencias)

---


## 1. Introducción


### 1.1 Propósito

Las cuatro fases anteriores definieron qué debe hacer el sistema, cómo se comporta por dentro y
cómo guarda la información. Ninguna respondió la pregunta que un docente hará el primer día:
*¿dónde hago clic para subir las notas?*

Esta fase responde eso. Entrega **24 pantallas** organizadas en una estructura de navegación, un
sistema de diseño con sus componentes, el catálogo de mensajes del sistema y un **prototipo
navegable en Figma** que se recorre completo, con los tres roles, antes de escribir una línea de
código de la aplicación.

El orden importa. Descubrir en el sprint 3 que la pantalla de matrícula necesita mostrar el cupo
disponible obliga a rehacer el controlador, la consulta y la vista. Descubrirlo ahora cuesta mover una
caja en el prototipo.


### 1.2 De la base de datos a la pantalla

El prototipo no inventa datos. Usa **exactamente el juego de prueba de la Fase 4**, de modo que lo
que aparece en pantalla es lo que devuelve la base de datos: Valentina con 4.1 en Matemáticas I,
el curso MAT-101 lleno con 4 de 4 cupos, Ciencias Sociales sin docente asignado y, por lo tanto,
sin calificaciones.

Esa decisión convierte el prototipo en una verificación adicional del modelo. Si una pantalla
necesita un dato que el esquema no tiene, se nota aquí y no en la Fase 6.

**Tabla 1.** *De dónde sale cada elemento de la interfaz*

| Elemento de la pantalla | Origen |
|---|---|
| Qué puede hacer cada rol | Casos de uso de la Fase 3 |
| Qué campos tiene un formulario | Columnas y dominios de la Fase 4 |
| Qué valida el sistema y en qué orden | Reglas de negocio RN-01 a RN-27 |
| Qué dice un mensaje de error | RNF-10 y los flujos de excepción de la Fase 3 |
| Qué columnas tiene un listado | Vistas `vw_*` de la Fase 4 |
| Qué aparece cuando no hay datos | Estados vacíos definidos en esta fase |


### 1.3 Alcance de la fase

| Incluye | No incluye |
|---|---|
| Las 25 historias del producto mínimo viable | Las historias de la versión 2 (boletín, tablero, automatrícula) |
| Prototipo navegable de 24 pantallas | Aplicación funcional: eso es la Fase 6 |
| Sistema de diseño con tokens y componentes | Biblioteca de componentes programada |
| Catálogo de mensajes completo | Traducción a otros idiomas |
| Verificación de adaptación y contraste | Prueba de usabilidad con usuarios reales (plan en la sección 13) |

---


## 2. Estructura de Navegación


### 2.1 El Mapa

La navegación se organiza por rol. No hay un menú único con opciones deshabilitadas: cada rol ve
su propio menú, y lo que no le corresponde sencillamente no existe en su interfaz. Es la
aplicación en pantalla de ADR-003, que ubica la autorización en el servidor.

**Figura 1.** *Mapa de navegación del sistema*

![Mapa de navegación del sistema](diagramas/01-mapa-navegacion.png)

*Nota.* Elaboración propia con PlantUML. El catálogo de mensajes no es una pantalla del sistema:
es la referencia de diseño de los estados de la interfaz.


### 2.2 Las Rutas

**Tabla 2.** *Las 24 pantallas del prototipo*

El nombre de cada pantalla es el del frame en Figma. El prefijo numérico fija el orden de lectura
en el lienzo y agrupa el flujo de contraseña bajo el 02.

| Frame en Figma | Pantalla | Rol |
|---|---|---|
| `01 Acceso` | Acceso | Público |
| `02 Cambio de contraseña` | Cambio obligatorio de contraseña | Público autenticado |
| `02b Olvidé mi contraseña` | Solicitud de restablecimiento | Público |
| `02c Revise su correo` | Confirmación neutra del envío | Público |
| `02d Contraseña nueva` | Contraseña nueva desde el enlace | Público con enlace válido |
| `02e Enlace no válido` | Enlace vencido o ya usado | Público |
| `03 Panel administrador` | Panel del administrador | Administrador |
| `04 Estudiantes` | Listado de estudiantes | Administrador |
| `05 Formulario de estudiante` | Alta y edición de estudiante | Administrador |
| `06 Ficha del estudiante` | Ficha del estudiante | Administrador |
| `07 Docentes` | Listado de docentes | Administrador |
| `08 Cuentas y roles` | Cuentas y roles | Administrador |
| `09 Períodos académicos` | Períodos académicos | Administrador |
| `10 Oferta académica` | Oferta académica | Administrador |
| `11 Formulario de curso` | Curso, docente y cortes | Administrador |
| `12 Matricular estudiante` | Matricular estudiante | Administrador |
| `13 Lista de clase` | Lista de clase | Administrador y docente |
| `14 Panel docente` | Mis cursos | Docente |
| `15 Registrar calificaciones` | Registrar calificaciones | Docente |
| `16 Panel estudiante` | Mis cursos | Estudiante |
| `17 Mis notas` | Mis notas y promedio | Estudiante |
| `18 Catálogo de mensajes` | Catálogo de mensajes | Referencia de diseño |
| `19 Mi perfil` | Mis datos y mis datos de contacto | Los tres roles |
| `20 Cambiar contraseña` | Cambio voluntario de contraseña | Los tres roles |


### 2.3 Reglas de Navegación

Cuatro reglas gobiernan la estructura y se aplican sin excepción en las 24 pantallas.

1. **Tres niveles como máximo.** Desde cualquier panel, cualquier tarea del MVP se alcanza en tres
   interacciones o menos. Es la métrica de RNF-13 y la sección 9 la verifica tarea por tarea.
2. **La ruta siempre visible.** Toda pantalla interior muestra su ruta de regreso
   (`Panel > Estudiantes > Ficha`), de modo que nadie quede sin saber dónde está.
3. **El menú marca dónde se está.** La opción activa se distingue por color y por el atributo
   `aria-current`, para que también lo perciba un lector de pantalla.
4. **Cada rol tiene su panel de entrada.** Al iniciar sesión, el sistema lleva al panel del rol
   correspondiente, nunca a una pantalla genérica.

---


## 3. Sistema de Diseño

Un prototipo de 24 pantallas escritas sin un sistema común produce 18 variantes del mismo botón.
Definimos los tokens y los componentes antes de escribir la primera pantalla.

**Figura 2.** *Sistema de diseño del prototipo*

![Sistema de diseño del prototipo](diagramas/07-sistema-diseno.png)

*Nota.* Elaboración propia con PlantUML. Los tokens alimentan los componentes, y los componentes
construyen las pantallas. Ninguna pantalla define un color propio.


### 3.1 Color

La paleta es la misma de los diagramas de las fases 3 y 4, de modo que el proyecto se ve como una
sola cosa. El color se usa **semánticamente**, no decorativamente: el verde significa que algo
salió bien, el rojo que algo se rechazó, el ámbar que conviene prestar atención.

**Tabla 3.** *Paleta y su contraste sobre el fondo correspondiente*

| Token | Valor | Uso | Contraste |
|---|---|---|---|
| `--azul-900` | `#1f3864` | Títulos y barra superior | 11.6:1 sobre blanco |
| `--azul-600` | `#2e75b6` | Acciones principales | 4.6:1 sobre blanco |
| `--gris-900` | `#1a1a1a` | Texto principal | 15.3:1 sobre blanco |
| `--gris-700` | `#44474d` | Texto secundario y ayudas | 8.9:1 sobre blanco |
| `--verde-texto` | `#10632b` | Confirmación | 7.3:1 sobre su fondo |
| `--rojo-texto` | `#a50e0e` | Error | 7.6:1 sobre su fondo |
| `--ambar-texto` | `#7f6000` | Aviso | 7.1:1 sobre su fondo |

*Nota.* Todas superan el 4.5:1 que exige RNF-12 para texto normal. El mínimo de la paleta es el
azul de acción, con 4.6:1, y se usa únicamente como fondo de botón con texto blanco encima.


### 3.2 Tipografía y Espaciado

Una sola familia tipográfica, la del sistema operativo, por tres razones: carga instantánea, se ve
nativa en cualquier equipo de la institución y no añade una dependencia externa que el despliegue
tenga que resolver (RE-03).

| Elemento | Tamaño | Peso |
|---|---|---|
| Título de pantalla | 1.5 rem | 700 |
| Título de sección | 1.2 rem | 700 |
| Texto base | 1 rem, 16 px | 400 |
| Texto de tabla | 0.92 rem | 400 |
| Ayuda y notas | 0.82 rem | 400 |

El espaciado sigue una escala de 4 píxeles, de 4 a 48. No hay valores arbitrarios: cada margen del
prototipo es uno de esos siete valores.


### 3.3 Componentes

**Tabla 4.** *Componentes del sistema de diseño*

| Componente | Qué resuelve | Dónde aparece |
|---|---|---|
| Barra superior | Identidad, rol activo y salida | Las 24 pantallas |
| Menú lateral | Navegación del rol, con la página actual marcada | 15 pantallas |
| Ruta de navegación | Dónde está el usuario y cómo vuelve | Pantallas interiores |
| Tarjeta | Agrupa información relacionada | Paneles y fichas |
| Banda de encabezado | Sitúa al usuario en el periodo activo | Paneles |
| Indicador | Una cifra grande, su rótulo y su detalle | Paneles |
| Barra de ocupación | Dibuja una proporción que el texto ya enuncia | Panel y listado de cursos |
| Acceso directo | Las tareas frecuentes a un clic | Paneles |
| Tabla de datos | Listados, se apila en móvil | 12 pantallas |
| Distintivo de estado | Activo, lleno, pendiente, aprobada | Listados y fichas |
| Filtros | Búsqueda, filtro y orden de un listado | 6 listados |
| Campo de formulario | Rótulo, control, ayuda y error | Formularios |
| Botón | Principal, secundario y de peligro | Todas las acciones |
| Mensaje | Éxito, error, aviso e información | Catálogo completo |
| Estado vacío | No hay datos y qué hacer al respecto | Listados |
| Paginación | Recorrer listados largos | Listados |


### 3.4 Profundidad y Movimiento

Una interfaz plana obliga a leerlo todo para saber qué es importante. La jerarquía se refuerza con
dos recursos: **elevación** y **movimiento**.

**Elevación.** Cuatro niveles de sombra, declarados como estilos de efecto y aplicados según cuánto
se adelanta un elemento respecto del fondo. El menú y las tarjetas usan el nivel 1; la banda de
encabezado y los elementos que responden al puntero, el 4. Los degradados siguen la misma lógica:
el azul institucional se oscurece hacia el fondo y se aclara hacia adelante.

**Movimiento.** En el prototipo, cada conexión entre pantallas se genera con *Smart Animate*,
salida suave y 300 ms. Como las 24 pantallas comparten la barra superior y el menú con el mismo
nombre y la misma posición, Figma los reconoce entre pantallas y los interpola en lugar de cortar.

Para la Fase 6, el movimiento dentro de cada pantalla queda especificado aquí. Todo se anima sobre
`transform` y `opacity`, las dos propiedades que el navegador resuelve sin rehacer el diseño de la
página:

| Momento | Qué ocurre | Duración |
|---|---|---|
| Entrada de la tarjeta de acceso | Aparece y sube 18 px | 520 ms |
| Entrada de sus líneas | Escalonada, en orden de lectura | 420 ms, con retardos de 50 ms |
| Entrada de los indicadores | Escalonada, de izquierda a derecha | 460 ms |
| Barras de ocupación | Crecen desde cero hasta su porcentaje | 900 ms |
| Puntero sobre indicador o acceso directo | Se eleva 4 px y gana sombra | 320 ms |
| Manchas de color del fondo de acceso | Respiran en bucle | 18 y 22 s |

La curva es siempre la misma, `cubic-bezier(.16, 1, .3, 1)`: arranca rápido y frena al final, que
es como se mueve algo con masa.

Estas duraciones no son una ocurrencia: salieron de probarlas en un navegador, en la maqueta de
trabajo con la que se midió la accesibilidad (sección 10.1). La profundidad —degradados, sombras,
cintas de color y barras de ocupación— sí está en el prototipo entregado, porque es pintura y no
animación: vive en el relleno y los efectos de cada frame.

---


## 4. Inventario de Pantallas

**Tabla 5.** *Las 24 pantallas, su caso de uso y su historia*

| Pantalla | Caso de uso | Historia | Tipo |
|---|---|---|---|
| Acceso | CU-01 | HU-01 | Formulario |
| Cambio de contraseña | CU-03 | HU-05 | Formulario |
| Olvidé mi contraseña | CU-28 | HU-32 | Formulario |
| Confirmación del envío | CU-28 | HU-32 | Mensaje |
| Contraseña nueva desde el enlace | CU-28 | HU-32 | Formulario |
| Enlace no válido | CU-28 | HU-32 | Mensaje |
| Panel del administrador | CU-04 a CU-16 | HU-04 | Tablero |
| Listado de estudiantes | CU-05 | HU-07 | Listado |
| Formulario de estudiante | CU-04, CU-06 | HU-06, HU-08 | Formulario |
| Ficha del estudiante | CU-05, CU-07 | HU-07, HU-09 | Detalle |
| Listado de docentes | CU-08, CU-09 | HU-11 | Listado |
| Cuentas y roles | CU-02 | HU-03 | Listado |
| Períodos académicos | CU-10 | HU-13 | Listado y acción |
| Oferta académica | CU-11 | HU-14 | Listado |
| Formulario de curso | CU-11, CU-12, CU-13 | HU-14, HU-12, HU-17 | Formulario |
| Matricular estudiante | CU-14, CU-24, CU-26 | HU-15 | Formulario |
| Lista de clase | CU-15, CU-16 | HU-22, HU-16 | Listado |
| Mis cursos del docente | CU-16 | HU-22 | Tablero |
| Registrar calificaciones | CU-17, CU-18, CU-19 | HU-18, HU-19, HU-21 | Formulario |
| Mis cursos del estudiante | CU-20, CU-22 | HU-23, HU-25 | Tablero |
| Mis notas | CU-21, CU-27 | HU-24 | Consulta |
| Catálogo de mensajes | — | — | Referencia |
| Mi perfil | CU-29 | HU-33 | Detalle y formulario |
| Cambiar contraseña | CU-03 | HU-05 | Formulario |

*Nota.* Las 25 historias del producto mínimo viable quedan cubiertas. Las dos que no aparecen como
pantalla propia son HU-02 (cerrar sesión), que es la acción de la barra superior, y HU-21 (calcular
la definitiva), que no tiene interfaz: el sistema la ejecuta al guardar las notas.

**Figura 3.** *Boceto de la pantalla Matricular estudiante*

![Boceto de la pantalla Matricular estudiante](diagramas/05-wireframe-matricular.png)

*Nota.* Elaboración propia con PlantUML. El boceto fija la estructura; el prototipo la implementa.

**Figura 4.** *Boceto de la pantalla Mis notas*

![Boceto de la pantalla Mis notas](diagramas/06-wireframe-mis-notas.png)

*Nota.* Elaboración propia con PlantUML. La columna de aporte hace visible el cálculo de RN-11 y
evita la pregunta más frecuente en la ventanilla: de dónde salió esa nota.

---


## 5. Formularios y Validación


### 5.1 Anatomía de un Campo

Cada campo tiene cuatro partes, y ninguna es opcional cuando corresponde: el **rótulo**, el
**control**, el **texto de ayuda** que explica la regla antes de incumplirla, y el **mensaje de
error** cuando la incumple.

El texto de ayuda es la pieza más barata y más olvidada. Decir *"mínimo 8 caracteres"* debajo del
campo de contraseña evita que el usuario descubra la regla equivocándose.


### 5.2 Cómo se Marca un Error

Tres señales simultáneas, nunca una sola:

1. **Borde** de 2 píxeles en rojo, en lugar de 1 en gris.
2. **Texto** debajo del campo, con la causa y qué hacer.
3. **Vínculo programático** mediante `aria-describedby`, para que un lector de pantalla lea el
   error al llegar al campo.

El color por sí solo no comunica: una parte de la población no distingue el rojo del verde. Por eso
el error siempre lleva texto además de color.


### 5.3 Dónde se Valida

**Tabla 6.** *Las tres capas de validación y qué le toca a cada una*

| Capa | Qué valida | Ejemplo |
|---|---|---|
| Navegador | Formato y obligatoriedad, de inmediato | Campo vacío, correo sin arroba, nota fuera de 0 a 5 |
| Servidor | Todas las reglas de negocio, otra vez | El cupo, el tope de siete cursos, el período activo |
| Base de datos | Las reglas que corrompen el registro | Documento duplicado, cupo excedido, nota fuera de rango |

*Nota.* La validación del navegador es una cortesía, no una garantía: cualquiera puede saltársela.
Por eso el servidor repite todo (RNF-19) y la base de datos vuelve a verificar lo crítico
(ADR-002). La interfaz no afloja ninguna regla; solo las comunica antes.


### 5.4 El Lote se Guarda Completo o No se Guarda

En el registro de calificaciones, si una sola nota del grupo está fuera de rango **no se guarda
ninguna**. Es la decisión más discutible de esta fase y conviene justificarla: un guardado parcial
dejaría al docente sin saber cuáles alcanzaron a registrarse, y la forma de averiguarlo sería
revisar la lista una por una. Rechazar el lote completo es más molesto en el momento y mucho más
seguro después.

Lo que sí se conserva es lo digitado: el formulario no se vacía, solo señala el campo que hay que
corregir.

---


## 6. Listados y Consultas


### 6.1 Estructura

Los seis listados del sistema comparten la misma estructura: filtros arriba, resumen de lo que se
está viendo, tabla, paginación. Aprender uno es aprender los seis.

**Tabla 7.** *Filtros de cada listado*

| Listado | Buscar por | Filtrar por | Ordenar por |
|---|---|---|---|
| Estudiantes | Nombre o documento | Estado | Apellidos, código, fecha de ingreso |
| Docentes | Nombre o código | Área, estado | Apellidos |
| Cuentas | Correo | Rol, primer ingreso pendiente | Correo |
| Cursos | Código o nombre | Período, ocupación, sin docente | Código |
| Listas de clase | — | Curso, período, estado de la matrícula | Apellidos |
| Mis notas | — | Período, curso, nivel de detalle | Código de curso |


### 6.2 Lo que Nunca Aparece en un Listado

Dos ausencias deliberadas, las dos heredadas de decisiones anteriores:

- **Los registros inactivos**, salvo que se pidan explícitamente con el filtro de estado. Es el
  dolor D-3 de la Fase 1: las listas de clase con nombres de personas que ya no asisten.
- **Las matrículas canceladas** en la lista de clase principal. Se muestran en una sección aparte,
  porque forman parte del historial pero no del grupo.


### 6.3 Las Dos Formas de No Tener Datos

No son lo mismo y no se comunican igual:

| Situación | Qué dice el sistema |
|---|---|
| Todavía no hay registros | *"Este curso todavía no tiene estudiantes matriculados. La lista aparecerá aquí en cuanto registre la primera matrícula."* más el botón para hacerlo |
| El filtro no encontró nada | *"No se encontraron estudiantes con ese criterio. Revise la escritura o quite algún filtro."* más el botón de quitar filtros |

Confundirlas hace que el usuario crea que perdió datos cuando solo escribió mal un apellido.

---


## 7. Detalle de Registros

La ficha del estudiante es la pantalla de detalle de referencia. Responde en un vistazo las tres
preguntas que llegan a la ventanilla: quién es, qué está cursando y qué cursó antes.

**Tabla 8.** *Secciones de la ficha del estudiante*

| Sección | Contenido | Origen |
|---|---|---|
| Encabezado | Nombre y distintivo de estado | `vw_estudiante` |
| Datos personales | Código, documento, contacto, fechas | `persona` y `estudiante` |
| Carga académica | Matrículas activas, créditos, definitiva por curso | `vw_nota_definitiva` |
| Historial | Períodos cerrados con su resultado | `matricula` con la instantánea |
| Acciones | Editar, matricular, inactivar | CU-06, CU-14, CU-07 |

La acción de inactivar es de peligro y se distingue visualmente de las demás: borde rojo, fondo
blanco. No se parece a Guardar, porque no hace lo mismo. Va acompañada de la explicación de qué
significa inactivar, que es justamente lo que un usuario nuevo no sabe: que no se borra nada.

---


## 8. Catálogo de Mensajes

RNF-10 exige que *"los mensajes de error indiquen la causa y la acción correctiva, redactados en
español y sin códigos técnicos"*, y su métrica dice *"100 % de los mensajes del catálogo del
Anexo A"*. **Ese anexo nunca se escribió en la Fase 2.** Queda resuelto aquí, y la pantalla
La pantalla `18 Catálogo de mensajes` del prototipo los muestra todos juntos.


### 8.1 Los Cuatro Tipos

**Tabla 9.** *Tipos de mensaje y cuándo se usa cada uno*

| Tipo | Significa | Ejemplo |
|---|---|---|
| Confirmación | La operación terminó bien | *Matrícula registrada correctamente. El curso pasa de 20 a 21 cupos ocupados.* |
| Error | La operación no se hizo | *El curso no tiene cupos disponibles. Amplíe el cupo o escoja otro grupo.* |
| Aviso | Se hizo, pero hay algo que saber | *Matrícula registrada. Alcanzó el tope de siete cursos.* |
| Información | Explica una regla antes del choque | *Solo puede haber un período activo a la vez.* |


### 8.2 Las Reglas de Redacción

**Tabla 10.** *Cómo se escribe un mensaje del sistema*

| Así no | Así sí | Por qué |
|---|---|---|
| Error RN-05 | El curso no tiene cupos disponibles | El usuario no conoce el catálogo de reglas |
| Operación inválida | El estudiante ya está matriculado en este curso | Decir qué falló, no que algo falló |
| Usted ingresó mal el dato | La nota debe estar entre 0.0 y 5.0 | El mensaje describe la regla, no culpa a nadie |
| No se pudo completar | No se guardó ninguna nota. Corrija la de Isabella y reintente | Siempre hay un siguiente paso |

*Nota.* La confirmación también dice el efecto concreto, no solo que funcionó. *"Matrícula
registrada"* es menos útil que *"Matrícula registrada. El curso pasa de 20 a 21 cupos ocupados"*,
porque la segunda permite notar un error de inmediato.


### 8.3 Los Mensajes de la Matrícula

Los cinco rechazos posibles de la operación más densa del sistema, uno por regla:

| Regla | Mensaje |
|---|---|
| RN-07 | *No hay un período académico activo. Active el período 2027-1 antes de registrar matrículas.* |
| RN-06 | *El estudiante no está activo. Reactive su registro antes de matricularlo.* |
| RN-04 | *El estudiante ya está matriculado en este curso, desde el 22 de julio.* |
| RN-05 | *El curso no tiene cupos disponibles. Tiene 4 de 4 lugares ocupados.* |
| RN-14 | *El estudiante alcanzó el tope de siete cursos. Cancele una matrícula antes de agregar otra.* |

### 8.4 Los Mensajes que no Revelan Información

Tres mensajes están redactados a propósito para **no** decir lo que el sistema sabe. No es
descuido: decirlo sería una fuga de información.

| Dónde | Qué dice | Qué esconde y por qué |
|---|---|---|
| Inicio de sesión | *Usuario o contraseña incorrectos* | No dice cuál de los dos falló: revelarlo confirmaría qué correos están registrados |
| Olvidé mi contraseña | *Si existe una cuenta con ese correo, le enviamos un enlace* | Responde igual exista o no la cuenta (RN-29); con una cuenta inactiva tampoco envía nada |
| Enlace de restablecimiento | *El enlace venció o ya se usó* | No distingue entre vencido, usado o cuenta inactivada después de pedirlo |

*Nota.* Es el único lugar del catálogo donde un mensaje menos informativo es el correcto. En todos
los demás, decir menos es un defecto.

**Figura 5.** *Estados de una pantalla con datos*

![Estados de una pantalla con datos](diagramas/08-estados-interfaz.png)

*Nota.* Elaboración propia con PlantUML. Las cinco situaciones que toda pantalla con datos debe
resolver. Omitir el estado vacío o el de sin resultados es el olvido más frecuente, y el que más
desconcierta al usuario.

---


## 9. Flujos Principales

RNF-13 fija la métrica: *"matricular, registrar notas y consultar notas en tres clics o menos"*.
Los tres flujos se verifican sobre el prototipo.

**Figura 6.** *Flujo de pantallas para matricular un estudiante*

![Flujo de pantallas para matricular](diagramas/02-flujo-matricula.png)

*Nota.* Elaboración propia con PlantUML. Si una regla falla, el formulario conserva lo
seleccionado: el usuario no vuelve a empezar.

**Figura 7.** *Flujo de pantallas para registrar calificaciones*

![Flujo de pantallas para registrar calificaciones](diagramas/03-flujo-calificar.png)

*Nota.* Elaboración propia con PlantUML. El rechazo del lote completo es deliberado y se justifica
en la sección 5.4.

**Figura 8.** *Flujo de consulta de notas del estudiante*

![Flujo de consulta de notas del estudiante](diagramas/04-flujo-consulta-estudiante.png)

*Nota.* Elaboración propia con PlantUML. La identidad se toma de la sesión, nunca de la dirección.

**Tabla 11.** *Verificación de RNF-13*

| Tarea | Recorrido | Clics |
|---|---|---|
| Matricular un estudiante | Panel, Matricular, Registrar matrícula | 3 |
| Registrar las notas de un corte | Mis cursos, Registrar notas, Guardar | 3 |
| Consultar mis notas | Mis cursos, Mis notas | 2 |
| Ver la lista de clase | Panel, Listas de clase | 2 |
| Ver la ficha de un estudiante | Panel, Estudiantes, Ver ficha | 3 |

*Nota.* Las cinco tareas más frecuentes cumplen el umbral. El panel de cada rol incluye además
accesos directos a sus tres tareas principales, que es lo que permite llegar en uno.

---


## 10. Accesibilidad y Adaptación


### 10.1 Lo que se Verificó

**Tabla 12.** *Verificación de los requerimientos de interfaz*

| Requerimiento | Métrica | Resultado |
|---|---|---|
| RNF-11 adaptación | Sin desplazamiento horizontal desde 360 px | **Cumple en las 24 pantallas**, verificado midiendo `scrollWidth` contra `clientWidth` |
| RNF-12 contraste | Mínimo 4.5:1 en texto normal | Cumple; el valor más bajo de la paleta es 4.6:1 |
| RNF-12 teclado | Foco visible en todo elemento interactivo | Definido: contorno de 3 px con separación. Comprobado en la maqueta de trabajo |
| RNF-13 interacciones | Tres o menos para las tareas frecuentes | Cumple; verificado en la Tabla 11 |
| RNF-10 mensajes | Causa y acción correctiva, sin códigos | Cumple; catálogo completo en la sección 8 |
| RNF-12 movimiento | La animación no puede ser obligatoria | Especificado para la Fase 6: con `prefers-reduced-motion` la interfaz queda quieta y conserva color y jerarquía. Comprobado en la maqueta de trabajo |

*Nota.* Un frame de Figma no se puede medir: no se adapta ni tiene relación de contraste
calculable sobre un fondo real. Para verificar RNF-11 y RNF-12 con números y no con opiniones, las
24 pantallas se construyeron primero como una **maqueta de trabajo en HTML y CSS**, se cargaron en
un marco de 360 píxeles y se comparó el ancho del contenido con el de la ventana: ninguna desbordó.
El contraste se calculó par de colores a par de colores sobre esa misma maqueta. La maqueta es un
instrumento de medición, no un entregable, y no forma parte de la entrega: lo que queda registrado
aquí es el resultado. Repetir la medición exige reconstruirla.


### 10.2 Cómo se Adapta la Tabla

El problema real de una interfaz académica en el teléfono es la tabla: seis columnas no caben en
360 píxeles. Hay tres salidas y escogimos la tercera.

| Opción | Qué pasa | Por qué no |
|---|---|---|
| Desplazamiento horizontal | La tabla se arrastra de lado | Incumple RNF-11 y esconde columnas |
| Ocultar columnas | Se muestran solo dos o tres | El usuario pierde información sin saberlo |
| **Apilar en fichas** | **Cada fila se vuelve una ficha con sus rótulos** | **Elegida: no se pierde nada y se lee** |

En móvil, el encabezado de la tabla se oculta y cada celda muestra su rótulo delante del valor. La
información es la misma; cambia la forma de leerla.

**Figura 9.** *El listado de estudiantes a 360 píxeles*

![El listado de estudiantes a 360 píxeles](capturas/21-listado-movil.png)

*Nota.* Cada fila de la tabla se vuelve una ficha y ninguna columna se pierde: código,
estudiante, documento, correo, estado y acciones siguen estando, cada una con su rótulo delante.
El menú lateral pasa arriba y el contenido ocupa el ancho completo.


### 10.3 Decisiones de Accesibilidad

La accesibilidad se decide en dos momentos distintos y conviene separarlos, porque se verifican de
formas distintas.

**Lo que ya está resuelto en el diseño.** Se ve en el prototipo y se puede revisar ahí mismo:

- **El color nunca comunica solo**: todo estado lleva además texto. Las barras de ocupación
  acompañan a un porcentaje escrito; si se quitan, no se pierde ningún dato.
- **Contraste suficiente en toda la paleta**, con 4.6:1 como valor más bajo (Tabla 3).
- **Rótulo visible en todo control**, siempre encima del campo y nunca dentro como texto de ejemplo,
  que desaparece al escribir.
- **Orden de lectura explícito** en cada pantalla, que es el que debe seguir el tabulador.

**Lo que queda especificado para la Fase 6.** Son decisiones tomadas, pero que solo existen cuando
haya código; el equipo de desarrollo no tiene que volver a discutirlas:

- **Indicador de foco propio**, contorno de 3 píxeles con separación, en lugar del que el navegador
  ponga por defecto.
- **Enlace de salto al contenido**, primera parada del tabulador en cada pantalla.
- **Marcado semántico**: `header`, `nav`, `main`, `footer`, y `table` con `thead` y `scope`. Un
  lector de pantalla recorre la estructura sin adivinar.
- **`aria-current="page"`** en la opción activa del menú.
- **Rótulos asociados** a su control con `for` e `id`, nunca texto suelto al lado.
- **El movimiento se puede apagar**: con `prefers-reduced-motion: reduce`, las entradas, los
  desplazamientos al apuntar y las manchas de color del fondo se detienen. La interfaz queda
  idéntica en color, tamaño y jerarquía; solo deja de moverse.

Las seis de la segunda lista se probaron en la maqueta de trabajo de la sección 10.1, de modo que
pasan a la Fase 6 comprobadas y no como buenas intenciones.

---


## 11. El Prototipo Navegable


### 11.1 Qué Contiene y Cómo se Recorre

El prototipo es un archivo de Figma con las 24 pantallas de la Tabla 2 y las conexiones que las
unen.

**Tabla 13.** *Contenido del archivo de Figma*

| Elemento | Cantidad |
|---|---|
| Pantallas por versión, cada una un frame con auto layout | 24 |
| Versiones: escritorio 1440 × 1024 y móvil 360 × 800 | 2 |
| Conexiones entre pantallas, escritorio | 142 |
| Conexiones entre pantallas, móvil | 96 |
| Estilos de color y de texto | 23 |
| Variables de color y espaciado | 25 |
| Hoja con los componentes del sistema de diseño | 1 |

El prototipo se entrega en **dos tamaños de ventana**, con las mismas 24 pantallas en cada uno:

| Versión | Tamaño del frame | Por qué ese tamaño |
|---|---|---|
| Escritorio | 1440 × 1024 px | Resolución de trabajo de la secretaría académica |
| Móvil | 360 × 800 px | Es el ancho mínimo que exige RNF-11, no uno cómodo |

El tamaño no es un detalle cosmético: fija el ancho real de trabajo y obliga a decidir qué entra
en la primera pantalla y qué queda debajo. Cuando el contenido es más alto que la ventana —el
panel del administrador, la lista de clase, el catálogo de mensajes— la pantalla se desplaza
verticalmente al presentarla, igual que en un navegador, en lugar de recortarse.

La versión móvil no es la de escritorio encogida. Aplica las mismas tres reglas de adaptación de
la sección 10.2: el menú lateral pasa arriba, las rejillas de indicadores y accesos directos
quedan en una sola columna, y cada tabla se convierte en una lista de fichas donde cada celda
lleva delante el rótulo que en escritorio va en la cabecera. Ninguna columna se pierde.

Dos decisiones de construcción sostienen todo lo demás. La primera es el **auto layout**: ninguna
pantalla es un montón de cajas sueltas, sino contenedores que crecen con su contenido. Por eso una
tabla con dos filas y otra con ocho se ven bien sin ajustar nada a mano, y por eso el prototipo
soporta cambiar un texto sin que se descuadre la pantalla entera. La segunda son los **estilos y
las variables**: los colores y los espaciados de la sección 3 no están escritos pantalla por
pantalla, sino declarados una vez. Cambiar el azul institucional cambia las 24 pantallas a la vez,
que es justamente lo que a mano se olvida.

**Para recorrerlo**, sin necesidad de cuenta ni de iniciar sesión. Cada enlace abre su versión en
modo presentación y arranca en la pantalla de acceso, fijada como punto de partida del flujo:

Escritorio, 1440 × 1024:

```text
https://www.figma.com/proto/0N23jzSCsiWpoBvI59fkup/SGA---Prototipo-Fase-5---Grupo-6?node-id=52-4743&starting-point-node-id=52%3A4743&scaling=contain&content-scaling=fixed
```

Móvil, 360 × 800:

```text
https://www.figma.com/proto/0N23jzSCsiWpoBvI59fkup/SGA---Prototipo-Fase-5---Grupo-6?node-id=54-7377&starting-point-node-id=54%3A7377&scaling=contain&content-scaling=fixed
``` Desde ahí se entra a cualquiera de los tres roles y cada pantalla lleva
a las demás. Las conexiones usan *Smart Animate* con salida suave y 300 ms: como las pantallas
comparten la barra superior y el menú con el mismo nombre y la misma posición, Figma los reconoce
entre pantallas y los interpola en lugar de cortar en seco.


### 11.2 Las Pantallas

Las 24 pantallas, en el orden en que se recorren y agrupadas por el rol que las usa. Cada captura
sale del prototipo con los datos del juego de prueba de la Fase 4.


#### 11.2.1 Acceso y contraseña

Seis pantallas que nadie ve más de una vez al día, y que por eso tienen que explicarse solas.

**Figura 10.** *Acceso*

![Acceso](capturas/01-acceso.png)

*Nota.* El único camino de entrada. El enlace de restablecimiento abre el flujo de autoservicio de HU-32, que no pasa por la secretaría.

**Figura 11.** *Cambio obligatorio de contraseña*

![Cambio obligatorio de contraseña](capturas/02-cambio-clave.png)

*Nota.* Primer ingreso con contraseña temporal. RN-22 impide seguir usando el sistema hasta cambiarla.

**Figura 12.** *Olvidé mi contraseña*

![Olvidé mi contraseña](capturas/02b-recuperar.png)

*Nota.* Pide solo el correo. No confirma ni desmiente que la cuenta exista, que es lo que exige RN-29.

**Figura 13.** *Confirmación del envío*

![Confirmación del envío](capturas/02c-recuperar-enviado.png)

*Nota.* El mismo mensaje se muestre o no la cuenta. Es la mitad visible de RN-29: la respuesta no revela quién está registrado.

**Figura 14.** *Contraseña nueva desde el enlace*

![Contraseña nueva desde el enlace](capturas/02d-recuperar-nueva.png)

*Nota.* Se llega aquí solo con un enlace válido. Al guardar, RN-31 invalida los demás enlaces del mismo usuario.

**Figura 15.** *Enlace no válido*

![Enlace no válido](capturas/02e-recuperar-invalido.png)

*Nota.* Vencido o ya usado. El mensaje no dice cuál de los dos, y ofrece pedir uno nuevo.


#### 11.2.2 Administración académica

Once pantallas. Es el rol con más trabajo: registra personas, arma la oferta y matricula.

**Figura 16.** *Panel del administrador académico*

![Panel del administrador académico](capturas/03-panel-admin.png)

*Nota.* Los indicadores y la tabla de ocupación salen del juego de prueba de la Fase 4: 11 estudiantes activos, 23 matrículas sobre 109 cupos. Los dos avisos ámbar no son decorativos, son los dos problemas reales de ese juego de datos: MAT-101 lleno y SOC-101 sin docente.

**Figura 17.** *Listado de estudiantes*

![Listado de estudiantes](capturas/04-estudiantes.png)

*Nota.* Filtros, paginación y el mensaje de éxito del registro anterior. Ningún listado muestra la contraseña ni el documento completo de quien no corresponde.

**Figura 18.** *Formulario de estudiante*

![Formulario de estudiante](capturas/05-estudiante-form.png)

*Nota.* Alta y edición comparten pantalla. El correo debe ser único, que es RN-02.

**Figura 19.** *Ficha del estudiante*

![Ficha del estudiante](capturas/06-estudiante-detalle.png)

*Nota.* Reúne datos personales, matrículas del periodo y promedio. Desde aquí se inactiva, nunca se borra: es la aplicación de ADR-004.

**Figura 20.** *Listado de docentes*

![Listado de docentes](capturas/07-docentes.png)

*Nota.* Muestra cuántos cursos tiene asignado cada docente, que es lo que hace falta para repartir carga.

**Figura 21.** *Cuentas y roles*

![Cuentas y roles](capturas/08-usuarios.png)

*Nota.* Una cuenta por persona y un rol por cuenta (RN-23). La columna de último acceso ayuda a detectar cuentas abandonadas.

**Figura 22.** *Períodos académicos*

![Períodos académicos](capturas/09-periodos.png)

*Nota.* Solo un periodo puede estar activo a la vez (RN-03). Cerrar uno es la acción que habilita abrir el siguiente.

**Figura 23.** *Oferta académica*

![Oferta académica](capturas/10-cursos.png)

*Nota.* Cupo, matriculados y docente por curso. Es la pantalla que responde la pregunta que dispara el aviso del panel.

**Figura 24.** *Formulario de curso*

![Formulario de curso](capturas/11-curso-form.png)

*Nota.* Curso, docente titular y los cortes con su peso. La suma de los pesos debe dar 100 %, que es RN-10.

**Figura 25.** *Matricular estudiante*

![Matricular estudiante](capturas/12-matricular.png)

*Nota.* La pantalla muestra las cinco reglas que el sistema revisa antes de escribir nada, con su resultado para la selección actual, y debajo los cinco mensajes posibles de rechazo. El cupo disponible se ve antes de confirmar, de modo que RN-05 está en la interfaz y no solo en el error.

**Figura 26.** *Lista de clase*

![Lista de clase](capturas/13-lista-clase.png)

*Nota.* Quién está matriculado en un curso. La comparten el administrador y el docente, con el mismo contenido y distinto menú.


#### 11.2.3 Docente

**Figura 27.** *Mis cursos del docente*

![Mis cursos del docente](capturas/14-panel-docente.png)

*Nota.* Solo los cursos donde es titular. Lo que no le corresponde no aparece: es ADR-003 en pantalla.

**Figura 28.** *Registrar calificaciones*

![Registrar calificaciones](capturas/15-calificar.png)

*Nota.* El lote se guarda completo o no se guarda. El error se marca en la fila concreta, no en un aviso general al principio del formulario.


#### 11.2.4 Estudiante

**Figura 29.** *Mis cursos del estudiante*

![Mis cursos del estudiante](capturas/16-panel-estudiante.png)

*Nota.* Sus matrículas del periodo activo y el estado de cada una.

**Figura 30.** *Mis notas*

![Mis notas](capturas/17-mis-notas.png)

*Nota.* La columna de aporte hace visible el cálculo de RN-11: responde de dónde salió la definitiva sin que el estudiante tenga que preguntarlo en la ventanilla. *Pendiente* nunca se dibuja como 0.0.


#### 11.2.5 Mi cuenta

Dos pantallas comunes a los tres roles. El menú de cada rol las incluye bajo el grupo *Mi cuenta*;
el prototipo muestra la instancia del estudiante.

**Figura 31.** *Mi perfil*

![Mi perfil](capturas/19-perfil.png)

*Nota.* La identidad se muestra pero no se edita, y la pantalla dice por qué: el documento identifica a la persona (RN-01) y el correo es la credencial de acceso (RN-02). Lo único editable es el teléfono (RN-32). El mensaje azul no es decorativo: evita que el usuario busque dónde cambiar su nombre y termine escribiendo a soporte.

**Figura 32.** *Cambiar contraseña*

![Cambiar contraseña](capturas/20-cambiar-contrasena.png)

*Nota.* Es HU-05 desde una sesión abierta, distinta del restablecimiento por correo de HU-32. Pide la contraseña actual (RN-33) y avisa de la consecuencia antes de guardar: se cierran las demás sesiones y caducan los enlaces pendientes (RN-31). Debajo, los dos mensajes que el sistema puede responder.


#### 11.2.6 Referencia de diseño

**Figura 33.** *Catálogo de mensajes*

![Catálogo de mensajes](capturas/18-catalogo-mensajes.png)

*Nota.* No es una pantalla del sistema, es la referencia de diseño: reúne los 25 mensajes con su redacción definitiva. La captura muestra el comienzo; la pantalla continúa con el resto.

### 11.3 Qué es Real y Qué está Simulado

Conviene ser explícito para que nadie espere lo que no hay.

**Tabla 14.** *Alcance del prototipo*

| Es real | Está simulado |
|---|---|
| Toda la navegación entre las 24 pantallas | Los datos: son fijos, del juego de prueba de la Fase 4 |
| La estructura y el contenido de cada pantalla | El guardado: los formularios navegan, no persisten |
| El sistema de diseño completo | La autenticación: cualquier botón entra |
| El contraste de la paleta | El cálculo: los resultados están escritos, no se computan |
| Los mensajes, con su redacción definitiva | La autorización: el prototipo deja cambiar de rol a voluntad |
| | La adaptación automática: cada frame tiene un tamaño fijo. Hay dos versiones, pero una no se transforma en la otra al cambiar el ancho |

*Nota.* Dos filas piden explicación. La autorización se deja abierta a propósito, para poder
revisar el prototipo completo con los tres roles; en el sistema real ese salto es exactamente lo
que RN-23 impide. Y la adaptación no se puede mostrar en Figma: un frame mide lo que se le dibujó.
El diseño adaptable está definido —la Figura 9 muestra cómo se ve a 360 píxeles— y medido en la
sección 10.1, pero sobre la maqueta de trabajo, no sobre este archivo.


### 11.4 Qué se Lleva la Fase 6

El prototipo no es un dibujo que se descarta. Lo que pasa a la Fase 6 son tres cosas concretas:

- **Los tokens del sistema de diseño**, que en el archivo de Figma son variables y estilos, y en la
  aplicación serán las variables de la hoja de estilo.
- **La estructura de cada pantalla**: cada frame dice qué bloques tiene la vista y en qué orden.
- **La redacción definitiva de los mensajes**, que ya no hay que inventar en el sprint.

Lo que cambia es de dónde vienen los datos: hoy están escritos; mañana los devuelve la base de
datos de la Fase 4.

---


## 12. Trazabilidad

**Tabla 15.** *De la historia de usuario a la pantalla y a la tabla*

| Historia | Pantalla | Caso de uso | Tabla de la Fase 4 |
|---|---|---|---|
| HU-01 Iniciar sesión | Acceso | CU-01 | `usuario`, `evento_seguridad` |
| HU-03 Administrar usuarios | Cuentas y roles | CU-02 | `usuario` |
| HU-04 Restringir por rol | Todas, vía el menú de cada rol | CU-23 | `usuario.rol` |
| HU-05 Cambiar contraseña | Cambio de contraseña | CU-03 | `usuario` |
| HU-32 Restablecer contraseña olvidada | Las 4 pantallas de recuperación | CU-28 | `solicitud_restablecimiento`, `usuario` |
| HU-06 Registrar estudiante | Formulario de estudiante | CU-04 | `persona`, `estudiante` |
| HU-07 Consultar estudiantes | Listado y ficha | CU-05 | `vw_estudiante` |
| HU-08 Actualizar estudiante | Formulario de estudiante | CU-06 | `persona`, `estudiante` |
| HU-09 Inactivar estudiante | Ficha del estudiante | CU-07 | `persona.estado` |
| HU-11 Registrar docentes | Listado de docentes | CU-08 | `persona`, `docente` |
| HU-12 Asignar docente | Formulario de curso | CU-12 | `curso.id_docente` |
| HU-13 Administrar períodos | Períodos académicos | CU-10 | `periodo_academico` |
| HU-14 Administrar cursos | Oferta y formulario de curso | CU-11 | `curso` |
| HU-15 Matricular | Matricular estudiante | CU-14, CU-24 | `matricula`, `curso` |
| HU-16 Cancelar matrícula | Lista de clase | CU-15 | `matricula` |
| HU-17 Configurar cortes | Formulario de curso | CU-13 | `corte` |
| HU-18 Registrar calificaciones | Registrar calificaciones | CU-17 | `calificacion` |
| HU-19 Modificar calificación | Registrar calificaciones | CU-18 | `calificacion`, `registro_auditoria` |
| HU-21 Calcular definitiva | Mis notas, columna de aporte | CU-19 | `vw_nota_definitiva` |
| HU-22 Lista de clase | Lista de clase | CU-16 | `vw_lista_clase` |
| HU-23 Mis cursos | Mis cursos del estudiante | CU-20 | `vw_nota_definitiva` |
| HU-24 Mis notas | Mis notas | CU-21 | `vw_notas_estudiante` |
| HU-25 Mi promedio | Mis cursos del estudiante | CU-22, CU-27 | `vw_promedio_estudiante` |

*Nota.* HU-02 (cerrar sesión) es la acción de la barra superior y no tiene pantalla propia. Las 24
historias del MVP quedan representadas.


### 12.1 Verificación de Consistencia

**Tabla 16.** *Verificación del modelo de interfaz*

| Condición verificada | Resultado | Detalle |
|---|---|---|
| Toda historia del MVP tiene pantalla o acción | Cumple | 23 de 23 |
| Toda pantalla corresponde a un caso de uso | Cumple | 21 de 21, más el catálogo de referencia |
| Todo enlace del prototipo resuelve | Cumple | 0 enlaces rotos sobre 22 páginas |
| Toda pantalla es alcanzable desde otra | Cumple | 0 páginas huérfanas |
| Toda pantalla cabe en 360 px sin desbordar | Cumple | 22 de 22 |
| Toda regla con rechazo visible tiene su mensaje | Cumple | Las 5 de la matrícula, más 9 del catálogo |

*Nota.* Las dos primeras se revisaron manualmente; las tres siguientes se verificaron con
herramientas, recorriendo los enlaces y midiendo el ancho de cada página.

---


## 13. Plan de Validación con Usuarios

RNF-09 fija una métrica que todavía no se puede medir: *"el 80 % de los docentes de prueba
completa el registro de notas en menos de diez minutos, sin capacitación previa"*. El prototipo es
justamente lo que permite medirla antes de programar.

**Tabla 17.** *Prueba de usabilidad propuesta*

| Elemento | Definición |
|---|---|
| Participantes | 5 docentes y 5 estudiantes de la institución, sin capacitación previa |
| Duración | 20 minutos por participante |
| Tarea 1 (docente) | Registrar las notas del corte 2 de Matemáticas I |
| Tarea 2 (docente) | Corregir una nota ya registrada |
| Tarea 3 (estudiante) | Averiguar por qué su definitiva de Lengua Castellana II aún no aparece |
| Qué se mide | Tiempo, si la completa sin ayuda, dónde duda y qué dice en voz alta |
| Umbral de éxito | 80 % completa la tarea 1 en menos de diez minutos |

*Nota.* Cinco participantes por perfil bastan: a partir del quinto, los hallazgos se repiten
(Nielsen y Landauer, 1993). La tarea 3 no es de uso sino de comprensión, y es la que verifica si la
distinción entre *Pendiente* y 0.0 se entiende sin explicación.

---


## 14. Decisiones de Diseño de Interfaz

**Tabla 18.** *Decisiones de diseño y sus consecuencias*

| Decisión | Por qué | Qué nos cuesta |
|---|---|---|
| El prototipo se arma con auto layout, estilos y variables, no con cajas sueltas | Cambiar un token o un componente cambia las 24 pantallas a la vez y nada se descuadra al editar un texto | Montar el sistema de diseño antes que las pantallas retrasa las primeras |
| La accesibilidad se mide en una maqueta HTML aparte | RNF-11 y RNF-12 se verifican con una medición, no con una opinión | Esa maqueta no se entrega: la medición consta en el informe, pero no se puede repetir desde el repositorio |
| Un menú por rol, sin opciones deshabilitadas | Lo que no le corresponde a un rol no existe en su interfaz | Tres menús que mantener en lugar de uno |
| Los datos del prototipo son los de la Fase 4 | Lo que se ve en pantalla es lo que devuelve la base de datos | Hay que actualizarlos si cambia el juego de prueba |
| La tabla se apila en móvil en vez de desplazarse | No se pierde ninguna columna y no hay desplazamiento horizontal | Cada celda necesita llevar su rótulo, que en escritorio va en el encabezado |
| El lote de notas se rechaza completo | Un guardado parcial deja al docente sin saber qué alcanzó a registrar | Más fricción cuando hay un solo error |
| La definitiva muestra el aporte de cada corte | Responde la pregunta más frecuente en la ventanilla | Una columna más en una pantalla ya densa |
| *Pendiente* nunca se dibuja como 0.0 | Es la distinción que la Fase 3 declaró crítica | Obliga a un estilo propio y a explicarlo en la interfaz |
| Una sola familia tipográfica, la del sistema | Carga instantánea y sin dependencias externas (RE-03) | Menos personalidad visual que una tipografía propia |
| Catálogo de mensajes como pantalla del prototipo | El Anexo A pendiente desde la Fase 2 queda escrito y visible | Una pantalla que no existirá en el sistema real |

---


## 15. Conclusiones

Las 25 historias del producto mínimo viable se convirtieron en 24 pantallas, un sistema de diseño
de 16 componentes y un prototipo navegable en Figma que se recorre completo con los tres roles.
Los requerimientos de interfaz quedaron verificados: ninguna de las 24 pantallas desborda a 360
píxeles, la paleta completa supera el contraste exigido y las cinco tareas más frecuentes se
alcanzan en tres interacciones o menos.

El diseño obligó a precisar tres cosas que las fases anteriores dejaban abiertas.

La primera fue el **Anexo A**. La Fase 2 escribió la métrica de RNF-10 contra un catálogo de
mensajes que nunca existió. Escribirlo ahora no fue un trámite: obligó a decidir, mensaje por
mensaje, qué le decimos a alguien cuando el sistema le dice que no. La regla que resultó es que un
mensaje sin siguiente paso está incompleto.

La segunda fue **cómo se ve una nota pendiente**. La Fase 3 identificó la distinción y la Fase 4 la
resolvió no almacenando la fila. Pero faltaba la mitad visible: en pantalla, *Pendiente* aparece en
cursiva y en gris, con una leyenda que explica la diferencia. Un sistema puede tener el modelo
correcto y aun así comunicar mal.

La tercera fue **qué pasa cuando no hay datos**. Ninguna fase anterior lo había planteado, porque
los diagramas suelen dibujar el caso en que todo existe. Distinguir el listado que todavía no tiene
registros del que no encontró coincidencias evita que alguien crea que perdió información.

Queda una limitación consciente. El prototipo permite saltar entre los tres roles con un clic, que
es exactamente lo que el sistema real debe impedir. Es una concesión para poder revisarlo completo,
y está declarada en la sección 11.2 para que nadie la confunda con el comportamiento esperado.

---


## 16. Referencias

- Cooper, A., Reimann, R., Cronin, D., & Noessel, C. (2014). *About face: The essentials of interaction design* (4th ed.). Wiley.
- Johnson, J. (2020). *Designing with the mind in mind: Simple guide to understanding user interface design guidelines* (3rd ed.). Morgan Kaufmann.
- Krug, S. (2014). *Don't make me think, revisited: A common sense approach to web usability* (3rd ed.). New Riders.
- Nielsen, J. (1994). *Usability engineering*. Morgan Kaufmann.
- Nielsen, J., & Landauer, T. K. (1993). A mathematical model of the finding of usability problems. *Proceedings of the INTERCHI 93 Conference on Human Factors in Computing Systems*, 206-213.
- Norman, D. (2013). *The design of everyday things: Revised and expanded edition*. Basic Books.
- Snyder, C. (2003). *Paper prototyping: The fast and easy way to design and refine user interfaces*. Morgan Kaufmann.
- World Wide Web Consortium. (2018). *Web Content Accessibility Guidelines (WCAG) 2.1*. https://www.w3.org/TR/WCAG21/
- World Wide Web Consortium. (2023). *ARIA Authoring Practices Guide*. https://www.w3.org/WAI/ARIA/apg/

---

**Resumen del entregable:** 24 pantallas · 16 componentes · 8 diagramas · 25 capturas ·
18 tablas · catálogo de 25 mensajes · prototipo de Figma en escritorio y móvil ·
0 desbordes a 360 px · 25 historias del MVP trazadas.
