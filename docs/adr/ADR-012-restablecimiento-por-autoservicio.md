# ADR-012: Restablecimiento de contraseña por autoservicio con enlace por correo

- **Estado:** Aceptada
- **Fecha:** 2026-10-15
- **Decidido por:** Jannier Johan Otavo
- **Relacionado con:** ADR-007, HU-32, RF-58 a RF-60, RN-28 a RN-31, RE-11

## Contexto

Hasta ahora, quien olvidaba su contrasena tenia un solo camino: pedirle a la secretaria academica
que la restableciera. Esa decision venia de la Fase 1, donde HU-32 quedo clasificada como
*Won't have* por su relacion valor/esfuerzo: 2 de valor sobre 5, 8 puntos de esfuerzo.

La clasificacion estaba mal calibrada. Un restablecimiento que depende de que alguien este en la
ventanilla no es un restablecimiento: es un tramite con horario. Un estudiante que olvida su
contrasena un domingo pierde el acceso hasta el lunes, y la secretaria absorbe una carga que no
aporta nada al registro academico.

[ADR-007](ADR-007-almacenamiento-de-contrasenas.md) ya habia establecido lo que se puede y no se
puede hacer: como solo se guarda el resumen criptografico, la contrasena **no se puede recuperar**,
unicamente **restablecer**. Lo que cambia aqui no es eso, sino quien puede iniciar el
restablecimiento.

## Decision

Permitir que el propio usuario restablezca su contrasena mediante un enlace enviado a su correo
institucional, con cuatro salvaguardas:

1. **La respuesta no revela si la cuenta existe.** La pantalla responde siempre lo mismo, haya o no
   una cuenta con ese correo (RN-29). Confirmarlo convertiria el formulario en un detector de
   correos registrados.
2. **El enlace sirve una sola vez y vence a los 30 minutos** (RN-28).
3. **Del enlace se guarda su resumen criptografico, nunca el identificador en claro.** Es el mismo
   razonamiento de ADR-007 aplicado a otra credencial: un enlace almacenado tal cual es una llave
   activa para quien lea la tabla.
4. **Maximo tres solicitudes por hora y por cuenta** (RN-30). Al usar un enlace se invalidan los
   demas y se cierran las sesiones abiertas de esa cuenta (RN-31).

El restablecimiento desde la pantalla de cuentas se conserva como camino de excepcion, para quien
no tiene acceso a su correo institucional.

## Consecuencias

Se vuelve mas facil: recuperar el acceso fuera del horario de la secretaria; descargar a la
secretaria de una tarea que no aporta al registro academico; y cumplir HU-32 con una metrica
observable, porque el flujo completo se puede probar.

Se vuelve mas dificil: el sistema pasa a depender de un servidor de correo saliente, lo que anade
la restriccion RE-11 y un punto de fallo que antes no existia; el MVP crece de 126 a 134 puntos; y
aparece una superficie de ataque nueva que obliga a las cuatro salvaguardas anteriores. Si el
correo no llega, el usuario queda igual que antes, y por eso el camino por secretaria se conserva.

## Alternativas consideradas

**Dejarlo como estaba, con la secretaria como unico camino.** Descartada: es la situacion que
motivo este ADR.

**Preguntas de seguridad.** Descartada. Las respuestas suelen ser datos publicos o averiguables, y
en una institucion educativa, donde muchos estudiantes se conocen entre si, son especialmente
debiles.

**Enviar una contrasena temporal por correo en vez de un enlace.** Descartada porque deja una
credencial valida escrita en un buzon de forma indefinida. El enlace vence a los 30 minutos y
muere al usarse.

**Codigo de un solo uso por mensaje de texto.** Descartada por RE-03 y RE-11: exigiria contratar un
servicio de mensajeria, mientras que el correo institucional ya existe.
