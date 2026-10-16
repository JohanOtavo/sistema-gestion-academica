# Generador del prototipo en Figma

Este plugin construye dentro de Figma, de forma automatica, el prototipo completo
de la Fase 5 del Sistema de Gestion Academica.

No hay que dibujar nada a mano. Todo lo que aparece en el lienzo lo crea `code.js`.

## Que genera

| Elemento | Cantidad |
|---|---|
| Pantallas como frames con auto layout | 22 |
| Nodos totales | 2212 |
| Conexiones del prototipo, todas con transicion Smart Animate | 142 |
| Estilos de color y de texto | 23 |
| Variables de color y espaciado | 25 |
| Hoja de componentes | 1 |

Ademas deja fijado el punto de partida del prototipo en la pantalla de acceso,
de modo que el boton Presentar de Figma arranca por donde debe.

Cada conexion lleva una transicion Smart Animate de 300 ms con salida suave. Como
las pantallas comparten la barra superior y el menu con el mismo nombre y la misma
posicion, Figma los reconoce entre pantallas y los interpola en lugar de cortar.
Si la version instalada del editor rechazara ese objeto de transicion, el plugin
reintenta sin ella y lo dice en el mensaje final, en lugar de quedarse sin conexiones.

Cada ejecucion escribe en una **pagina nueva** del archivo. Volver a generar no
duplica frames sobre los anteriores ni borra nada: la version previa queda en su
propia pagina y se puede eliminar a mano cuando ya no haga falta.

## Como ejecutarlo

Se necesita **Figma para escritorio**. La version del navegador no permite cargar
plugins en desarrollo.

1. Abra Figma para escritorio y cree un archivo de diseno nuevo, o abra uno vacio.
2. Vaya al menu **Plugins**, luego **Development**, luego **Import plugin from manifest**.
3. Escoja el archivo `manifest.json` de esta carpeta.
4. Vuelva a **Plugins**, **Development**, y pulse **SGA - Generador del prototipo**.

Tarda unos segundos. Al terminar muestra un aviso con lo que genero y encuadra
la vista sobre todas las pantallas.

## Si algo sale mal

| Sintoma | Causa probable | Que hacer |
|---|---|---|
| No aparece la opcion Import plugin from manifest | Esta usando Figma en el navegador | Instale Figma para escritorio |
| Error sobre la fuente Inter | El editor no tiene Inter disponible | Inter viene con Figma; reinicie el editor |
| Se generan las pantallas pero sin conexiones | Version antigua del editor | Actualice Figma; las conexiones usan la API de reacciones |
| No se crean las variables | El plan de la cuenta no las admite | El resto se genera igual; las variables son opcionales |

El plugin esta escrito para no abortar ante un fallo parcial: si una parte no se
puede crear, continua con lo demas y lo informa en el aviso final.

## Como se verifico

En dos niveles.

**Fuera de Figma**, contra un doble de la API de plugins que comprueba que cada
nodo se crea con los datos correctos, que ninguno se anexa dos veces, que el
arbol no tiene ciclos y que cada propiedad recibe un valor que la API admite.

**Dentro de Figma**, ejecutandolo de verdad. El resultado fue 22 pantallas,
142 de 142 conexiones, 23 estilos y 25 variables, con la forma de reaccion que
incluye la transicion. Despues se reviso pantalla por pantalla contra la
maqueta de trabajo en HTML con la que se midio la accesibilidad.

La primera ejecucion real fallo, y vale la pena dejar escrito por que: el doble
inicial no validaba los rangos que la API exige, de modo que dejaba pasar codigo
que Figma rechazaba. Cuatro defectos aparecieron y se corrigieron:

1. **layoutGrow fuera de rango.** Se usaba para expresar los pesos de columna de
   las tablas, pero la API solo admite 0 o 1. Las proporciones se traducen ahora
   a anchos fijos calculados sobre el ancho util del area de contenido.
2. **Forma del objeto Reaction.** Las conexiones se creaban con `action` en
   singular y el editor las rechazaba en silencio: 0 de 132. El generador prueba
   ahora las formas conocidas de la API y conserva la primera que el editor
   acepta, e informa cual uso.
3. **Confusion de ejes en los contenedores horizontales.** En un contenedor
   horizontal el eje cruzado es la ALTURA, y fijarla recortaba el contenido: las
   pantallas salian de 1280 por 200 pixeles. Eran 14 llamadas afectadas.

4. **resize() fija los dos ejes del auto layout.** Al llamarlo antes de anadir los
   hijos, el alto de la caja quedaba congelado en 1 pixel y las pantallas de acceso
   salian de 1280 por 160 con todo recortado. Ahora el alto se devuelve al contenido
   justo despues de cada resize y una vez terminada cada pantalla.

Tras el tercer arreglo, el doble incluye una comprobacion que detecta ese caso. El
cuarto no lo detecta y conviene decirlo: el doble no modela los efectos colaterales
de resize(), de modo que solo se ve ejecutando el plugin y mirando el resultado.

## Relacion con el resto de la fase

Este plugin **es** el prototipo entregado de la Fase 5: lo que se versiona es el
generador, y el archivo de Figma es su resultado.

Durante la construccion existio ademas una maqueta de trabajo en HTML y CSS con
las mismas 22 pantallas y los mismos datos del juego de prueba de la Fase 4. Sirvio
para medir lo que un frame no deja medir: que ninguna pantalla desborda a 360 px y
que el contraste cumple la relacion exigida. Esa maqueta no forma parte de la
entrega; su resultado esta registrado en la seccion 10.1 del informe de la fase.
