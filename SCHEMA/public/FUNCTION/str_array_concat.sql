CREATE OR REPLACE FUNCTION public.str_array_concat(left_array character varying[], right_array integer[], delimiter_str character varying = ' '::character varying, max_dim integer = NULL::integer) RETURNS character varying[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
	return str_array_concat(left_array, array_replace(right_array, 0, null)::varchar[], delimiter_str, max_dim);
end;
$$;

ALTER FUNCTION public.str_array_concat(left_array character varying[], right_array integer[], delimiter_str character varying, max_dim integer) OWNER TO postgres;

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.str_array_concat(left_array character varying[], right_array character varying[], delimiter_str character varying = ' '::character varying, max_dim integer = NULL::integer) RETURNS character varying[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
	res varchar[];
	i integer;
	val varchar;
begin
	if (max_dim is null) then
		max_dim := array_length(left_array, 1);
		if (max_dim < array_length(right_array, 1)) then
			max_dim := array_length(right_array, 1);
		end if;
	end if;

	for i in 1..max_dim loop
		val = coalesce(left_array[i], right_array[i]);
		if (val is null) then
			res[i] = '';
		elsif (left_array[i] is not null and right_array[i] is not null) then
			res[i] := coalesce(left_array[i], '') || delimiter_str || coalesce(right_array[i], '');
		else
			res[i] := val;
		end if;
	end loop;

	return res;
end;
$$;

ALTER FUNCTION public.str_array_concat(left_array character varying[], right_array character varying[], delimiter_str character varying, max_dim integer) OWNER TO postgres;
