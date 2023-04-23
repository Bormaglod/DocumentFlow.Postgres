CREATE OR REPLACE FUNCTION public.contractor_test_inn(inn numeric) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
   inn_arr integer[];
   k integer[] := '{ 2, 4, 10, 3, 5, 9, 4, 6, 8 }';
   k1 integer[] := '{ 7, 2, 4, 10, 3, 5, 9, 4, 6, 8 }';
   k2 integer[] := '{3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8 }';
begin
   inn_arr := string_to_array(inn::character varying, NULL)::integer[];

   -- Проверка контрольного числа
   if (array_length(inn_arr, 1) = 10) then
      /* 
       * 10-значный ИНН
       * 
       * 1. Вычислить сумму произведений цифр ИНН (с 1-й по 9-ю)
       * 2. Вычислить остаток от деления полученной суммы на 11
       * 3. Сравнить младший разряд полученного остатка от деления с младшим разрядом ИНН. Если они равны, то ИНН верный
       */
      return control_value(inn_arr, k, 11) = inn_arr[10];
   elsif (array_length(inn_arr, 1) = 12) then
      /*
       * 12-значный ИНН
       * 
       * 1. Вычислить 1-ю контрольную цифру
       * 1.1. Вычислить сумму произведений цифр ИНН (с 1-й по 10-ю)
       * 1.2. Вычислить младший разряд остатка от деления полученной суммы на 11
       * 2. Вычислить 2-ю контрольную цифру
       * 2.1. Вычислить сумму произведений цифр ИНН (с 1-й по 11-ю)
       * 2.2. Вычислить младший разряд остатка от деления полученной суммы на 11
       * 3. Сравнить 1-ю контрольную цифру с 11-й цифрой ИНН и сравнить 2-ю контрольную цифру с 12-й цифрой ИНН. Если они равны, то ИНН верный
       */
      return (control_value(inn_arr, k1, 11) = inn_arr[11]) and (control_value(inn_arr, k2, 11) = inn_arr[12]);
   else
      raise notice 'Неверная длина ИНН: %', array_length(inn_arr, 1);
      return false;
   end if;
  
   raise notice 'Неверное контрольное число';
  
   return false;
end;
$$;

ALTER FUNCTION public.contractor_test_inn(inn numeric) OWNER TO postgres;
