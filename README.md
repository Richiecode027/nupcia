# 💍 Nupcia

Planeador de boda con sincronización en tiempo real para dos personas.

- **Resumen** con cuenta regresiva, presupuesto, invitados y proveedores.
- **Presupuesto** (estimado / real / pagado).
- **Invitados** con confirmaciones (RSVP) y mesas.
- **Tareas** por etapas, ya precargadas.
- **Proveedores** y **Notas**.

## Tecnología
Una sola página (`index.html`) que usa **Supabase** (Postgres + Realtime) para guardar
y sincronizar los datos en vivo entre los dispositivos de la pareja.

## Cómo se usa
1. Abre la web publicada.
2. La primera vez, pega tu **Project URL** y **anon public key** de Supabase y conéctate.
3. Comparte el enlace de **Ajustes → Conectar a mi pareja**; al abrirlo queda sincronizada.

> Nota: las claves de Supabase NO están en este repositorio. Se introducen al usar la app
> y se guardan solo en el navegador / en el enlace que compartes.
