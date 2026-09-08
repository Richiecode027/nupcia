-- ════════════════════════════════════════════════════════════════
--  Nupcia · Diagnóstico de historial (solo lectura, sin datos personales)
--  Ejecuta este script UNA vez en Supabase:
--  Proyecto pbjthkfiuapwnmwhlrxp → SQL Editor → New query → pega y "Run".
--
--  Qué hace: crea una función que devuelve SOLO conteos y fechas de cada
--  versión guardada (nunca nombres, montos ni contenido) — para que pueda
--  ver desde el chat en qué momento exacto se perdieron datos, sin
--  necesitar que copies y pegues resultados de SQL cada vez.
-- ════════════════════════════════════════════════════════════════

create or replace function public.debug_espacios_history(p_limit int default 30)
returns table(
  saved_at      timestamptz,
  n_guests      int,
  n_people      int,
  n_tasks       int,
  n_budget      int,
  n_house       int,
  n_credit      int,
  n_savings     int,
  n_schedule    int,
  n_points      int,
  data_ts       bigint,
  by_device     text
)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
  select
    h.saved_at,
    jsonb_array_length(coalesce(h.data->'guests','[]'::jsonb)),
    jsonb_array_length(coalesce(h.data->'people','[]'::jsonb)),
    jsonb_array_length(coalesce(h.data->'tasks','[]'::jsonb)),
    jsonb_array_length(coalesce(h.data->'budget','[]'::jsonb)),
    jsonb_array_length(coalesce(h.data->'houseExpenses','[]'::jsonb)),
    jsonb_array_length(coalesce(h.data->'creditCards','[]'::jsonb)),
    jsonb_array_length(coalesce(h.data->'savings','[]'::jsonb)),
    jsonb_array_length(coalesce(h.data->'schedule','[]'::jsonb)),
    (select coalesce(sum(jsonb_array_length(coalesce(mom->'children','[]'::jsonb))),0)::int
       from jsonb_array_elements(coalesce(h.data->'schedule','[]'::jsonb)) mom),
    (h.data->>'_ts')::bigint,
    h.data->>'_by'
  from public.espacios_history h
  where h.espacio_id = 'nupcia-principal'
  order by h.saved_at desc
  limit p_limit;
end;
$$;

grant execute on function public.debug_espacios_history(int) to anon;

-- También la versión ACTUAL (la que está viva ahora mismo), para comparar:
create or replace function public.debug_espacios_actual()
returns table(
  n_guests int, n_people int, n_tasks int, n_budget int, n_house int,
  n_credit int, n_savings int, n_schedule int, n_points int,
  data_ts bigint, by_device text, updated_at timestamptz
)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
  select
    jsonb_array_length(coalesce(e.data->'guests','[]'::jsonb)),
    jsonb_array_length(coalesce(e.data->'people','[]'::jsonb)),
    jsonb_array_length(coalesce(e.data->'tasks','[]'::jsonb)),
    jsonb_array_length(coalesce(e.data->'budget','[]'::jsonb)),
    jsonb_array_length(coalesce(e.data->'houseExpenses','[]'::jsonb)),
    jsonb_array_length(coalesce(e.data->'creditCards','[]'::jsonb)),
    jsonb_array_length(coalesce(e.data->'savings','[]'::jsonb)),
    jsonb_array_length(coalesce(e.data->'schedule','[]'::jsonb)),
    (select coalesce(sum(jsonb_array_length(coalesce(mom->'children','[]'::jsonb))),0)::int
       from jsonb_array_elements(coalesce(e.data->'schedule','[]'::jsonb)) mom),
    (e.data->>'_ts')::bigint,
    e.data->>'_by',
    e.updated_at
  from public.espacios e
  where e.id = 'nupcia-principal';
end;
$$;

grant execute on function public.debug_espacios_actual() to anon;
