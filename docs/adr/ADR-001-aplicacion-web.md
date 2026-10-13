# ADR-001: Aplicación web adaptable en lugar de aplicación móvil nativa

- **Estado:** Aceptada
- **Fecha:** 2026-08-20
- **Decidido por:** Jannier Johan Otavo
- **Relacionado con:** RE-01, RNF-08, RNF-11, RNF-13

## Contexto

El sistema tiene tres tipos de usuario con condiciones de acceso muy distintas. La coordinación
académica y la secretaría trabajan desde equipos de escritorio durante toda la jornada. Los docentes
usan los equipos de la sala de profesores en momentos puntuales del período. Los estudiantes
consultan sus notas casi siempre desde el celular.

El desarrollo lo hace una sola persona en cuatro sprints para construir el producto mínimo viable. La
institución no cuenta con presupuesto para publicar y mantener una aplicación en las tiendas de
aplicaciones.

## Decisión

Construir una única aplicación web adaptable, accesible desde los navegadores vigentes tanto en
escritorio como en dispositivos móviles.

## Consecuencias

Se vuelve más fácil: mantener una sola base de código para los tres perfiles; desplegar
correcciones sin depender de la aprobación de una tienda; y cubrir con un solo desarrollo el uso de
escritorio de la secretaría y el uso móvil del estudiante.

Se vuelve más difícil: la experiencia en el celular no será tan fluida como la de una aplicación
nativa; no podremos usar notificaciones automáticas del sistema operativo, lo que refuerza la
decisión de dejar las notificaciones fuera del alcance (HU-31); y dependeremos de que haya conexión
a internet en el momento de uso, sin funcionamiento fuera de línea.

Para acotar el riesgo de usabilidad móvil fijamos RNF-11, que obliga a que la interfaz opere sin
desplazamiento horizontal desde 360 píxeles de ancho.

## Alternativas consideradas

**Aplicación móvil nativa para estudiantes más aplicación web para el personal.** Descartada porque
duplica el esfuerzo de construcción y de mantenimiento, y con una sola persona de desarrollo no lo
sostiene en cuatro sprints.

**Aplicación de escritorio instalable.** Descartada porque obligaría a instalar y actualizar el
programa en cada equipo de la institución, y dejaría por fuera el acceso del estudiante desde el
celular, que es justamente el que descongestiona la ventanilla.
