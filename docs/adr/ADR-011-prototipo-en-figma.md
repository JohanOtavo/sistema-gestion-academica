# ADR-011: Prototipo navegable en Figma, generado por código

- **Estado:** Aceptada
- **Fecha:** 2026-10-15
- **Decidido por:** Jannier Johan Otavo
- **Relacionado con:** ADR-001, ADR-006, RE-03, RE-06, RNF-11, RNF-12, Fase 5, Fase 6

## Contexto

La Fase 5 pide un prototipo navegable y la institución lo exige **en Figma**. Eso fija la
herramienta, pero no fija cómo se construye el archivo, y ahí hay dos caminos muy distintos.

El camino habitual es dibujarlo: arrastrar cajas, duplicar pantallas y conectarlas con flechas a
mano. Son 22 pantallas y 142 conexiones. Un cambio en el sistema de diseño —un color, un tamaño de
texto, el espaciado de una tarjeta— obliga a repasar las 22, y nadie puede revisar después qué
cambió exactamente, porque un archivo de diseño no tiene diff.

Dos hechos del proyecto empujan hacia el otro camino. El primero es ADR-006, que ya decidió
escribir los diagramas en lugar de dibujarlos, por razones que aquí valen igual: diff legible,
resultado repetible y nada que dependa de que alguien recuerde dónde movió una caja. El segundo es
RE-06: desarrolla una sola persona, de modo que el trabajo manual repetido se paga dos veces.

Queda un problema aparte. Dos requerimientos de interfaz no se pueden verificar en Figma: RNF-11
exige que no haya desplazamiento horizontal desde 360 píxeles, y RNF-12 fija una relación de
contraste mínima. Un frame no se adapta y su contraste no se calcula sobre un fondo real. Eso no
se resuelve eligiendo mejor la herramienta de diseño: se resuelve midiendo en un navegador.

## Decisión

Generar el archivo de Figma con un **plugin propio versionado en el repositorio**
(`fase5-mockup/figma-plugin/`), donde las 22 pantallas se declaran como datos y el generador las
construye con auto layout, estilos, variables y las conexiones del prototipo.

Para verificar RNF-11 y RNF-12, construir aparte una **maqueta de trabajo en HTML y CSS** con las
mismas pantallas, usarla como instrumento de medición y **no incluirla en la entrega**.

## Consecuencias

Se vuelve más fácil:

- **Revisar un cambio de interfaz.** Un ajuste aparece como un diff en `code.js`, igual que los
  diagramas de ADR-006.
- **Regenerar.** Volver a ejecutar el plugin rehace las 22 pantallas completas en una página nueva,
  sin tocar lo ya generado y sin pasos manuales que recordar.
- **Mantener la coherencia.** El sistema de diseño está escrito una sola vez: cambiar un token
  cambia las 22 pantallas a la vez, que es justo lo que a mano se olvida.
- **Verificar la accesibilidad con un número.** La medición en el navegador da un valor, no una
  impresión.

Se vuelve más difícil:

- **Arrancar.** Escribir el generador cuesta bastante más que arrastrar las primeras pantallas. Se
  recupera a partir de la tercera, cuando el sistema de diseño ya está hecho.
- **Depender de la API del editor.** El plugin se escribe contra una API que cambia entre
  versiones. Se mitigó probando las formas conocidas del objeto de conexión y conservando la que el
  editor acepta, pero la dependencia existe.
- **Perder el instrumento de medición.** La maqueta HTML no se versiona, de modo que el resultado
  de RNF-11 y RNF-12 queda registrado en el informe pero **no se puede repetir desde el
  repositorio**. Quien quiera volver a medir tiene que reconstruirla. Es el costo aceptado de
  entregar un único prototipo, el que pide la institución, y no dos.

## Alternativas consideradas

**Dibujar el prototipo a mano en Figma.** Descartada por lo dicho en el contexto: 22 pantallas y
142 conexiones movidas a mano no se revisan, no se repiten y se desincronizan en cuanto cambia un
token del sistema de diseño.

**Entregar el prototipo en HTML y CSS versionados.** Era la decisión anterior y tiene ventajas
reales —se abre con doble clic, se mide, y pasa a la Fase 6 tal cual—, pero no cumple el requisito:
la institución pide Figma. Se conserva su mejor parte, la medición, en forma de maqueta de trabajo.

**Entregar los dos, HTML y Figma.** Descartada porque obliga a mantener la misma interfaz escrita
dos veces. Al primer cambio que entre en uno y no en el otro, el prototipo deja de ser la fuente de
verdad y pasa a ser dos versiones que se contradicen.

**Mapa de pantallas en PlantUML.** Descartada como entregable principal porque la rúbrica pide un
prototipo **navegable**, y un diagrama no se recorre. Se conserva como complemento: los bocetos de
las figuras 3 y 4 de la Fase 5 están hechos así, y fijan la estructura antes de generar nada.
