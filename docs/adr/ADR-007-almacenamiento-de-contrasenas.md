# ADR-007: Contraseñas con función de resumen y sal, y canal cifrado

- **Estado:** Aceptada
- **Fecha:** 2026-08-20
- **Decidido por:** Jannier Johan Otavo, Sergio David Vargas
- **Relacionado con:** RNF-17, RNF-22, RN-21, RF-01, RF-04, RF-08

## Contexto

El sistema custodiará datos personales de estudiantes, buena parte de ellos menores de edad, lo que
nos sitúa bajo la restricción normativa RE-09. Las cuentas se crean con una contraseña temporal que
asigna el administrador (RF-04), de modo que muchas personas empezarán con una credencial que no
eligieron.

Si las contraseñas se guardaran en texto plano, cualquier acceso a la base de datos —incluido el de
un integrante del equipo durante el desarrollo— expondría las credenciales reales de personas que,
además, probablemente reutilizan esa contraseña en otros servicios.

## Decisión

Almacenar únicamente el resumen criptográfico de la contraseña, calculado con una función diseñada
para ese propósito y con sal única por usuario. Servir toda la aplicación sobre HTTPS y redirigir
cualquier acceso por HTTP.

## Consecuencias

Se vuelve más fácil: cumplir RNF-17 y RNF-22; y responder ante un acceso indebido a la base de
datos, porque las contraseñas no quedan expuestas.

Se vuelve más difícil: no podremos recuperar una contraseña olvidada, solo restablecerla, lo que
mantiene al administrador en el circuito mientras HU-32 siga fuera del alcance; y el despliegue
exige gestionar un certificado, con su vencimiento y su renovación.

## Alternativas consideradas

**Cifrado reversible de la contraseña.** Descartada: permitiría recuperarla, pero cualquiera con la
clave de cifrado obtendría todas las contraseñas en claro.

**Resumen sin sal.** Descartada porque dos usuarios con la misma contraseña producirían el mismo
resumen, lo que facilita los ataques por tablas precalculadas.
