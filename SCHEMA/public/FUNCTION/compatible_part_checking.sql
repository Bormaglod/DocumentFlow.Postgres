CREATE OR REPLACE FUNCTION public.compatible_part_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	mat_kind material_kind;
	comp_kind material_kind;
begin
	if (TG_OP = 'UPDATE') then
		if (new.owner_id != old.owner_id) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Некорректное значение owner_id.');
		end if;
	end if;

	select material_kind into mat_kind from material where id = new.owner_id;
	select material_kind into comp_kind from material where id = new.compatible_id;

	if (mat_kind = 'terminal'::material_kind) then
		if (comp_kind not in ('housing'::material_kind, 'undefined'::material_kind)) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Совместимая деталь должна быть колодкой.');
		end if;
	elsif (mat_kind = 'housing'::material_kind) then
		if (comp_kind not in ('terminal'::material_kind, 'seal'::material_kind, 'undefined'::material_kind)) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Совместимая деталь должна быть контактом или уплотнителем.');
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.compatible_part_checking() OWNER TO postgres;
