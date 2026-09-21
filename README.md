# 💍 Nupcia

Planeador de boda colaborativo, en tiempo real, para dos personas (y ayudantes en modo solo lectura). Todo en español.

Una sola página (`index.html`), JavaScript sin framework ni build, con **Supabase** (Postgres + Realtime) como respaldo y sincronización. Es una PWA instalable que abre incluso sin conexión.

## Qué incluye

| Pestaña | Para qué sirve |
|---|---|
| **Resumen** | Cuenta regresiva y tarjetas de tareas, presupuesto, invitados y participantes (cada una lleva a su pestaña). |
| **Presupuesto** | Ahorro, tarjetas de crédito (deuda que se descuenta del ahorro), presupuesto de la boda con lo abonado y lo donado, gráficas de cobertura con varias vistas y **Gastos de la casa** por separado, con un switch "Incluir" por renglón. Muestra "Por abonar" y el excedente que pasa a la casa. |
| **Invitados** | Una fila por invitación (familia) con grupo, pases y confirmación. Enlace personal por invitación, envío por WhatsApp, marca de "enviado", cuenta de días para el cierre del RSVP y los mensajes que dejan al confirmar. |
| **Lista de invitados** | Personas ya confirmadas con su grupo e invitación; filtro por varios grupos, orden por columna y búsqueda sin acentos. |
| **Mesas** | Se sientan solas por grupo al confirmar (familias juntas, máximo de lugares editable en Ajustes). Plano o lista, secciones plegables por grupo, filtros, búsqueda «¿Dónde está…?» con «mover a…», mover familias completas, archivar mesas terminadas, «Agrupar por optimización de espacio» (con vista previa), «Reagrupar por grupos» e imprimir. Botón **Guardar** con confirmación. |
| **Tareas** | Por etapas, con fecha, responsable (novio, novia o ambos) y filtros. |
| **Cronograma** | Momentos del día con "puntos" anidados que se reordenan arrastrando (mouse o dedo). |
| **Participantes / Proveedores / Notas** | Padrinos y roles, proveedores con costo y estado, y notas libres. |
| **Ajustes** | Datos de la boda, cierre del RSVP, PIN, enlaces para compartir, clave de sincronización y respaldos. |

## Cómo funciona

- **Datos:** todo el planeador vive en un solo `jsonb` (tabla `espacios`, fila `nupcia-principal`) y se sincroniza por Realtime entre dispositivos. Las confirmaciones de la invitación web van en su propia tabla, `confirmaciones`.
- **Escritura protegida:** guardar exige una **clave de sincronización** que vive solo en cada dispositivo (localStorage) y nunca en el repositorio. La escritura pasa por la función `guardar_espacio`, que además archiva la versión anterior en un historial del servidor. Si un dispositivo no tiene la clave, un banner rojo avisa que los cambios no se están guardando.
- **RSVP:** cada invitación tiene un `token`; el enlace lleva a un sitio de invitación aparte, que consulta y guarda con las funciones `rsvp_lookup`, `rsvp_confirm` y `rsvp_deadline`. La fecha límite se define en Ajustes y la invitación la lee de ahí. Al llegar una confirmación, Nupcia crea las personas y las sienta.
- **Ediciones simultáneas:** al recibir cambios de otro dispositivo, las listas (cronograma, tareas, invitados y presupuesto) se **combinan por `id`** en vez de reemplazarse, para que lo agregado casi al mismo tiempo no se pierda. Si dos personas editan el *mismo* elemento a la vez, gana el último en guardar.
- **Respaldos:** copias automáticas locales (las últimas 5), descarga y restauración de `.json` desde Ajustes.
- **Vista de colaborador:** `?vista=colaborador` muestra solo la lista de invitados, mesas y cronograma, en solo lectura y sin el ahorro; `?vista=completa` la quita en ese dispositivo.

## Seguridad, en corto

- La URL y la **anon key** de Supabase están en `index.html` a propósito (la anon key es pública por diseño). Con esa clave **cualquiera puede leer** la tabla `espacios`, así que la lectura es abierta; lo que no se puede sin la clave de sincronización es escribir.
- La vista de colaborador y el PIN son restricciones de interfaz, no de seguridad: sirven para uso casual, no para proteger información sensible.
- La clave de sincronización y los scripts SQL que la contienen **no** se suben al repositorio.

## Archivos

- `index.html` — la aplicación completa.
- `sw.js` — service worker (network-first). Sube el número de `CACHE` en cada despliegue para forzar la actualización en móviles.
- `manifest.json`, `icon.svg` — PWA.
- `netlify.toml` — cabeceras de seguridad para Netlify.
- `diagnostico_historial.sql` — funciones de solo lectura (solo conteos, sin datos personales) para revisar el historial de guardados.
- `boda.html` — versión offline antigua (localStorage), sin sincronización; se conserva solo como respaldo.

## Despliegue

Sitio estático en Netlify conectado a la rama `main`: cada `git push` publica. Cada cambio de `index.html` debe acompañarse de subir el número de `CACHE` en `sw.js`.
