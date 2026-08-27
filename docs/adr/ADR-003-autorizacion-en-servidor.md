# ADR-003: Autorización verificada en el servidor

- **Estado:** Aceptada
- **Fecha:** 2026-08-20
- **Decidido por:** Jannier Johan Otavo, Sergio David Vargas
- **Relacionado con:** RNF-19, RF-07, RF-41, RN-08, RN-23

## Contexto

El dolor D-4 identificado en la Fase 1 es que hoy cualquiera puede editar cualquier archivo de
notas, y que se registra al menos un incidente de calificación alterada por período. El sistema
existe, en buena parte, para impedir eso.

La forma más rápida de construir la interfaz es ocultar las opciones que el rol no debería usar. Es
también la forma más frágil: ocultar un botón no impide que alguien invoque directamente la
dirección de la operación, y el caso de prueba CP-02 verifica exactamente ese intento.

## Decisión

Verificar la autorización en el servidor para cada operación, tomando el rol de la sesión y no de
ningún dato enviado por el cliente. La interfaz oculta lo que el rol no puede usar, pero esa
ocultación es una comodidad visual, nunca el mecanismo de control.

## Consecuencias

Se vuelve más fácil: cumplir RN-08 y RN-23 de manera uniforme; superar CP-02 y CP-10; y auditar,
porque toda denegación pasa por un mismo punto y se registra en la bitácora (RF-09).

Se vuelve más difícil: cada operación nueva obliga a declarar explícitamente qué roles la pueden
ejecutar, lo que añade trabajo en cada historia; y hay que evitar la duplicación de la regla de
permiso entre la interfaz y el servidor, manteniendo una única tabla de permisos como fuente.

## Alternativas consideradas

**Control únicamente en la interfaz.** Descartada por insegura: no resiste la invocación directa de
una dirección, que es un ataque trivial y que además ya está escrito como caso de prueba.

**Control en la capa de datos mediante permisos del motor.** Descartada porque acopla el modelo de
seguridad al motor concreto, en contra de ADR-005 y de RNF-28.
