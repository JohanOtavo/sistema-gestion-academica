// =====================================================================
// SGA - Generador del prototipo en Figma
// Sistema de Gestion Academica - Grupo 6 - Fase 5
//
// Construye dentro de Figma, de forma programatica:
//   - la coleccion de variables de color y espaciado
//   - los estilos de color y de texto
//   - la libreria de componentes (botones, distintivos, mensajes, campos)
//   - las 18 pantallas como frames con auto layout
//   - las conexiones del prototipo entre pantallas
//
// Se ejecuta una sola vez. Todo lo que aparece en el lienzo lo crea este
// archivo: no hay que dibujar nada a mano.
// =====================================================================

// ---------------------------------------------------------------------
// 1. Tokens
// ---------------------------------------------------------------------
var COLOR = {
  azul900: '#1f3864',
  azul700: '#2a4f8a',
  azul600: '#2e75b6',
  azul100: '#deebf7',
  azul050: '#f4f8fd',
  gris900: '#1a1a1a',
  gris700: '#44474d',
  gris400: '#9aa0a6',
  gris200: '#dfe1e5',
  gris100: '#f1f3f4',
  blanco: '#ffffff',
  verdeFondo: '#e6f4ea',
  verdeTexto: '#10632b',
  rojoFondo: '#fce8e6',
  rojoTexto: '#a50e0e',
  ambarFondo: '#fef7e0',
  ambarTexto: '#7f6000',
  cian: '#11b0c8'
};

var FUENTE = 'Inter';
var ANCHO = 1280;
var SEP = 120; // separacion entre frames en el lienzo

function rgb(hex) {
  var h = hex.replace('#', '');
  return {
    r: parseInt(h.substring(0, 2), 16) / 255,
    g: parseInt(h.substring(2, 4), 16) / 255,
    b: parseInt(h.substring(4, 6), 16) / 255
  };
}

function solido(hex) {
  return [{ type: 'SOLID', color: rgb(hex) }];
}

// Degradado lineal. Solo dos direcciones, las dos con matriz conocida y
// estable en la API: de izquierda a derecha y de arriba a abajo.
function degradado(hexA, hexB, direccion) {
  var matriz = direccion === 'vertical'
    ? [[0, 1, 0], [-1, 0, 1]]
    : [[1, 0, 0], [0, 1, 0]];
  return [{
    type: 'GRADIENT_LINEAR',
    gradientTransform: matriz,
    gradientStops: [
      { position: 0, color: { r: rgb(hexA).r, g: rgb(hexA).g, b: rgb(hexA).b, a: 1 } },
      { position: 1, color: { r: rgb(hexB).r, g: rgb(hexB).g, b: rgb(hexB).b, a: 1 } }
    ]
  }];
}

// Sombra suave. Equivale a las variables --sombra-N de la hoja de estilo.
function sombra(nodo, nivel) {
  var niveles = {
    1: { y: 1, radio: 3, alfa: .10 },
    2: { y: 2, radio: 6, alfa: .10 },
    3: { y: 6, radio: 14, alfa: .12 },
    4: { y: 14, radio: 28, alfa: .16 }
  };
  var n = niveles[nivel] || niveles[1];
  try {
    nodo.effects = [{
      type: 'DROP_SHADOW',
      color: { r: 0.06, g: 0.09, b: 0.19, a: n.alfa },
      offset: { x: 0, y: n.y },
      radius: n.radio,
      spread: 0,
      visible: true,
      blendMode: 'NORMAL'
    }];
  } catch (e) { /* ignorar */ }
  return nodo;
}

// Barra de progreso de ancho fijo: el porcentaje se dibuja, el texto que lo
// acompana sigue siendo la fuente de verdad.
var ANCHO_PROGRESO = 240;

function progreso(porcentaje, lleno) {
  var caja = marco('Progreso', { fondo: COLOR.gris200, radio: 999 });
  auto(caja, 'HORIZONTAL', { sep: 0 });
  try {
    caja.resize(ANCHO_PROGRESO, 6);
    caja.primaryAxisSizingMode = 'FIXED';
    caja.counterAxisSizingMode = 'FIXED';
    caja.clipsContent = true;
  } catch (e) { /* ignorar */ }
  var relleno = marco('Relleno', { radio: 999 });
  relleno.fills = lleno
    ? degradado('#c0392b', '#e74c3c', 'horizontal')
    : degradado(COLOR.azul600, COLOR.cian, 'horizontal');
  try {
    relleno.resize(Math.max(Math.round(ANCHO_PROGRESO * porcentaje / 100), 3), 6);
  } catch (e) { /* ignorar */ }
  caja.appendChild(relleno);
  return caja;
}

// ---------------------------------------------------------------------
// 2. Ayudantes de construccion
// ---------------------------------------------------------------------
function auto(nodo, dir, opts) {
  opts = opts || {};
  nodo.layoutMode = dir;
  nodo.primaryAxisSizingMode = opts.principal || 'AUTO';
  nodo.counterAxisSizingMode = opts.cruzado || 'AUTO';
  nodo.itemSpacing = opts.sep === undefined ? 12 : opts.sep;
  var p = opts.pad === undefined ? 0 : opts.pad;
  nodo.paddingTop = opts.padTop === undefined ? p : opts.padTop;
  nodo.paddingBottom = opts.padBottom === undefined ? p : opts.padBottom;
  nodo.paddingLeft = opts.padLeft === undefined ? p : opts.padLeft;
  nodo.paddingRight = opts.padRight === undefined ? p : opts.padRight;
  if (opts.alinearCruzado) nodo.counterAxisAlignItems = opts.alinearCruzado;
  if (opts.alinearPrincipal) nodo.primaryAxisAlignItems = opts.alinearPrincipal;
  return nodo;
}

function marco(nombre, opts) {
  var f = figma.createFrame();
  f.name = nombre;
  opts = opts || {};
  f.fills = opts.fondo ? solido(opts.fondo) : [];
  if (opts.borde) {
    f.strokes = solido(opts.borde);
    f.strokeWeight = opts.grosorBorde || 1;
  }
  if (opts.radio) f.cornerRadius = opts.radio;
  return f;
}

function texto(contenido, opts) {
  opts = opts || {};
  var t = figma.createText();
  t.fontName = { family: FUENTE, style: opts.estilo || 'Regular' };
  t.fontSize = opts.tam || 14;
  t.characters = contenido === null || contenido === undefined ? '' : String(contenido);
  t.fills = solido(opts.color || COLOR.gris900);
  t.lineHeight = { unit: 'PERCENT', value: opts.interlinea || 150 };
  t.textAutoResize = 'HEIGHT';
  if (opts.centrado) {
    try { t.textAlignHorizontal = 'CENTER'; } catch (e) { /* ignorar */ }
  }
  return t;
}

function estirar(nodo) {
  try { nodo.layoutAlign = 'STRETCH'; } catch (e) { /* el padre no es auto layout */ }
  return nodo;
}

// resize() fija los DOS ejes del auto layout. Si se llama antes de anadir los
// hijos, el alto queda congelado en 1 px y el contenido se recorta. Por eso se
// devuelve el eje principal a AUTO justo despues.
function anchoFijo(nodo, w) {
  try {
    nodo.resize(w, Math.max(nodo.height, 1));
    nodo.counterAxisSizingMode = 'FIXED';
    nodo.primaryAxisSizingMode = 'AUTO';
  } catch (e) { /* ignorar */ }
  return nodo;
}

// Tras anadir los hijos, se reafirma que el alto lo manda el contenido.
function altoSegunContenido(nodo) {
  try { nodo.primaryAxisSizingMode = 'AUTO'; } catch (e) { /* ignorar */ }
  return nodo;
}

// ---------------------------------------------------------------------
// 3. Componentes de la interfaz
// ---------------------------------------------------------------------
function boton(etiqueta, tipo) {
  var fondo = COLOR.azul600;
  var textoColor = COLOR.blanco;
  var borde = null;
  if (tipo === 'secundario') { fondo = COLOR.blanco; textoColor = COLOR.azul700; borde = COLOR.gris400; }
  if (tipo === 'peligro') { fondo = COLOR.blanco; textoColor = COLOR.rojoTexto; borde = COLOR.rojoTexto; }

  var b = marco('Boton ' + (tipo || 'principal'), { fondo: fondo, borde: borde, radio: 6 });
  auto(b, 'HORIZONTAL', { pad: 10, padLeft: 16, padRight: 16, sep: 0, alinearCruzado: 'CENTER' });
  b.appendChild(texto(etiqueta, { tam: 13, estilo: 'Semi Bold', color: textoColor }));
  return b;
}

function distintivo(etiqueta, tono) {
  var fondos = { ok: COLOR.verdeFondo, error: COLOR.rojoFondo, alerta: COLOR.ambarFondo, neutro: COLOR.gris100 };
  var textos = { ok: COLOR.verdeTexto, error: COLOR.rojoTexto, alerta: COLOR.ambarTexto, neutro: COLOR.gris700 };
  var d = marco('Distintivo ' + tono, { fondo: fondos[tono] || COLOR.gris100, radio: 999 });
  auto(d, 'HORIZONTAL', { pad: 3, padLeft: 10, padRight: 10, sep: 0, alinearCruzado: 'CENTER' });
  d.appendChild(texto(etiqueta, { tam: 11, estilo: 'Semi Bold', color: textos[tono] || COLOR.gris700 }));
  return d;
}

function mensaje(tono, titulo, cuerpo) {
  var fondos = { exito: COLOR.verdeFondo, error: COLOR.rojoFondo, aviso: COLOR.ambarFondo, info: COLOR.azul100 };
  var textos = { exito: COLOR.verdeTexto, error: COLOR.rojoTexto, aviso: COLOR.ambarTexto, info: COLOR.azul900 };
  var color = textos[tono] || COLOR.gris900;

  var m = marco('Mensaje ' + tono, { fondo: fondos[tono] || COLOR.gris100, radio: 6 });
  auto(m, 'VERTICAL', { pad: 14, sep: 4, cruzado: 'FIXED' });
  try {
    m.strokes = solido(color);
    m.strokeWeight = 0;
    m.strokeLeftWeight = 4;
  } catch (e) { /* version antigua del editor */ }
  m.appendChild(estirar(texto(titulo, { tam: 13, estilo: 'Bold', color: color })));
  if (cuerpo) m.appendChild(estirar(texto(cuerpo, { tam: 13, color: color })));
  return m;
}

function campo(def) {
  var c = marco('Campo', {});
  auto(c, 'VERTICAL', { sep: 4, cruzado: 'FIXED' });
  c.appendChild(estirar(texto(def.rotulo + (def.obligatorio ? ' *' : ''), { tam: 13, estilo: 'Semi Bold' })));

  var caja = marco('Control', {
    fondo: def.deshabilitado ? COLOR.gris100 : COLOR.blanco,
    borde: def.error ? COLOR.rojoTexto : COLOR.gris400,
    grosorBorde: def.error ? 2 : 1,
    radio: 6
  });
  auto(caja, 'HORIZONTAL', { pad: 10, padLeft: 12, padRight: 12, sep: 0, principal: 'FIXED' });
  caja.appendChild(texto(def.valor || def.marcador || '', {
    tam: 14,
    color: def.valor ? COLOR.gris900 : COLOR.gris400
  }));
  c.appendChild(estirar(caja));

  if (def.error) c.appendChild(estirar(texto(def.error, { tam: 12, estilo: 'Semi Bold', color: COLOR.rojoTexto })));
  else if (def.ayuda) c.appendChild(estirar(texto(def.ayuda, { tam: 12, color: COLOR.gris700 })));
  return c;
}

// El ancho util del area de contenido: 1280 menos los margenes del cuerpo,
// el menu lateral y la separacion entre ambos.
var ANCHO_CONTENIDO = ANCHO - 48 - 220 - 24;

// Figma solo admite layoutGrow 0 o 1, de modo que las proporciones de columna
// no se pueden expresar con pesos de crecimiento: se traducen a anchos fijos.
function celda(valor, ancho, cabecera) {
  var envoltura = marco('Celda', {});
  auto(envoltura, 'HORIZONTAL', { pad: 10, sep: 6, alinearCruzado: 'CENTER', principal: 'FIXED' });
  envoltura.resize(ancho, 1);

  if (valor && typeof valor === 'object' && valor.distintivo) {
    envoltura.appendChild(distintivo(valor.distintivo, valor.tono));
  } else if (valor && typeof valor === 'object' && valor.pendiente) {
    var tp = texto(valor.pendiente, { tam: 12, color: COLOR.gris700 });
    tp.layoutGrow = 1;
    envoltura.appendChild(tp);
  } else {
    var tv = texto(valor, {
      tam: 12,
      estilo: cabecera ? 'Semi Bold' : 'Regular',
      color: cabecera ? COLOR.azul900 : COLOR.gris900
    });
    tv.layoutGrow = 1;   // el texto ocupa la celda y por lo tanto se ajusta
    envoltura.appendChild(tv);
  }
  return envoltura;
}

function anchosDeColumna(def, anchoTotal) {
  var n = def.columnas.length;
  var pesos = [];
  var suma = 0;
  for (var i = 0; i < n; i++) {
    var p = def.pesos && def.pesos[i] ? def.pesos[i] : 1;
    pesos.push(p);
    suma += p;
  }
  var anchos = [];
  var acumulado = 0;
  for (var j = 0; j < n; j++) {
    var w = j === n - 1 ? anchoTotal - acumulado : Math.floor(anchoTotal * pesos[j] / suma);
    anchos.push(Math.max(w, 60));
    acumulado += w;
  }
  return anchos;
}

function tabla(def, anchoTotal) {
  anchoTotal = anchoTotal || ANCHO_CONTENIDO;
  var anchos = anchosDeColumna(def, anchoTotal);

  var t = marco('Tabla', { fondo: COLOR.blanco, borde: COLOR.gris200, radio: 6 });
  auto(t, 'VERTICAL', { sep: 0, cruzado: 'FIXED' });

  var cab = marco('Cabecera', { fondo: COLOR.azul050 });
  auto(cab, 'HORIZONTAL', { sep: 0, principal: 'FIXED' });
  for (var i = 0; i < def.columnas.length; i++) {
    cab.appendChild(celda(def.columnas[i], anchos[i], true));
  }
  t.appendChild(estirar(cab));

  for (var f = 0; f < def.filas.length; f++) {
    var fila = marco('Fila', { fondo: COLOR.blanco });
    auto(fila, 'HORIZONTAL', { sep: 0, principal: 'FIXED' });
    try {
      fila.strokes = solido(COLOR.gris200);
      fila.strokeWeight = 0;
      fila.strokeTopWeight = 1;
    } catch (e) { /* ignorar */ }
    for (var c = 0; c < def.filas[f].length; c++) {
      fila.appendChild(celda(def.filas[f][c], anchos[c], false));
    }
    t.appendChild(estirar(fila));
  }
  return t;
}

// ---------------------------------------------------------------------
// 4. Estructura de una pantalla
// ---------------------------------------------------------------------
var enlaces = []; // {nodo, destino}, se resuelve al final

function registrarEnlace(nodo, destino) {
  if (destino) enlaces.push({ nodo: nodo, destino: destino });
}

function barraSuperior(def) {
  var barra = marco('Barra superior', {});
  barra.fills = degradado('#1a2f55', COLOR.azul700, 'horizontal');
  sombra(barra, 2);
  auto(barra, 'HORIZONTAL', { pad: 16, padLeft: 24, padRight: 24, sep: 12, alinearCruzado: 'CENTER', principal: 'FIXED' });

  var marca = marco('Marca', {});
  auto(marca, 'HORIZONTAL', { sep: 6, alinearCruzado: 'CENTER' });
  marca.appendChild(texto('SGA', { tam: 16, estilo: 'Bold', color: COLOR.blanco }));
  marca.appendChild(texto(def.ambito, { tam: 16, color: COLOR.blanco }));
  barra.appendChild(marca);

  var hueco = marco('Espaciador', {});
  auto(hueco, 'HORIZONTAL', { sep: 0 });
  hueco.layoutGrow = 1;
  barra.appendChild(hueco);

  barra.appendChild(distintivo(def.rol, 'neutro'));
  barra.appendChild(texto(def.usuario, { tam: 13, color: COLOR.blanco }));
  var salir = texto('Cerrar sesion', { tam: 13, color: COLOR.blanco });
  barra.appendChild(salir);
  registrarEnlace(salir, 'acceso');
  return barra;
}

function menuLateral(items, activo) {
  var m = marco('Menu', { fondo: COLOR.blanco, borde: COLOR.gris200, radio: 6 });
  auto(m, 'VERTICAL', { pad: 12, sep: 2, cruzado: 'FIXED' });
  anchoFijo(m, 220);

  for (var i = 0; i < items.length; i++) {
    var it = items[i];
    if (it.titulo) {
      var env = marco('Grupo', {});
      auto(env, 'HORIZONTAL', { pad: 8, padBottom: 2, padTop: 10, sep: 0, principal: 'FIXED' });
      env.appendChild(texto(it.titulo.toUpperCase(), { tam: 11, estilo: 'Semi Bold', color: COLOR.gris700 }));
      m.appendChild(estirar(env));
      continue;
    }
    var esActivo = it.clave === activo;
    var op = marco('Opcion', { fondo: esActivo ? COLOR.azul100 : null, radio: 6 });
    auto(op, 'HORIZONTAL', { pad: 8, padLeft: 12, padRight: 12, sep: 0, principal: 'FIXED' });
    op.appendChild(texto(it.etiqueta, {
      tam: 13,
      estilo: esActivo ? 'Semi Bold' : 'Regular',
      color: esActivo ? COLOR.azul900 : COLOR.gris900
    }));
    m.appendChild(estirar(op));
    if (!esActivo) registrarEnlace(op, it.clave);
  }
  return m;
}

function bloque(def, contenedor) {
  var i, sub, env;

  if (def.t === 'h1') {
    contenedor.appendChild(estirar(texto(def.s, { tam: 24, estilo: 'Bold', color: COLOR.azul900, interlinea: 130 })));

  } else if (def.t === 'h2') {
    contenedor.appendChild(estirar(texto(def.s, { tam: 18, estilo: 'Bold', color: COLOR.azul900, interlinea: 130 })));

  } else if (def.t === 'p') {
    contenedor.appendChild(estirar(texto(def.s, { tam: 14, color: COLOR.gris900 })));

  } else if (def.t === 'ruta') {
    contenedor.appendChild(estirar(texto(def.s, { tam: 12, color: COLOR.gris700 })));

  } else if (def.t === 'msg') {
    contenedor.appendChild(estirar(mensaje(def.tono, def.titulo, def.cuerpo)));

  } else if (def.t === 'hero') {
    env = marco('Encabezado del panel', { radio: 16 });
    env.fills = degradado(COLOR.azul900, COLOR.azul600, 'horizontal');
    auto(env, 'VERTICAL', { pad: 24, sep: 6, cruzado: 'FIXED' });
    sombra(env, 4);
    if (def.insignia) {
      var chip = marco('Insignia', { fondo: COLOR.azul900, radio: 999 });
      auto(chip, 'HORIZONTAL', { padLeft: 12, padRight: 12, padTop: 4, padBottom: 4 });
      chip.appendChild(texto(def.insignia.toUpperCase(), { tam: 11, estilo: 'Semi Bold', color: COLOR.blanco }));
      env.appendChild(chip);
    }
    env.appendChild(estirar(texto(def.titulo, { tam: 26, estilo: 'Bold', color: COLOR.blanco, interlinea: 130 })));
    if (def.sub) env.appendChild(estirar(texto(def.sub, { tam: 14, color: COLOR.blanco })));
    contenedor.appendChild(estirar(env));

  } else if (def.t === 'indicadores') {
    env = marco('Indicadores', {});
    auto(env, 'HORIZONTAL', { sep: 16, principal: 'FIXED' });
    for (i = 0; i < def.items.length; i++) {
      sub = marco('Indicador', { fondo: COLOR.blanco, borde: COLOR.gris200, radio: 10 });
      auto(sub, 'VERTICAL', { pad: 0, sep: 0, cruzado: 'FIXED' });
      sub.layoutGrow = 1;
      sub.clipsContent = true;
      sombra(sub, 2);

      // Cinta superior: el mismo detalle que el prototipo dibuja con ::before
      var cinta = marco('Cinta', {});
      cinta.fills = degradado(COLOR.azul600, COLOR.cian, 'horizontal');
      try { cinta.resize(100, 4); cinta.counterAxisSizingMode = 'FIXED'; } catch (e) { /* ignorar */ }
      sub.appendChild(estirar(cinta));

      var dentro = marco('Contenido del indicador', {});
      auto(dentro, 'VERTICAL', { pad: 20, sep: 4, cruzado: 'FIXED' });
      estirar(dentro);
      dentro.appendChild(texto(def.items[i].cifra, { tam: 38, estilo: 'Bold', color: COLOR.azul900, interlinea: 110 }));
      dentro.appendChild(texto(def.items[i].rotulo, { tam: 13, color: COLOR.gris700 }));
      if (def.items[i].detalle) {
        dentro.appendChild(texto(def.items[i].detalle, { tam: 12, color: COLOR.gris700 }));
      }
      if (def.items[i].porcentaje !== undefined) {
        dentro.appendChild(progreso(def.items[i].porcentaje, def.items[i].lleno));
      }
      sub.appendChild(dentro);
      altoSegunContenido(dentro);
      env.appendChild(sub);
    }
    contenedor.appendChild(estirar(env));

  } else if (def.t === 'accesos') {
    env = marco('Accesos directos', {});
    auto(env, 'HORIZONTAL', { sep: 12, principal: 'FIXED' });
    for (i = 0; i < def.items.length; i++) {
      sub = marco('Acceso', { fondo: COLOR.blanco, borde: COLOR.gris200, radio: 6 });
      auto(sub, 'VERTICAL', { pad: 16, sep: 2, cruzado: 'FIXED' });
      sub.layoutGrow = 1;
      try {
        sub.strokes = solido(COLOR.azul600);
        sub.strokeLeftWeight = 4;
      } catch (e) { /* ignorar */ }
      sombra(sub, 2);
      var encabezadoAcceso = marco('Titulo del acceso', {});
      auto(encabezadoAcceso, 'HORIZONTAL', { sep: 8, principal: 'FIXED', alinearCruzado: 'CENTER' });
      estirar(encabezadoAcceso);
      var tituloAcceso = texto(def.items[i].titulo, { tam: 14, estilo: 'Semi Bold', color: COLOR.azul900 });
      tituloAcceso.layoutGrow = 1;
      encabezadoAcceso.appendChild(tituloAcceso);
      encabezadoAcceso.appendChild(texto('→', { tam: 14, estilo: 'Semi Bold', color: COLOR.azul600 }));
      sub.appendChild(encabezadoAcceso);
      sub.appendChild(texto(def.items[i].sub, { tam: 12, color: COLOR.gris700 }));
      env.appendChild(sub);
      registrarEnlace(sub, def.items[i].a);
    }
    contenedor.appendChild(estirar(env));

  } else if (def.t === 'tabla') {
    contenedor.appendChild(estirar(tabla(def)));

  } else if (def.t === 'filtros') {
    env = marco('Filtros', { fondo: COLOR.blanco, borde: COLOR.gris200, radio: 6 });
    auto(env, 'HORIZONTAL', { pad: 16, sep: 12, principal: 'FIXED', alinearCruzado: 'MAX' });
    for (i = 0; i < def.campos.length; i++) {
      var cmp = campo(def.campos[i]);
      cmp.layoutGrow = 1;
      env.appendChild(cmp);
    }
    env.appendChild(boton(def.boton || 'Filtrar', 'secundario'));
    contenedor.appendChild(estirar(env));

  } else if (def.t === 'form') {
    env = marco('Formulario', { fondo: COLOR.blanco, borde: COLOR.gris200, radio: 6 });
    auto(env, 'VERTICAL', { pad: 24, sep: 16, cruzado: 'FIXED' });
    for (i = 0; i < def.campos.length; i++) {
      if (def.campos[i].pareja) {
        var par = marco('Pareja', {});
        auto(par, 'HORIZONTAL', { sep: 16, principal: 'FIXED' });
        for (var j = 0; j < def.campos[i].pareja.length; j++) {
          var c2 = campo(def.campos[i].pareja[j]);
          c2.layoutGrow = 1;
          par.appendChild(c2);
        }
        env.appendChild(estirar(par));
      } else {
        env.appendChild(estirar(campo(def.campos[i])));
      }
    }
    contenedor.appendChild(estirar(env));

  } else if (def.t === 'ficha') {
    env = marco('Ficha', { fondo: COLOR.blanco, borde: COLOR.gris200, radio: 6 });
    auto(env, 'VERTICAL', { pad: 24, sep: 14, cruzado: 'FIXED' });
    for (i = 0; i < def.items.length; i += 2) {
      var fila2 = marco('Par', {});
      auto(fila2, 'HORIZONTAL', { sep: 24, principal: 'FIXED' });
      for (var k = i; k < Math.min(i + 2, def.items.length); k++) {
        var cel = marco('Dato', {});
        auto(cel, 'VERTICAL', { sep: 2, cruzado: 'FIXED' });
        cel.layoutGrow = 1;
        cel.appendChild(texto(def.items[k][0], { tam: 11, color: COLOR.gris700 }));
        cel.appendChild(texto(def.items[k][1], { tam: 14, estilo: 'Semi Bold' }));
        fila2.appendChild(cel);
      }
      env.appendChild(estirar(fila2));
    }
    contenedor.appendChild(estirar(env));

  } else if (def.t === 'vacio') {
    env = marco('Estado vacio', { borde: COLOR.gris200, radio: 6 });
    auto(env, 'VERTICAL', { pad: 40, sep: 10, cruzado: 'FIXED', alinearCruzado: 'CENTER' });
    try {
      env.dashPattern = [6, 4];
      env.strokeWeight = 2;
    } catch (e) { /* ignorar */ }
    env.appendChild(texto(def.titulo, { tam: 14, estilo: 'Semi Bold', color: COLOR.gris700 }));
    env.appendChild(texto(def.cuerpo, { tam: 13, color: COLOR.gris700 }));
    if (def.boton) env.appendChild(boton(def.boton, 'principal'));
    contenedor.appendChild(estirar(env));

  } else if (def.t === 'acciones') {
    env = marco('Acciones', {});
    auto(env, 'HORIZONTAL', { sep: 12, principal: 'FIXED' });
    for (i = 0; i < def.items.length; i++) {
      var bt = boton(def.items[i].etiqueta, def.items[i].tipo);
      env.appendChild(bt);
      registrarEnlace(bt, def.items[i].a);
    }
    contenedor.appendChild(estirar(env));

  } else if (def.t === 'nota') {
    env = marco('Nota del prototipo', { fondo: COLOR.ambarFondo, radio: 6 });
    auto(env, 'VERTICAL', { pad: 14, sep: 0, cruzado: 'FIXED' });
    try {
      env.strokes = solido(COLOR.ambarTexto);
      env.strokeWeight = 0;
      env.strokeLeftWeight = 4;
    } catch (e) { /* ignorar */ }
    env.appendChild(estirar(texto(def.s, { tam: 12, color: COLOR.ambarTexto })));
    contenedor.appendChild(estirar(env));
  }
}

function construirPantalla(def) {
  var raiz = marco(def.nombre, { fondo: COLOR.azul050 });
  auto(raiz, 'VERTICAL', { sep: 0, cruzado: 'FIXED', principal: 'AUTO' });
  raiz.resize(ANCHO, 100);

  if (def.barra) raiz.appendChild(estirar(barraSuperior(def.barra)));

  var cuerpo = marco('Cuerpo', {});
  auto(cuerpo, 'HORIZONTAL', { pad: 24, sep: 24, principal: 'FIXED' });
  estirar(cuerpo);

  if (def.menu) cuerpo.appendChild(menuLateral(def.menu, def.activo));

  var contenido = marco('Contenido', {});
  auto(contenido, 'VERTICAL', { sep: 16, cruzado: 'FIXED' });
  contenido.layoutGrow = 1;

  for (var i = 0; i < def.bloques.length; i++) bloque(def.bloques[i], contenido);

  cuerpo.appendChild(contenido);
  raiz.appendChild(cuerpo);
  altoSegunContenido(cuerpo);
  altoSegunContenido(raiz);
  return raiz;
}

function construirAcceso(def) {
  var raiz = marco(def.nombre, {});
  raiz.fills = degradado(COLOR.azul700, '#152649', 'vertical');
  auto(raiz, 'VERTICAL', { pad: 80, sep: 0, cruzado: 'FIXED', alinearCruzado: 'CENTER' });
  raiz.resize(ANCHO, 100);

  var caja = marco('Caja de acceso', { fondo: COLOR.blanco, radio: 18 });
  auto(caja, 'VERTICAL', { pad: 32, sep: 16, cruzado: 'FIXED' });
  anchoFijo(caja, 420);
  sombra(caja, 4);

  // Sello de la marca, igual que el del prototipo en HTML
  var sello = marco('Sello', { radio: 14 });
  sello.fills = degradado(COLOR.azul600, COLOR.azul900, 'vertical');
  auto(sello, 'VERTICAL', { alinearCruzado: 'CENTER', alinearPrincipal: 'CENTER' });
  try {
    sello.resize(52, 52);
    sello.primaryAxisSizingMode = 'FIXED';
    sello.counterAxisSizingMode = 'FIXED';
  } catch (e) { /* ignorar */ }
  sello.appendChild(texto('SGA', { tam: 17, estilo: 'Bold', color: COLOR.blanco }));

  var filaSello = marco('Marca', {});
  auto(filaSello, 'HORIZONTAL', { sep: 0, principal: 'FIXED', alinearPrincipal: 'CENTER' });
  estirar(filaSello);
  filaSello.appendChild(sello);
  caja.appendChild(filaSello);

  caja.appendChild(estirar(texto(def.titulo, { tam: 22, estilo: 'Bold', color: COLOR.azul900, centrado: true })));
  caja.appendChild(estirar(texto(def.lema, { tam: 13, color: COLOR.gris700, centrado: true })));

  for (var i = 0; i < def.campos.length; i++) caja.appendChild(estirar(campo(def.campos[i])));

  for (var j = 0; j < def.botones.length; j++) {
    var b = boton(def.botones[j].etiqueta, def.botones[j].tipo);
    estirar(b);
    // STRETCH por si solo no basta: en un contenedor horizontal el ancho es el
    // eje principal, y mientras sea AUTO el boton se ajusta a su texto.
    try { b.primaryAxisSizingMode = 'FIXED'; } catch (e) { /* ignorar */ }
    b.primaryAxisAlignItems = 'CENTER';
    caja.appendChild(b);
    registrarEnlace(b, def.botones[j].a);
  }

  if (def.pie) {
    for (var k = 0; k < def.pie.length; k++) {
      var p = texto(def.pie[k].etiqueta, { tam: 12, color: COLOR.azul700 });
      estirar(p);
      caja.appendChild(p);
      registrarEnlace(p, def.pie[k].a);
    }
  }

  raiz.appendChild(caja);
  altoSegunContenido(caja);
  altoSegunContenido(raiz);
  return raiz;
}

// ---------------------------------------------------------------------
// 5. Menus por rol
// ---------------------------------------------------------------------
var MENU_ADMIN = [
  { titulo: 'Personas' },
  { clave: 'estudiantes', etiqueta: 'Estudiantes' },
  { clave: 'docentes', etiqueta: 'Docentes' },
  { clave: 'usuarios', etiqueta: 'Cuentas y roles' },
  { titulo: 'Oferta academica' },
  { clave: 'periodos', etiqueta: 'Periodos' },
  { clave: 'cursos', etiqueta: 'Cursos' },
  { titulo: 'Matricula' },
  { clave: 'matricular', etiqueta: 'Matricular' },
  { clave: 'lista-clase', etiqueta: 'Listas de clase' },
  { titulo: 'Panel' },
  { clave: 'panel-admin', etiqueta: 'Resumen' }
];

var MENU_DOCENTE = [
  { titulo: 'Mi trabajo' },
  { clave: 'panel-docente', etiqueta: 'Mis cursos' },
  { clave: 'calificar', etiqueta: 'Registrar notas' }
];

var MENU_ESTUDIANTE = [
  { titulo: 'Mi informacion' },
  { clave: 'panel-estudiante', etiqueta: 'Mis cursos' },
  { clave: 'mis-notas', etiqueta: 'Mis notas' }
];

var BARRA_ADMIN = { ambito: 'Administracion', rol: 'Administradora', usuario: 'Laura Restrepo' };
var BARRA_DOCENTE = { ambito: 'Docente', rol: 'Docente', usuario: 'Carlos Andres Mejia' };
var BARRA_ESTUDIANTE = { ambito: 'Estudiante', rol: 'Estudiante', usuario: 'Valentina Rios' };

// ---------------------------------------------------------------------
// 6. Las 18 pantallas
// ---------------------------------------------------------------------
var PANTALLAS = [
  {
    clave: 'acceso', tipo: 'acceso', nombre: '01 Acceso',
    titulo: 'Sistema de Gestion Academica',
    lema: 'Institucion Educativa - Periodo 2026-2',
    campos: [
      { rotulo: 'Correo institucional', marcador: 'nombre.apellido@sga.edu.co', obligatorio: true },
      { rotulo: 'Contrasena', marcador: 'Minimo 8 caracteres', obligatorio: true, ayuda: 'Minimo 8 caracteres (RN-21).' }
    ],
    botones: [{ etiqueta: 'Ingresar', tipo: 'principal', a: 'panel-admin' }],
    pie: [
      { etiqueta: 'Olvide mi contrasena', a: 'recuperar' },
      { etiqueta: 'Entrar como docente', a: 'panel-docente' },
      { etiqueta: 'Entrar como estudiante', a: 'panel-estudiante' },
      { etiqueta: 'Primer ingreso: cambiar contrasena', a: 'cambiar-clave' }
    ]
  },
  {
    clave: 'cambiar-clave', tipo: 'acceso', nombre: '02 Cambio de contrasena',
    titulo: 'Cambie su contrasena',
    lema: 'Primer ingreso con la contrasena temporal',
    campos: [
      { rotulo: 'Contrasena temporal', marcador: 'La que asigno la administradora', obligatorio: true },
      { rotulo: 'Contrasena nueva', marcador: 'Minimo 8 caracteres', obligatorio: true, ayuda: 'Evite datos faciles de adivinar.' },
      { rotulo: 'Repita la contrasena nueva', valor: 'No coincide', obligatorio: true, error: 'Las dos contrasenas no coinciden. Escriba la misma en ambos campos.' }
    ],
    botones: [{ etiqueta: 'Guardar y continuar', tipo: 'principal', a: 'panel-estudiante' }],
    pie: [{ etiqueta: 'Volver al acceso', a: 'acceso' }]
  },
  {
    clave: 'recuperar', tipo: 'acceso', nombre: '02b Olvide mi contrasena',
    titulo: 'Olvide mi contrasena',
    lema: 'Le enviaremos un enlace a su correo institucional',
    campos: [
      { rotulo: 'Correo institucional', marcador: 'nombre.apellido@sga.edu.co', obligatorio: true,
        ayuda: 'El mismo con el que ingresa al sistema.' }
    ],
    botones: [{ etiqueta: 'Enviarme el enlace', tipo: 'principal', a: 'recuperar-enviado' }],
    pie: [
      { etiqueta: 'Volver al acceso', a: 'acceso' },
      { etiqueta: 'El enlace sirve una sola vez y vence a los 30 minutos (RN-28)' }
    ]
  },
  {
    clave: 'recuperar-enviado', tipo: 'acceso', nombre: '02c Revise su correo',
    titulo: 'Revise su correo',
    lema: 'Si existe una cuenta con ese correo, le enviamos un enlace',
    campos: [],
    botones: [{ etiqueta: 'Abrir el enlace recibido', tipo: 'principal', a: 'recuperar-nueva' }],
    pie: [
      { etiqueta: 'El mensaje no dice si el correo existe: confirmarlo revelaria' },
      { etiqueta: 'que correos estan registrados (RN-29).' },
      { etiqueta: 'Solicitar otro enlace', a: 'recuperar' },
      { etiqueta: 'Volver al acceso', a: 'acceso' }
    ]
  },
  {
    clave: 'recuperar-nueva', tipo: 'acceso', nombre: '02d Contrasena nueva',
    titulo: 'Defina su contrasena nueva',
    lema: 'valentina.rios@sga.edu.co',
    campos: [
      { rotulo: 'Contrasena nueva', marcador: 'Minimo 8 caracteres', obligatorio: true,
        ayuda: 'Minimo 8 caracteres (RN-21).' },
      { rotulo: 'Repita la contrasena nueva', marcador: 'Minimo 8 caracteres', obligatorio: true }
    ],
    botones: [{ etiqueta: 'Guardar y entrar', tipo: 'principal', a: 'acceso' }],
    pie: [
      { etiqueta: 'Al guardar se cierran las sesiones abiertas y dejan de servir' },
      { etiqueta: 'los demas enlaces de la cuenta (RN-31).' },
      { etiqueta: 'Ver el enlace vencido o ya usado', a: 'recuperar-invalido' }
    ]
  },
  {
    clave: 'recuperar-invalido', tipo: 'acceso', nombre: '02e Enlace no valido',
    titulo: 'Este enlace ya no sirve',
    lema: 'El enlace vencio o ya se uso',
    campos: [],
    botones: [{ etiqueta: 'Solicitar un enlace nuevo', tipo: 'principal', a: 'recuperar' }],
    pie: [
      { etiqueta: 'El mensaje es el mismo si el enlace vencio, si ya se uso o si' },
      { etiqueta: 'la cuenta fue inactivada: no da informacion sobre su estado.' },
      { etiqueta: 'Volver al acceso', a: 'acceso' }
    ]
  },
  {
    clave: 'panel-admin', nombre: '03 Panel administrador', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: 'panel-admin',
    bloques: [
      { t: 'nota', s: 'Prototipo de la Fase 5. Los datos son los del juego de prueba de la Fase 4.' },
      { t: 'hero', insignia: 'Periodo en curso', titulo: 'Periodo 2026-2',
        sub: 'Segundo semestre de 2026, del 20 de julio al 27 de noviembre.' },
      { t: 'indicadores', items: [
        { cifra: '11', rotulo: 'Estudiantes activos', detalle: '2,1 cursos por estudiante en promedio' },
        { cifra: '6', rotulo: 'Cursos ofertados', detalle: '5 con docente titular asignado', porcentaje: 83 },
        { cifra: '23', rotulo: 'Matriculas activas', detalle: '23 de 109 cupos ofertados', porcentaje: 21 }
      ] },
      { t: 'h2', s: 'Que necesita hacer' },
      { t: 'accesos', items: [
        { titulo: 'Matricular un estudiante', sub: 'Valida cupo, estado y tope de siete cursos', a: 'matricular' },
        { titulo: 'Revisar la oferta', sub: 'Cupos disponibles y ocupacion por curso', a: 'cursos' },
        { titulo: 'Ver una lista de clase', sub: 'Quien esta matriculado en cada curso', a: 'lista-clase' }
      ] },
      { t: 'h2', s: 'Asuntos que piden atencion' },
      { t: 'msg', tono: 'aviso', titulo: 'Matematicas I llego a su cupo.', cuerpo: '4 de 4 lugares ocupados. Para admitir mas estudiantes, amplie el cupo del curso.' },
      { t: 'msg', tono: 'aviso', titulo: 'Ciencias Sociales no tiene docente asignado.', cuerpo: 'Sin titular no se pueden registrar calificaciones.' },
      { t: 'h2', s: 'Ocupacion de los cursos' },
      { t: 'tabla', pesos: [1, 2, 2, 1, 1, 1],
        columnas: ['Codigo', 'Curso', 'Docente', 'Matriculados', 'Cupo', 'Ocupacion'],
        filas: [
          ['MAT-101', 'Matematicas I', 'Mejia Ruiz, Carlos Andres', '4', '4', { distintivo: 'Lleno, 100 %', tono: 'error' }],
          ['MAT-201', 'Matematicas II', 'Mejia Ruiz, Carlos Andres', '4', '25', { distintivo: '16 %', tono: 'ok' }],
          ['LEN-201', 'Lengua Castellana II', 'Gomez Pena, Marta Lucia', '5', '25', { distintivo: '20 %', tono: 'ok' }],
          ['CIE-101', 'Ciencias Naturales', 'Salazar Torres, Jorge Ivan', '5', '20', { distintivo: '25 %', tono: 'ok' }],
          ['SIS-101', 'Tecnologia e Informatica', 'Perez Mora, Diana Carolina', '3', '15', { distintivo: '20 %', tono: 'ok' }],
          ['SOC-101', 'Ciencias Sociales', { distintivo: 'Sin asignar', tono: 'alerta' }, '2', '20', { distintivo: '10 %', tono: 'ok' }]
        ] }
    ]
  },
  {
    clave: 'estudiantes', nombre: '04 Estudiantes', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: 'estudiantes',
    bloques: [
      { t: 'ruta', s: 'Panel > Estudiantes' },
      { t: 'h1', s: 'Estudiantes' },
      { t: 'msg', tono: 'exito', titulo: 'Estudiante registrado correctamente.', cuerpo: 'Sara Michelle Osorio Ramirez quedo con el codigo EST-2026-011.' },
      { t: 'filtros', campos: [
        { rotulo: 'Buscar por nombre o documento', marcador: 'Rios Cardenas, 1098765401' },
        { rotulo: 'Estado', valor: 'Activos' },
        { rotulo: 'Ordenar por', valor: 'Apellidos' }
      ] },
      { t: 'p', s: '11 estudiantes activos de 12 registrados. Mostrando 1 a 6.' },
      { t: 'acciones', items: [{ etiqueta: 'Registrar estudiante', tipo: 'principal', a: 'estudiante-form' }] },
      { t: 'tabla', pesos: [1, 2, 1, 2, 1, 1],
        columnas: ['Codigo', 'Apellidos y nombres', 'Documento', 'Correo', 'Estado', 'Acciones'],
        filas: [
          ['EST-2026-006', 'Arango Velez, Sebastian', 'TI 1098765406', 'sebastian.arango@sga.edu.co', { distintivo: 'Activo', tono: 'ok' }, 'Ver ficha'],
          ['EST-2026-009', 'Betancur Agudelo, Laura Sofia', 'TI 1098765409', 'laura.betancur@sga.edu.co', { distintivo: 'Activo', tono: 'ok' }, 'Ver ficha'],
          ['EST-2026-012', 'Cardona Gil, Andres Felipe', 'TI 1098765412', 'andres.cardona@sga.edu.co', { distintivo: 'Inactivo', tono: 'neutro' }, 'Ver ficha'],
          ['EST-2026-003', 'Castano Loaiza, Mariana', 'TI 1098765403', 'mariana.castano@sga.edu.co', { distintivo: 'Activo', tono: 'ok' }, 'Ver ficha'],
          ['EST-2026-008', 'Duque Sierra, Mateo Alejandro', 'TI 1098765408', 'mateo.duque@sga.edu.co', { distintivo: 'Activo', tono: 'ok' }, 'Ver ficha'],
          ['EST-2026-001', 'Rios Cardenas, Valentina', 'TI 1098765401', 'valentina.rios@sga.edu.co', { distintivo: 'Activo', tono: 'ok' }, 'Ver ficha']
        ] },
      { t: 'acciones', items: [{ etiqueta: 'Ver la ficha de Valentina Rios', tipo: 'secundario', a: 'estudiante-detalle' }] }
    ]
  },
  {
    clave: 'estudiante-form', nombre: '05 Formulario de estudiante', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: 'estudiantes',
    bloques: [
      { t: 'ruta', s: 'Panel > Estudiantes > Registrar' },
      { t: 'h1', s: 'Registrar estudiante' },
      { t: 'msg', tono: 'error', titulo: 'No se pudo guardar el estudiante.', cuerpo: 'Revise el campo marcado mas abajo. Ningun dato se perdio.' },
      { t: 'form', campos: [
        { pareja: [
          { rotulo: 'Tipo de documento', valor: 'Tarjeta de identidad', obligatorio: true },
          { rotulo: 'Numero de documento', valor: '1098765401', obligatorio: true, error: 'Ya existe una persona registrada con este documento: Valentina Rios Cardenas.' }
        ] },
        { pareja: [
          { rotulo: 'Nombres', valor: 'Daniela', obligatorio: true },
          { rotulo: 'Apellidos', valor: 'Lopez Grisales', obligatorio: true }
        ] },
        { pareja: [
          { rotulo: 'Correo institucional', valor: 'daniela.lopez@sga.edu.co', obligatorio: true, ayuda: 'Sera su usuario de acceso. Debe ser unico (RN-02).' },
          { rotulo: 'Telefono', valor: '3165558899', ayuda: 'Opcional.' }
        ] },
        { pareja: [
          { rotulo: 'Fecha de nacimiento', valor: '18/05/2010', obligatorio: true },
          { rotulo: 'Fecha de ingreso', valor: '20/07/2026', obligatorio: true }
        ] },
        { rotulo: 'Codigo de estudiante', valor: 'EST-2026-013', deshabilitado: true, ayuda: 'Lo asigna el sistema al guardar.' }
      ] },
      { t: 'acciones', items: [
        { etiqueta: 'Guardar estudiante', tipo: 'principal', a: 'estudiantes' },
        { etiqueta: 'Cancelar', tipo: 'secundario', a: 'estudiantes' }
      ] }
    ]
  },
  {
    clave: 'estudiante-detalle', nombre: '06 Ficha del estudiante', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: 'estudiantes',
    bloques: [
      { t: 'ruta', s: 'Panel > Estudiantes > EST-2026-001' },
      { t: 'h1', s: 'Rios Cardenas, Valentina' },
      { t: 'ficha', items: [
        ['Codigo', 'EST-2026-001'],
        ['Documento', 'TI 1098765401'],
        ['Correo institucional', 'valentina.rios@sga.edu.co'],
        ['Telefono', '3151112233'],
        ['Fecha de nacimiento', '14 de marzo de 2009'],
        ['Fecha de ingreso', '26 de enero de 2026']
      ] },
      { t: 'h2', s: 'Carga academica del periodo 2026-2' },
      { t: 'tabla', pesos: [2, 1, 2, 1, 1],
        columnas: ['Curso', 'Creditos', 'Docente', 'Definitiva', 'Estado'],
        filas: [
          ['MAT-101 Matematicas I', '4', 'Mejia Ruiz, Carlos Andres', '4.1', { distintivo: 'Aprobada', tono: 'ok' }],
          ['LEN-201 Lengua Castellana II', '3', 'Gomez Pena, Marta Lucia', { pendiente: 'En curso' }, { distintivo: 'Falta el corte 3', tono: 'neutro' }],
          ['CIE-101 Ciencias Naturales', '4', 'Salazar Torres, Jorge Ivan', { pendiente: 'En curso' }, { distintivo: 'Falta el corte 3', tono: 'neutro' }],
          ['SIS-101 Tecnologia e Informatica', '2', 'Perez Mora, Diana Carolina', { pendiente: 'En curso' }, { distintivo: 'Falta el corte 2', tono: 'neutro' }]
        ] },
      { t: 'h2', s: 'Historial' },
      { t: 'tabla', pesos: [2, 1, 1],
        columnas: ['Curso', 'Definitiva', 'Resultado'],
        filas: [
          ['MAT-101 Matematicas I (2026-1)', '4.1', { distintivo: 'Aprobada', tono: 'ok' }],
          ['LEN-101 Lengua Castellana I (2026-1)', '4.0', { distintivo: 'Aprobada', tono: 'ok' }]
        ] },
      { t: 'acciones', items: [
        { etiqueta: 'Editar datos', tipo: 'principal', a: 'estudiante-form' },
        { etiqueta: 'Matricular en un curso', tipo: 'secundario', a: 'matricular' },
        { etiqueta: 'Inactivar estudiante', tipo: 'peligro', a: 'estudiantes' }
      ] },
      { t: 'nota', s: 'Inactivar no borra nada. Conserva su historial completo (RN-15, ADR-004).' }
    ]
  },
  {
    clave: 'docentes', nombre: '07 Docentes', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: 'docentes',
    bloques: [
      { t: 'ruta', s: 'Panel > Docentes' },
      { t: 'h1', s: 'Docentes' },
      { t: 'filtros', campos: [
        { rotulo: 'Buscar por nombre o codigo', marcador: 'Mejia, DOC-001' },
        { rotulo: 'Area de conocimiento', valor: 'Todas' },
        { rotulo: 'Estado', valor: 'Activos' }
      ] },
      { t: 'tabla', pesos: [1, 2, 1, 1, 1],
        columnas: ['Codigo', 'Apellidos y nombres', 'Area', 'Cursos asignados', 'Estado'],
        filas: [
          ['DOC-002', 'Gomez Pena, Marta Lucia', 'Humanidades', 'LEN-201', { distintivo: 'Activo', tono: 'ok' }],
          ['DOC-001', 'Mejia Ruiz, Carlos Andres', 'Matematicas', 'MAT-101, MAT-201', { distintivo: 'Activo', tono: 'ok' }],
          ['DOC-004', 'Perez Mora, Diana Carolina', 'Tecnologia', 'SIS-101', { distintivo: 'Activo', tono: 'ok' }],
          ['DOC-003', 'Salazar Torres, Jorge Ivan', 'Ciencias Naturales', 'CIE-101', { distintivo: 'Activo', tono: 'ok' }]
        ] },
      { t: 'h2', s: 'Al intentar inactivar un docente con cursos vigentes' },
      { t: 'msg', tono: 'error', titulo: 'No se puede inactivar a Carlos Andres Mejia Ruiz.', cuerpo: 'Tiene 2 cursos asignados en el periodo activo. Reasignelos antes de inactivarlo (RN-24).' }
    ]
  },
  {
    clave: 'usuarios', nombre: '08 Cuentas y roles', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: 'usuarios',
    bloques: [
      { t: 'ruta', s: 'Panel > Cuentas y roles' },
      { t: 'h1', s: 'Cuentas de acceso' },
      { t: 'msg', tono: 'info', titulo: 'Las contrasenas no se pueden consultar, solo restablecer.', cuerpo: 'El sistema guarda unicamente su resumen criptografico (ADR-007).' },
      { t: 'p', s: '17 cuentas: 1 administradora, 4 docentes y 12 estudiantes.' },
      { t: 'tabla', pesos: [2, 2, 1, 1, 1],
        columnas: ['Correo', 'Persona', 'Rol', 'Ultimo acceso', 'Estado'],
        filas: [
          ['laura.restrepo@sga.edu.co', 'Restrepo Ocampo, Laura Elena', 'Administrador', 'Hoy, 08:12', { distintivo: 'Activa', tono: 'ok' }],
          ['carlos.mejia@sga.edu.co', 'Mejia Ruiz, Carlos Andres', 'Docente', 'Ayer, 17:40', { distintivo: 'Activa', tono: 'ok' }],
          ['valentina.rios@sga.edu.co', 'Rios Cardenas, Valentina', 'Estudiante', 'Hace 3 dias', { distintivo: 'Activa', tono: 'ok' }],
          ['sara.osorio@sga.edu.co', 'Osorio Ramirez, Sara Michelle', 'Estudiante', 'Nunca', { distintivo: 'Contrasena temporal', tono: 'alerta' }],
          ['andres.cardona@sga.edu.co', 'Cardona Gil, Andres Felipe', 'Estudiante', 'Hace 2 meses', { distintivo: 'Inactiva', tono: 'neutro' }]
        ] }
    ]
  },
  {
    clave: 'periodos', nombre: '09 Periodos academicos', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: 'periodos',
    bloques: [
      { t: 'ruta', s: 'Panel > Periodos' },
      { t: 'h1', s: 'Periodos academicos' },
      { t: 'msg', tono: 'info', titulo: 'Solo puede haber un periodo activo a la vez (RN-03).', cuerpo: 'Para activar 2027-1 debe cerrar antes el periodo 2026-2.' },
      { t: 'tabla', pesos: [1, 2, 1, 1, 1, 1],
        columnas: ['Codigo', 'Nombre', 'Inicio', 'Fin', 'Cursos', 'Estado'],
        filas: [
          ['2026-1', 'Primer semestre de 2026', '02/02/2026', '12/06/2026', '2', { distintivo: 'Cerrado', tono: 'neutro' }],
          ['2026-2', 'Segundo semestre de 2026', '20/07/2026', '27/11/2026', '6', { distintivo: 'Activo', tono: 'ok' }],
          ['2027-1', 'Primer semestre de 2027', '01/02/2027', '11/06/2027', '0', { distintivo: 'Planeado', tono: 'alerta' }]
        ] },
      { t: 'h2', s: 'Cerrar el periodo 2026-2' },
      { t: 'msg', tono: 'error', titulo: 'No se puede cerrar el periodo todavia.', cuerpo: 'Hay 18 matriculas con cortes sin calificar. El periodo solo se cierra cuando todas las notas estan registradas.' },
      { t: 'form', campos: [
        { rotulo: 'Para confirmar, escriba el codigo del periodo', marcador: '2026-2', ayuda: 'Escribir el codigo evita cerrar un periodo por accidente.' }
      ] },
      { t: 'acciones', items: [{ etiqueta: 'Cerrar periodo', tipo: 'peligro' }] }
    ]
  },
  {
    clave: 'cursos', nombre: '10 Oferta academica', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: 'cursos',
    bloques: [
      { t: 'ruta', s: 'Panel > Cursos' },
      { t: 'h1', s: 'Cursos del periodo 2026-2' },
      { t: 'filtros', campos: [
        { rotulo: 'Buscar por codigo o nombre', marcador: 'MAT-201, Matematicas' },
        { rotulo: 'Periodo', valor: '2026-2 (activo)' },
        { rotulo: 'Ocupacion', valor: 'Todas' }
      ] },
      { t: 'acciones', items: [{ etiqueta: 'Crear curso', tipo: 'principal', a: 'curso-form' }] },
      { t: 'tabla', pesos: [1, 2, 1, 2, 1, 1],
        columnas: ['Codigo', 'Nombre', 'Creditos', 'Docente', 'Cupo', 'Cortes'],
        filas: [
          ['CIE-101', 'Ciencias Naturales', '4', 'Salazar Torres, Jorge Ivan', '5 de 20', '3 cortes, 100 %'],
          ['LEN-201', 'Lengua Castellana II', '3', 'Gomez Pena, Marta Lucia', '5 de 25', '3 cortes, 100 %'],
          ['MAT-101', 'Matematicas I', '4', 'Mejia Ruiz, Carlos Andres', { distintivo: '4 de 4, lleno', tono: 'error' }, '3 cortes, 100 %'],
          ['MAT-201', 'Matematicas II', '4', 'Mejia Ruiz, Carlos Andres', '4 de 25', '3 cortes, 100 %'],
          ['SIS-101', 'Tecnologia e Informatica', '2', 'Perez Mora, Diana Carolina', '3 de 15', '2 cortes, 100 %'],
          ['SOC-101', 'Ciencias Sociales', '3', { distintivo: 'Sin asignar', tono: 'alerta' }, '2 de 20', '3 cortes, 100 %']
        ] },
      { t: 'nota', s: 'El codigo de un curso es unico dentro de su periodo, no en todo el sistema (RN-20). Por eso MAT-101 existe a la vez en 2026-1 y en 2026-2.' },
      { t: 'acciones', items: [{ etiqueta: 'Editar Ciencias Sociales', tipo: 'secundario', a: 'curso-form' }] }
    ]
  },
  {
    clave: 'curso-form', nombre: '11 Formulario de curso', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: 'cursos',
    bloques: [
      { t: 'ruta', s: 'Panel > Cursos > SOC-101' },
      { t: 'h1', s: 'Editar curso' },
      { t: 'form', campos: [
        { pareja: [
          { rotulo: 'Codigo', valor: 'SOC-101', obligatorio: true, ayuda: 'Unico dentro del periodo (RN-20).' },
          { rotulo: 'Nombre', valor: 'Ciencias Sociales', obligatorio: true }
        ] },
        { pareja: [
          { rotulo: 'Creditos', valor: '3', obligatorio: true, ayuda: 'Entero positivo (RN-25).' },
          { rotulo: 'Cupo maximo', valor: '20', obligatorio: true, ayuda: 'No puede quedar por debajo de los 2 ya matriculados (RN-26).' }
        ] },
        { rotulo: 'Docente titular', valor: 'Sin asignar', ayuda: 'Sin titular no se pueden registrar calificaciones.' }
      ] },
      { t: 'h2', s: 'Cortes evaluativos' },
      { t: 'p', s: 'Los porcentajes deben sumar exactamente 100 % (RN-10).' },
      { t: 'tabla', pesos: [1, 3, 1],
        columnas: ['Corte', 'Descripcion', 'Porcentaje'],
        filas: [
          ['1', 'Primer corte', '30'],
          ['2', 'Segundo corte', '30'],
          ['3', 'Corte final', '40']
        ] },
      { t: 'msg', tono: 'exito', titulo: 'Los porcentajes suman 100 %.', cuerpo: 'La configuracion es valida.' },
      { t: 'msg', tono: 'error', titulo: 'Los porcentajes suman 110 %, deben sumar 100 %.', cuerpo: 'Asi se veria el rechazo si el total no cuadrara.' },
      { t: 'acciones', items: [
        { etiqueta: 'Guardar curso', tipo: 'principal', a: 'cursos' },
        { etiqueta: 'Cancelar', tipo: 'secundario', a: 'cursos' }
      ] }
    ]
  },
  {
    clave: 'matricular', nombre: '12 Matricular estudiante', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: 'matricular',
    bloques: [
      { t: 'ruta', s: 'Panel > Matricular' },
      { t: 'h1', s: 'Matricular estudiante' },
      { t: 'p', s: 'Periodo activo: 2026-2, segundo semestre de 2026.' },
      { t: 'form', campos: [
        { pareja: [
          { rotulo: 'Estudiante', valor: 'EST-2026-001 Rios Cardenas, Valentina', obligatorio: true, ayuda: 'Solo estudiantes activos (RN-06).' },
          { rotulo: 'Curso', valor: 'MAT-201 Matematicas II, 21 cupos libres', obligatorio: true, ayuda: 'Solo cursos del periodo activo (RN-07).' }
        ] }
      ] },
      { t: 'h2', s: 'Validaciones del sistema' },
      { t: 'p', s: 'El sistema revisa cinco reglas antes de escribir nada. Si alguna falla, no se crea la matricula y el cupo no cambia.' },
      { t: 'tabla', pesos: [1, 3, 2],
        columnas: ['Regla', 'Que verifica', 'Resultado'],
        filas: [
          ['RN-07', 'Existe un periodo academico activo', { distintivo: 'Cumple', tono: 'ok' }],
          ['RN-06', 'El estudiante esta activo', { distintivo: 'Cumple', tono: 'ok' }],
          ['RN-04', 'No esta ya matriculado en este curso', { distintivo: 'Cumple', tono: 'ok' }],
          ['RN-05', 'El curso tiene cupos disponibles', { distintivo: 'Cumple, quedan 21', tono: 'ok' }],
          ['RN-14', 'No supera las 7 matriculas del periodo', { distintivo: 'Cumple, sera la 5 de 7', tono: 'alerta' }]
        ] },
      { t: 'acciones', items: [
        { etiqueta: 'Registrar matricula', tipo: 'principal', a: 'lista-clase' },
        { etiqueta: 'Cancelar', tipo: 'secundario', a: 'panel-admin' }
      ] },
      { t: 'h2', s: 'Como se ve cuando una regla falla' },
      { t: 'msg', tono: 'error', titulo: 'El curso no tiene cupos disponibles.', cuerpo: 'Matematicas I tiene 4 de 4 lugares ocupados. Amplie el cupo del curso o escoja otro grupo.' },
      { t: 'msg', tono: 'error', titulo: 'El estudiante ya esta matriculado en este curso.', cuerpo: 'Valentina Rios tiene una matricula activa en Matematicas I desde el 22 de julio.' },
      { t: 'msg', tono: 'error', titulo: 'El estudiante no esta activo.', cuerpo: 'Andres Felipe Cardona Gil figura como inactivo. Reactive su registro antes de matricularlo.' },
      { t: 'msg', tono: 'error', titulo: 'El estudiante alcanzo el tope de siete cursos.', cuerpo: 'Mateo Duque ya tiene 7 matriculas activas en el periodo. Cancele una antes de agregar otra.' },
      { t: 'msg', tono: 'error', titulo: 'No hay un periodo academico activo.', cuerpo: 'Active el periodo 2027-1 antes de registrar matriculas.' }
    ]
  },
  {
    clave: 'lista-clase', nombre: '13 Lista de clase', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: 'lista-clase',
    bloques: [
      { t: 'ruta', s: 'Panel > Listas de clase' },
      { t: 'h1', s: 'Lista de clase' },
      { t: 'msg', tono: 'exito', titulo: 'Matricula registrada correctamente.', cuerpo: 'Valentina Rios quedo inscrita en Matematicas II. El curso pasa de 20 a 21 cupos ocupados.' },
      { t: 'filtros', campos: [
        { rotulo: 'Curso', valor: 'MAT-201 Matematicas II' },
        { rotulo: 'Periodo', valor: '2026-2 (activo)' },
        { rotulo: 'Estado de la matricula', valor: 'Activas' }
      ], boton: 'Ver lista' },
      { t: 'ficha', items: [
        ['Docente titular', 'Mejia Ruiz, Carlos Andres'],
        ['Creditos', '4'],
        ['Cupo', '4 de 25 ocupados, 21 disponibles'],
        ['Cortes configurados', '3 cortes: 30 %, 30 % y 40 %']
      ] },
      { t: 'tabla', pesos: [1, 1, 2, 2, 1],
        columnas: ['#', 'Codigo', 'Estudiante', 'Fecha de matricula', 'Acciones'],
        filas: [
          ['1', 'EST-2026-003', 'Castano Loaiza, Mariana', '21 de julio de 2026', 'Cancelar'],
          ['2', 'EST-2026-008', 'Duque Sierra, Mateo Alejandro', '21 de julio de 2026', 'Cancelar'],
          ['3', 'EST-2026-010', 'Franco Zapata, Nicolas', '22 de julio de 2026', 'Cancelar'],
          ['4', 'EST-2026-002', 'Moreno Ocampo, Santiago', '22 de julio de 2026', 'Cancelar']
        ] },
      { t: 'h2', s: 'Matriculas canceladas' },
      { t: 'tabla', pesos: [1, 2, 2, 2],
        columnas: ['Codigo', 'Estudiante', 'Cancelada el', 'Motivo'],
        filas: [
          ['EST-2026-009', 'Betancur Agudelo, Laura Sofia', '5 de agosto de 2026', 'Retiro voluntario del estudiante']
        ] },
      { t: 'h2', s: 'Cuando el curso no tiene a nadie' },
      { t: 'vacio', titulo: 'Este curso todavia no tiene estudiantes matriculados.', cuerpo: 'La lista aparecera aqui en cuanto registre la primera matricula.', boton: 'Matricular un estudiante' }
    ]
  },
  {
    clave: 'panel-docente', nombre: '14 Panel docente', barra: BARRA_DOCENTE, menu: MENU_DOCENTE, activo: 'panel-docente',
    bloques: [
      { t: 'nota', s: 'Un docente solo ve los cursos que tiene asignados (RN-08).' },
      { t: 'h1', s: 'Mis cursos' },
      { t: 'p', s: 'Periodo 2026-2, segundo semestre de 2026.' },
      { t: 'msg', tono: 'aviso', titulo: 'Tiene 4 notas del corte 3 sin registrar.', cuerpo: 'El periodo no se puede cerrar hasta que esten todas.' },
      { t: 'tabla', pesos: [2, 1, 1, 1],
        columnas: ['Curso', 'Corte 1 (30 %)', 'Corte 2 (30 %)', 'Corte 3 (40 %)'],
        filas: [
          ['MAT-101 Matematicas I', { distintivo: '4 de 4', tono: 'ok' }, { distintivo: '2 de 4', tono: 'alerta' }, { distintivo: '1 de 4', tono: 'neutro' }],
          ['MAT-201 Matematicas II', { distintivo: '4 de 4', tono: 'ok' }, { distintivo: '4 de 4', tono: 'ok' }, { distintivo: '0 de 4', tono: 'neutro' }]
        ] },
      { t: 'acciones', items: [
        { etiqueta: 'Registrar notas', tipo: 'principal', a: 'calificar' },
        { etiqueta: 'Ver lista de clase', tipo: 'secundario', a: 'lista-clase' }
      ] }
    ]
  },
  {
    clave: 'calificar', nombre: '15 Registrar calificaciones', barra: BARRA_DOCENTE, menu: MENU_DOCENTE, activo: 'calificar',
    bloques: [
      { t: 'ruta', s: 'Mis cursos > Registrar notas' },
      { t: 'h1', s: 'Registrar calificaciones' },
      { t: 'filtros', campos: [
        { rotulo: 'Curso', valor: 'MAT-101 Matematicas I' },
        { rotulo: 'Corte', valor: 'Corte 2 (30 %)' },
        { rotulo: 'Periodo', valor: '2026-2 (activo)', deshabilitado: true }
      ], boton: 'Cargar lista' },
      { t: 'p', s: 'MAT-101 Matematicas I, corte 2, 4 estudiantes, 2 notas pendientes.' },
      { t: 'tabla', pesos: [1, 2, 1, 1, 1],
        columnas: ['Codigo', 'Estudiante', 'Corte 1', 'Nota del corte 2', 'Estado'],
        filas: [
          ['EST-2026-001', 'Rios Cardenas, Valentina', '4.0', '3.0', { distintivo: 'Registrada', tono: 'ok' }],
          ['EST-2026-005', 'Pineda Rojas, Camila Andrea', '3.9', '4.1', { distintivo: 'Registrada', tono: 'ok' }],
          ['EST-2026-006', 'Arango Velez, Sebastian', '2.6', { pendiente: 'Sin calificar' }, { distintivo: 'Pendiente', tono: 'neutro' }],
          ['EST-2026-007', 'Quintero Marin, Isabella', '4.7', '5.5', { distintivo: 'Fuera de rango', tono: 'error' }]
        ] },
      { t: 'msg', tono: 'error', titulo: 'No se guardo ninguna nota.', cuerpo: 'La nota de Isabella Quintero (5.5) esta fuera del rango permitido. Corrijala y vuelva a guardar: el lote se guarda completo o no se guarda.' },
      { t: 'acciones', items: [
        { etiqueta: 'Guardar notas del corte', tipo: 'principal', a: 'panel-docente' },
        { etiqueta: 'Volver a mis cursos', tipo: 'secundario', a: 'panel-docente' }
      ] },
      { t: 'h2', s: 'Al guardar correctamente' },
      { t: 'msg', tono: 'exito', titulo: 'Se registraron 4 notas del corte 2.', cuerpo: 'El sistema recalculo la definitiva de las matriculas afectadas. Quedan 4 notas pendientes del corte 3.' },
      { t: 'h2', s: 'Al corregir una nota ya registrada' },
      { t: 'msg', tono: 'aviso', titulo: 'Esta modificando una nota ya registrada.', cuerpo: 'Valentina Rios pasa de 3.0 a 3.5 en el corte 2. El cambio queda en la bitacora con su nombre y la fecha (RN-18).' },
      { t: 'h2', s: 'Cuando el periodo ya esta cerrado' },
      { t: 'msg', tono: 'error', titulo: 'El periodo 2026-1 esta cerrado.', cuerpo: 'Sus calificaciones son de solo lectura (RN-17).' }
    ]
  },
  {
    clave: 'panel-estudiante', nombre: '16 Panel estudiante', barra: BARRA_ESTUDIANTE, menu: MENU_ESTUDIANTE, activo: 'panel-estudiante',
    bloques: [
      { t: 'nota', s: 'El estudiante solo ve su propia informacion. El sistema toma su identidad de la sesion, nunca de la direccion (RN-23).' },
      { t: 'h1', s: 'Hola, Valentina' },
      { t: 'p', s: 'Periodo 2026-2, codigo EST-2026-001.' },
      { t: 'indicadores', items: [
        { cifra: '4', rotulo: 'Cursos matriculados' },
        { cifra: '13', rotulo: 'Creditos inscritos' },
        { cifra: '4.1', rotulo: 'Promedio del periodo' }
      ] },
      { t: 'msg', tono: 'info', titulo: 'El promedio solo cuenta los cursos con todas sus notas.', cuerpo: 'Por ahora solo Matematicas I esta completo. Los demas apareceran cuando el docente registre el corte que falta.' },
      { t: 'h2', s: 'Mis cursos del periodo' },
      { t: 'tabla', pesos: [1, 2, 1, 2, 2],
        columnas: ['Codigo', 'Curso', 'Creditos', 'Docente', 'Definitiva'],
        filas: [
          ['MAT-101', 'Matematicas I', '4', 'Mejia Ruiz, Carlos Andres', { distintivo: '4.1 Aprobada', tono: 'ok' }],
          ['LEN-201', 'Lengua Castellana II', '3', 'Gomez Pena, Marta Lucia', { pendiente: 'Falta el corte 3' }],
          ['CIE-101', 'Ciencias Naturales', '4', 'Salazar Torres, Jorge Ivan', { pendiente: 'Falta el corte 3' }],
          ['SIS-101', 'Tecnologia e Informatica', '2', 'Perez Mora, Diana Carolina', { pendiente: 'Falta el corte 2' }]
        ] },
      { t: 'acciones', items: [{ etiqueta: 'Ver mis notas', tipo: 'principal', a: 'mis-notas' }] },
      { t: 'h2', s: 'Si no tuviera cursos matriculados' },
      { t: 'vacio', titulo: 'Todavia no tiene cursos matriculados en el periodo 2026-2.', cuerpo: 'La matricula la registra la secretaria academica.' }
    ]
  },
  {
    clave: 'mis-notas', nombre: '17 Mis notas', barra: BARRA_ESTUDIANTE, menu: MENU_ESTUDIANTE, activo: 'mis-notas',
    bloques: [
      { t: 'ruta', s: 'Mis cursos > Mis notas' },
      { t: 'h1', s: 'Mis notas' },
      { t: 'filtros', campos: [
        { rotulo: 'Periodo', valor: '2026-2 (en curso)' },
        { rotulo: 'Curso', valor: 'Todos mis cursos' },
        { rotulo: 'Mostrar', valor: 'Detalle por corte' }
      ], boton: 'Consultar' },
      { t: 'h2', s: 'MAT-101 Matematicas I' },
      { t: 'p', s: 'Mejia Ruiz, Carlos Andres - 4 creditos' },
      { t: 'tabla', pesos: [1, 1, 1, 1],
        columnas: ['Corte', 'Peso', 'Nota', 'Aporte'],
        filas: [
          ['Corte 1', '30 %', '4.0', '1.20'],
          ['Corte 2', '30 %', '3.0', '0.90'],
          ['Corte 3', '40 %', '5.0', '2.00']
        ] },
      { t: 'msg', tono: 'exito', titulo: 'Definitiva: 4.1 - Aprobada', cuerpo: 'Se aprueba con 3.0 o mas. El resultado se presenta con un decimal.' },
      { t: 'h2', s: 'LEN-201 Lengua Castellana II' },
      { t: 'p', s: 'Gomez Pena, Marta Lucia - 3 creditos' },
      { t: 'tabla', pesos: [1, 1, 1, 1],
        columnas: ['Corte', 'Peso', 'Nota', 'Aporte'],
        filas: [
          ['Corte 1', '30 %', '4.3', '1.29'],
          ['Corte 2', '30 %', '4.0', '1.20'],
          ['Corte 3', '40 %', { pendiente: 'Pendiente' }, { pendiente: 'Sin calcular' }]
        ] },
      { t: 'nota', s: 'Un corte sin calificar aparece como Pendiente, nunca como 0.0. No son lo mismo: un cero es una nota, y pendiente significa que el docente todavia no la registro.' },
      { t: 'h2', s: 'Historial de periodos cerrados' },
      { t: 'tabla', pesos: [2, 1, 1, 1],
        columnas: ['Curso', 'Creditos', 'Definitiva', 'Resultado'],
        filas: [
          ['MAT-101 Matematicas I', '4', '4.1', { distintivo: 'Aprobada', tono: 'ok' }],
          ['LEN-101 Lengua Castellana I', '3', '4.0', { distintivo: 'Aprobada', tono: 'ok' }]
        ] },
      { t: 'h2', s: 'Aviso de riesgo academico' },
      { t: 'msg', tono: 'aviso', titulo: 'Su promedio del periodo esta por debajo de 3.0.', cuerpo: 'Asi se veria el aviso si el promedio fuera inferior al minimo.' }
    ]
  },
  {
    clave: 'estados', nombre: '18 Catalogo de mensajes', barra: BARRA_ADMIN, menu: MENU_ADMIN, activo: null,
    bloques: [
      { t: 'h1', s: 'Catalogo de mensajes del sistema' },
      { t: 'p', s: 'Es el Anexo A que exige RNF-10: todo mensaje dice la causa y la accion correctiva, en espanol y sin codigos tecnicos.' },
      { t: 'h2', s: 'Confirmacion' },
      { t: 'msg', tono: 'exito', titulo: 'Matricula registrada correctamente.', cuerpo: 'El curso pasa de 20 a 21 cupos ocupados.' },
      { t: 'msg', tono: 'exito', titulo: 'Se registraron 4 notas del corte 2.', cuerpo: 'Quedan 4 notas pendientes del corte 3.' },
      { t: 'h2', s: 'Error' },
      { t: 'msg', tono: 'error', titulo: 'El curso no tiene cupos disponibles.', cuerpo: 'Amplie el cupo o escoja otro grupo.' },
      { t: 'msg', tono: 'error', titulo: 'Usuario o contrasena incorrectos.', cuerpo: 'Verifique sus datos e intente de nuevo. Si no la recuerda, use Olvide mi contrasena.' },
      { t: 'msg', tono: 'error', titulo: 'El enlace vencio o ya se uso.', cuerpo: 'Los enlaces de restablecimiento sirven una sola vez y duran 30 minutos. Solicite uno nuevo.' },
      { t: 'msg', tono: 'error', titulo: 'Alcanzo el maximo de solicitudes.', cuerpo: 'Se pueden pedir hasta 3 enlaces por hora (RN-30). Intente de nuevo a las 14:35.' },
      { t: 'h2', s: 'Aviso' },
      { t: 'msg', tono: 'aviso', titulo: 'Matricula registrada. Alcanzo el tope de siete cursos.', cuerpo: 'No podra inscribir mas asignaturas en este periodo.' },
      { t: 'h2', s: 'Informacion' },
      { t: 'msg', tono: 'info', titulo: 'Solo puede haber un periodo activo a la vez.', cuerpo: 'Para activar 2027-1 debe cerrar antes el periodo 2026-2.' },
      { t: 'msg', tono: 'info', titulo: 'Si existe una cuenta con ese correo, le enviamos un enlace.', cuerpo: 'Responde igual exista o no la cuenta (RN-29): confirmarlo revelaria que correos estan registrados.' },
      { t: 'h2', s: 'Estado vacio' },
      { t: 'vacio', titulo: 'No se encontraron estudiantes con ese criterio.', cuerpo: 'Revise la escritura del nombre o quite algun filtro.', boton: 'Quitar filtros' },
      { t: 'h2', s: 'Errores de campo' },
      { t: 'form', campos: [
        { rotulo: 'Numero de documento', valor: '1098765401', error: 'Ya existe una persona registrada con este documento: Valentina Rios Cardenas.' },
        { rotulo: 'Nota del corte', valor: '5.5', error: 'La nota debe estar entre 0.0 y 5.0' },
        { rotulo: 'Cupo maximo', valor: '1', error: 'El cupo no puede ser menor que los 4 estudiantes ya matriculados.' }
      ] },
      { t: 'h2', s: 'Como se escriben' },
      { t: 'tabla', pesos: [2, 3, 3],
        columnas: ['Asi no', 'Asi si', 'Por que'],
        filas: [
          ['Error RN-05', 'El curso no tiene cupos disponibles', 'El usuario no conoce el catalogo de reglas'],
          ['Operacion invalida', 'El estudiante ya esta matriculado en este curso', 'Decir que fallo, no que algo fallo'],
          ['Usted ingreso mal el dato', 'La nota debe estar entre 0.0 y 5.0', 'El mensaje describe la regla, no culpa a nadie'],
          ['No se pudo completar', 'No se guardo ninguna nota. Corrija la de Isabella', 'Siempre hay un siguiente paso']
        ] }
    ]
  }
];

// ---------------------------------------------------------------------
// 7. Variables, estilos y libreria de componentes
// ---------------------------------------------------------------------
function crearVariables() {
  try {
    if (!figma.variables || !figma.variables.createVariableCollection) return 0;
    var col = figma.variables.createVariableCollection('SGA');
    var modo = col.modes[0].modeId;
    var n = 0;
    for (var nombre in COLOR) {
      if (!Object.prototype.hasOwnProperty.call(COLOR, nombre)) continue;
      var v = figma.variables.createVariable('color/' + nombre, col, 'COLOR');
      v.setValueForMode(modo, rgb(COLOR[nombre]));
      n++;
    }
    var esp = [4, 8, 12, 16, 24, 32, 48];
    for (var i = 0; i < esp.length; i++) {
      var ve = figma.variables.createVariable('espacio/e' + (i + 1), col, 'FLOAT');
      ve.setValueForMode(modo, esp[i]);
      n++;
    }
    return n;
  } catch (e) {
    return 0;
  }
}

function crearEstilos() {
  var n = 0;
  try {
    for (var nombre in COLOR) {
      if (!Object.prototype.hasOwnProperty.call(COLOR, nombre)) continue;
      var e = figma.createPaintStyle();
      e.name = 'SGA/' + nombre;
      e.paints = solido(COLOR[nombre]);
      n++;
    }
    var tipos = [
      { n: 'Titulo de pantalla', tam: 24, est: 'Bold' },
      { n: 'Titulo de seccion', tam: 18, est: 'Bold' },
      { n: 'Cuerpo', tam: 14, est: 'Regular' },
      { n: 'Tabla', tam: 12, est: 'Regular' },
      { n: 'Ayuda', tam: 12, est: 'Regular' }
    ];
    for (var i = 0; i < tipos.length; i++) {
      var te = figma.createTextStyle();
      te.name = 'SGA/' + tipos[i].n;
      te.fontName = { family: FUENTE, style: tipos[i].est };
      te.fontSize = tipos[i].tam;
      te.lineHeight = { unit: 'PERCENT', value: 150 };
      n++;
    }
  } catch (e) { /* ignorar */ }
  return n;
}

function crearLibreria() {
  var hoja = marco('00 Componentes', { fondo: COLOR.blanco });
  auto(hoja, 'VERTICAL', { pad: 40, sep: 24, cruzado: 'FIXED' });
  hoja.resize(560, 100);

  hoja.appendChild(estirar(texto('Libreria de componentes del SGA', { tam: 22, estilo: 'Bold', color: COLOR.azul900 })));

  var grupos = [
    { titulo: 'Botones', hacer: function () { return [boton('Guardar', 'principal'), boton('Cancelar', 'secundario'), boton('Inactivar', 'peligro')]; } },
    { titulo: 'Distintivos de estado', hacer: function () { return [distintivo('Activo', 'ok'), distintivo('Lleno, 100 %', 'error'), distintivo('Sin asignar', 'alerta'), distintivo('Inactivo', 'neutro')]; } }
  ];

  for (var g = 0; g < grupos.length; g++) {
    hoja.appendChild(estirar(texto(grupos[g].titulo, { tam: 14, estilo: 'Semi Bold', color: COLOR.gris700 })));
    var fila = marco(grupos[g].titulo, {});
    auto(fila, 'HORIZONTAL', { sep: 12, principal: 'FIXED', alinearCruzado: 'CENTER' });
    var piezas = grupos[g].hacer();
    for (var p = 0; p < piezas.length; p++) {
      try {
        var comp = figma.createComponent();
        comp.name = grupos[g].titulo + ' / ' + (p + 1);
        auto(comp, 'HORIZONTAL', { sep: 0 });
        comp.appendChild(piezas[p]);
        fila.appendChild(comp);
      } catch (e) {
        fila.appendChild(piezas[p]);
      }
    }
    hoja.appendChild(estirar(fila));
  }

  hoja.appendChild(estirar(texto('Mensajes', { tam: 14, estilo: 'Semi Bold', color: COLOR.gris700 })));
  var tonos = [
    ['exito', 'Matricula registrada correctamente.', 'El curso pasa de 20 a 21 cupos ocupados.'],
    ['error', 'El curso no tiene cupos disponibles.', 'Amplie el cupo o escoja otro grupo.'],
    ['aviso', 'Alcanzo el tope de siete cursos.', 'No podra inscribir mas asignaturas.'],
    ['info', 'Solo puede haber un periodo activo.', 'Cierre 2026-2 antes de activar 2027-1.']
  ];
  for (var m = 0; m < tonos.length; m++) {
    hoja.appendChild(estirar(mensaje(tonos[m][0], tonos[m][1], tonos[m][2])));
  }

  hoja.appendChild(estirar(texto('Campos de formulario', { tam: 14, estilo: 'Semi Bold', color: COLOR.gris700 })));
  hoja.appendChild(estirar(campo({ rotulo: 'Correo institucional', valor: 'valentina.rios@sga.edu.co', ayuda: 'Sera su usuario de acceso.' })));
  hoja.appendChild(estirar(campo({ rotulo: 'Nota del corte', valor: '5.5', error: 'La nota debe estar entre 0.0 y 5.0' })));

  return hoja;
}

// ---------------------------------------------------------------------
// 8. Ejecucion
// ---------------------------------------------------------------------
async function principal() {
  await figma.loadFontAsync({ family: FUENTE, style: 'Regular' });
  await figma.loadFontAsync({ family: FUENTE, style: 'Medium' });
  await figma.loadFontAsync({ family: FUENTE, style: 'Semi Bold' });
  await figma.loadFontAsync({ family: FUENTE, style: 'Bold' });

  // Cada ejecucion escribe en una pagina nueva. Asi volver a generar no duplica
  // frames sobre los anteriores y tampoco borra nada que ya estuviera en el
  // archivo: la version anterior queda en su propia pagina.
  var pagina = figma.currentPage;
  try {
    if (figma.createPage) {
      pagina = figma.createPage();
      if (figma.setCurrentPageAsync) await figma.setCurrentPageAsync(pagina);
      else figma.currentPage = pagina;
    }
  } catch (e) {
    pagina = figma.currentPage;
  }
  pagina.name = 'SGA - Prototipo Fase 5';

  var nVars = crearVariables();
  var nEstilos = crearEstilos();

  var x = 0;
  var creados = {};

  var libreria = crearLibreria();
  libreria.x = x;
  libreria.y = 0;
  pagina.appendChild(libreria);
  x += libreria.width + SEP;

  for (var i = 0; i < PANTALLAS.length; i++) {
    var def = PANTALLAS[i];
    var f = def.tipo === 'acceso' ? construirAcceso(def) : construirPantalla(def);
    f.x = x;
    f.y = 0;
    pagina.appendChild(f);
    creados[def.clave] = f;
    x += ANCHO + SEP;
  }

  // Conexiones del prototipo.
  // La forma del objeto Reaction cambio entre versiones de la API: las
  // versiones nuevas esperan "actions" en plural y las antiguas "action".
  // Se prueban las formas conocidas y se conserva la primera que el editor
  // acepte, para no depender de la version instalada.
  // La transicion es la parte animada del prototipo de Figma: al presentarlo,
  // el paso de una pantalla a otra se interpola en lugar de cortar en seco.
  var TRANSICION = {
    type: 'SMART_ANIMATE',
    easing: { type: 'EASE_OUT' },
    duration: 0.3
  };

  function formasDeReaccion(idDestino) {
    var conTransicion = {
      type: 'NODE',
      destinationId: idDestino,
      navigation: 'NAVIGATE',
      transition: TRANSICION,
      preserveScrollPosition: false
    };
    var sinTransicion = {
      type: 'NODE',
      destinationId: idDestino,
      navigation: 'NAVIGATE',
      transition: null,
      preserveScrollPosition: false
    };
    return [
      { trigger: { type: 'ON_CLICK' }, actions: [conTransicion] },
      { trigger: { type: 'ON_CLICK' }, action: conTransicion },
      { trigger: { type: 'ON_CLICK' }, actions: [sinTransicion] },
      { trigger: { type: 'ON_CLICK' }, action: sinTransicion },
      { trigger: { type: 'ON_CLICK' }, actions: [{ type: 'NODE', destinationId: idDestino, navigation: 'NAVIGATE' }] }
    ];
  }

  async function aplicarReaccion(nodo, idDestino) {
    var formas = formasDeReaccion(idDestino);
    var ultimoError = null;
    for (var k = 0; k < formas.length; k++) {
      try {
        if (nodo.setReactionsAsync) await nodo.setReactionsAsync([formas[k]]);
        else nodo.reactions = [formas[k]];
        return { ok: true, forma: k + 1 };
      } catch (err) {
        ultimoError = err;
      }
    }
    return { ok: false, error: ultimoError ? ultimoError.message : 'desconocido' };
  }

  var hechas = 0;
  var formaUsada = 0;
  var primerError = '';
  for (var e = 0; e < enlaces.length; e++) {
    var destino = creados[enlaces[e].destino];
    if (!destino) continue;
    var r = await aplicarReaccion(enlaces[e].nodo, destino.id);
    if (r.ok) {
      hechas++;
      formaUsada = r.forma;
    } else if (!primerError) {
      primerError = r.error;
    }
  }

  // Punto de partida del prototipo
  try {
    if (creados['acceso']) {
      pagina.flowStartingPoints = [{ nodeId: creados['acceso'].id, name: 'Acceso al SGA' }];
    }
  } catch (e) { /* ignorar */ }

  figma.viewport.scrollAndZoomIntoView(pagina.children);

  var resumen = 'Prototipo del SGA generado: ' + PANTALLAS.length + ' pantallas, ' +
    hechas + ' de ' + enlaces.length + ' conexiones, ' + nEstilos + ' estilos y ' +
    nVars + ' variables.';
  if (hechas > 0) resumen += ' Forma de reaccion ' + formaUsada + '.';
  if (hechas < enlaces.length && primerError) resumen += ' Fallo: ' + primerError;

  figma.closePlugin(resumen);
}

principal().catch(function (e) {
  figma.closePlugin('Error al generar: ' + e.message);
});
