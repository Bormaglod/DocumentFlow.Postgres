CREATE TYPE public.contract_type AS ENUM (
	'purchase',
	'sale'
);

ALTER TYPE public.contract_type OWNER TO postgres;

COMMENT ON TYPE public.contract_type IS 'purchase - the purchase agreement (договор покупки)
sale - the contract of sale (договор продажи)';
