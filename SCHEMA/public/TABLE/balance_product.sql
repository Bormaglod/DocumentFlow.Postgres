CREATE TABLE public.balance_product (
)
INHERITS (public.balance);

ALTER TABLE ONLY public.balance_product ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.balance_product ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.balance_product ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.balance_product ALTER COLUMN operation_summa SET DEFAULT 0;

ALTER TABLE public.balance_product OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.balance_product TO users;
GRANT SELECT ON TABLE public.balance_product TO managers;
