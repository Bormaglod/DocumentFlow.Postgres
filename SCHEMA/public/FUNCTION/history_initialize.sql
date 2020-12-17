CREATE OR REPLACE FUNCTION public.history_initialize() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.changed = current_timestamp;
  return new;
end;
$$;

ALTER FUNCTION public.history_initialize() OWNER TO postgres;
