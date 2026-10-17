# ADR-011: Prototipo navegable en Figma, con medición aparte en el navegador

- **Estado:** Aceptada
- **Fecha:** 2026-10-15
- **Decidido por:** Jannier Johan Otavo
- **Relacionado con:** ADR-001, ADR-006, RE-03, RE-06, RNF-11, RNF-12, Fase 5, Fase 6

## Contexto

La Fase 5 pide un prototipo navegable y la institución lo exige **en Figma**. La herramienta queda
fijada, pero quedan abiertas dos preguntas que sí hay que decidir.

La primera es cómo se arma el archivo. Son 22 pantallas que comparten barra superior, menú lateral,
tablas, formularios y mensajes. Armarlas como dibujos independientes —cada pantalla con sus propias
cajas y sus propios colores escritos a mano— funciona para las tres primeras y se desmorona en la
décima: cambiar el azul institucional o el alto de una fila obliga a repasar las 22, y lo que se
olvida no avisa.

La segunda es más incómoda. Dos requerimientos de interfaz **no se pueden verificar en Figma**:
RNF-11 exige que no haya desplazamiento horizontal desde 360 píxeles y RNF-12 fija una relación de
contraste mínima. Un frame tiene el ancho que uno le dibujó, no se adapta, y su contraste no se
calcula contra un fondo real. Eso no se arregla eligiendo mejor la herramienta de diseño: un
archivo de diseño se mira, no se mide.

## Decisión

Construir el prototipo en Figma sobre tres mecanismos de la propia herramienta, y no como dibujos
sueltos: **auto layout** en cada frame, **estilos** de color y texto, y **variables** para la
paleta y la escala de espaciado. Los componentes del sistema de diseño se definen una vez y se
reutilizan en las 22 pantallas.

Para verificar RNF-11 y RNF-12, construir aparte una **maqueta de trabajo en HTML y CSS** con las
mismas pantallas, usarla como instrumento de medición y **no incluirla en la entrega**.

## Consecuencias

Se vuelve más fácil:

- **Mantener la coherencia.** El sistema de diseño vive en estilos y variables, no repetido pantalla
  por pantalla. Cambiar un token cambia las 22 a la vez.
- **Editar sin romper.** Con auto layout, alargar un nombre de curso o añadir una fila a una tabla
  reacomoda el contenedor en lugar de descuadrar la pantalla.
- **Presentar.** El botón Presentar recorre el prototipo con las 142 conexiones y sus transiciones,
  que es exactamente lo que la institución va a revisar.
- **Verificar la accesibilidad con un número.** La medición en el navegador da un valor, no una
  impresión.

Se vuelve más difícil:

- **Arrancar.** Montar componentes, estilos y variables antes de la primera pantalla cuesta más que
  dibujarla directamente. Se recupera a partir de la tercera.
- **Revisar los cambios.** Un archivo de Figma no tiene diff: para saber qué cambió entre dos
  versiones hay que mirarlas. Es el precio de la herramienta exigida, y contrasta con ADR-006, que
  justamente eligió texto para los diagramas por esta razón.
- **Perder el instrumento de medición.** La maqueta HTML no se versiona, de modo que el resultado
  de RNF-11 y RNF-12 queda registrado en el informe pero **no se puede repetir desde el
  repositorio**. Quien quiera volver a medir tiene que reconstruirla. Es el costo aceptado de
  entregar un único prototipo, el que pide la institución, y no dos.

## Alternativas consideradas

**Dibujar cada pantalla como cajas sueltas, sin componentes ni estilos.** Descartada por lo dicho en
el contexto: es más rápido al principio y se vuelve impagable a la décima pantalla, porque cada
cambio del sistema de diseño hay que repetirlo 22 veces a mano.

**Entregar el prototipo en HTML y CSS versionados.** Tiene ventajas reales —se abre con doble clic,
se mide y pasa a la Fase 6 tal cual—, pero no cumple el requisito: la institución pide Figma. Se
conserva su mejor parte, la medición, en forma de maqueta de trabajo.

**Entregar los dos, HTML y Figma.** Descartada porque obliga a mantener la misma interfaz escrita
dos veces. Al primer cambio que entre en uno y no en el otro, el prototipo deja de ser la fuente de
verdad y pasa a ser dos versiones que se contradicen.

**Mapa de pantallas en PlantUML.** Descartada como entregable principal porque la rúbrica pide un
prototipo **navegable**, y un diagrama no se recorre. Se conserva como complemento: los bocetos de
las figuras 3 y 4 de la Fase 5 están hechos así, y fijan la estructura antes de dibujar nada.
