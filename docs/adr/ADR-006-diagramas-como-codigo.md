# ADR-006: Diagramas como código con PlantUML

- **Estado:** Aceptada
- **Fecha:** 2026-08-20
- **Decidido por:** Jannier Johan Otavo
- **Relacionado con:** Decisión del equipo sobre la documentación de las seis fases

## Contexto

El trabajo integrador produce muchos diagramas: ocho en la Fase 1, seis en la Fase 2 y varios más en
la Fase 3, que es enteramente de modelado UML. Esos diagramas cambian: una regla de negocio nueva
modifica un diagrama de estados, y una historia dividida modifica el mapa de historias.

Un diagrama hecho en una herramienta gráfica se guarda como imagen. Cuando cambia, hay que localizar
el archivo original de la herramienta, esperar que quien lo hizo lo tenga, y confiar en que no se
haya perdido. En Git, además, dos imágenes distintas no se pueden comparar ni fusionar.

## Decisión

Escribir todos los diagramas en PlantUML. La fuente `.puml` se versiona junto al render `.png`, y
ambos se commitean juntos. Los `.png` nunca se editan a mano.

## Consecuencias

Se vuelve más fácil: ver en un diff qué cambió exactamente en un diagrama; que quien retome el proyecto
lo modifique sin depender de una herramienta instalada ni de una cuenta; y regenerar todos los
diagramas de una fase con un solo comando cuando se ajusta el estilo.

Se vuelve más difícil: el control fino de la posición de los elementos, porque la disposición la
decide el motor y no nosotros; algunos diagramas quedan con proporciones incómodas para una página y
hay que reestructurarlos; y se necesita Java instalado para renderizar.

Usamos el motor de disposición **Smetana**, incluido en PlantUML, para no depender de una
instalación de Graphviz.

## Alternativas consideradas

**Herramienta gráfica de diagramación en línea.** Ofrece control visual total, pero deja el diagrama
fuera del control de versiones y ata el proyecto a una cuenta personal.

**Capturas de pantalla de diagramas hechos a mano.** Descartada: irreproducibles y no comparables.
