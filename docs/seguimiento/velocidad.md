# Velocidad del equipo

## Por qué llevamos este registro

Los puntos de historia de la Fase 1 los asignamos **por juicio**, comparando cada historia contra
HU-02 (cerrar sesión = 2 puntos) y aplicando una rúbrica de complejidad. No salieron de ninguna
medición, porque cuando los estimamos el equipo todavía no había construido nada.

La velocidad es lo que convierte esas estimaciones en una proyección con base real. Es el número de
puntos de historia que efectivamente completamos en un sprint. Con un solo dato ya se puede
contrastar el plan contra la realidad; con dos o tres, se puede proyectar.

## Cómo la medimos

- Contamos los puntos de las historias que **cumplen la Definición de Terminado** al cierre del
  sprint. No hay crédito parcial: una historia al 90 % aporta **cero** puntos.
- Los puntos se cuentan en el sprint en que la historia se termina, no en el que se empezó.
- No re-estimamos una historia porque haya resultado más difícil de lo previsto. Si la estimación
  estuvo mal, eso es justamente lo que la velocidad debe reflejar.
- No comparamos nuestra velocidad con la de ningún otro equipo. Los puntos son una unidad interna:
  fuera de este equipo no significan nada.

## Replanificación por el cambio de capacidad

> **Vigente desde octubre de 2026.** El plan original se dimensionó para dos personas. El proyecto
> pasó a un solo integrante (RE-06), de modo que **la capacidad por sprint se reduce a la mitad** y
> la distribución de abajo dejó de ser alcanzable tal como está.
>
> El propio registro ya advertía que con 27 puntos de velocidad los 126 del producto mínimo viable
> necesitaban cinco sprints en lugar de cuatro. Con la mitad de capacidad la advertencia deja de ser
> un riesgo y pasa a ser un hecho: **126 puntos no caben en cuatro sprints de una sola persona.**
>
> Las dos salidas siguen siendo las mismas y ahora hay que tomar ambas, no una:
>
> 1. **Recortar alcance.** Mover HU-05 (3), HU-09 (3) y HU-25 (5) a la versión 2 baja el MVP a
>    115 puntos.
> 2. **Ampliar el calendario.** Con una velocidad estimada de 14 puntos por sprint, 115 puntos son
>    ocho sprints.
>
> La decisión entre recortar más alcance o ampliar el calendario es de la coordinación académica.
> Lo que me corresponde es entregar el dato antes del Sprint 1, no en la semana del cierre. Mientras
> la decisión no se tome, el plan de abajo se conserva como referencia histórica de lo que se
> comprometió y con qué supuestos.

## Plan inicial (dimensionado para dos personas)

Distribución de los 126 puntos del producto mínimo viable, según la Fase 1:

| Sprint | Objetivo | Puntos planeados |
|---|---|---|
| 1 | Acceso por rol y registro de estudiantes | 28 |
| 2 | Oferta académica configurada | 29 |
| 3 | Matrícula con reglas aplicadas | 24 |
| 4 | Calificaciones y consultas del estudiante | 45 |
| | **Total** | **126** |

## Registro real

| Sprint | Planeado | Completado | Velocidad | Historias no terminadas | Observaciones |
|---|---|---|---|---|---|
| 1 | 28 | — | — | — | Pendiente de ejecutar |
| 2 | 29 | — | — | — | Pendiente de ejecutar |
| 3 | 24 | — | — | — | Pendiente de ejecutar |
| 4 | 45 | — | — | — | Pendiente de ejecutar |

**Velocidad promedio:** sin datos todavía.

Este registro se actualiza el último día de cada sprint, en la misma sesión de la revisión, y el
commit correspondiente usa el alcance `seguimiento`.

## Cómo usaremos el dato

**Al cerrar el sprint 1.** Comparamos lo completado contra los 28 puntos planeados. Si la diferencia
supera el 20 %, replanificamos los sprints 2 a 4 antes de comprometer el siguiente.

**Al cerrar el sprint 2.** Con dos datos calculamos el promedio y proyectamos si los 126 puntos
caben en cuatro sprints. Un solo dato puede ser atípico; dos ya insinúan una tendencia.

**En adelante.** Comprometemos por sprint una cantidad de puntos igual al promedio de los dos
sprints anteriores, no a lo que quisiéramos alcanzar.

## Riesgo ya identificado en el plan

El sprint 4 tiene **45 puntos**, mientras que el promedio de los tres primeros es de **27**. Está un
67 % por encima, y eso lo detectamos desde la Fase 1.

Si la velocidad medida ronda los 27 puntos, tenemos dos salidas y probablemente necesitemos las dos:

1. **Mover historias al respaldo de la versión 2.** HU-05 (3), HU-09 (3) y HU-25 (5) suman 11
   puntos. El sprint 4 quedaría en 34, que sigue estando un 26 % por encima del promedio.
2. **Dividir HU-18** (registrar calificaciones, 13 puntos), por ejemplo separando el registro de
   notas de un corte del guardado parcial y la trazabilidad.

Conviene ser explícitos: **con una velocidad de 27 puntos, los 126 del producto mínimo viable no
caben en cuatro sprints, sino en cinco.** Preferimos decirlo desde ahora y no en la semana del
cierre. La decisión entre recortar alcance o agregar un sprint es de la coordinación académica, no
nuestra; lo que nos corresponde es darle el dato a tiempo.

## Qué no es la velocidad

No es una medida de productividad. Quien quiera subir su velocidad solo tiene que inflar sus
estimaciones, y con eso el número sube sin que se entregue nada más. Por eso el número solo se usa
para planear, nunca para evaluar a quien desarrolla.
