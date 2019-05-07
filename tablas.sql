create table area
(
	folio INTEGER not null
		constraint area_pk
			primary key,
	constate_encharcamiento INTEGER not null
);

create table agua_const
(
	folio INTEGER not null
		constraint agua_const_pk
			primary key,
	folio_area INTEGER not null
		references area
);

create table agua_var
(
	folio INTEGER not null
		constraint agua_var_pk
			primary key autoincrement,
	folio_area INTEGER not null
		references area,
	tipo TEXT not null,
	capacidad_huevos INTEGER default 500 not null,
	porcentaje_vaciado REAL default 2.0 not null
);

create table agua_var_unsafe
(
	folio_agua_var INTEGER not null
		constraint agua_var_unsafe_pk
			primary key
		references agua_var
);

create table areas_vecinas
(
	folio_area_1 INTEGER not null
		references area,
	folio_area_2 INTEGER not null
		constraint areas_vecinas_pk
			primary key
		references area
);

create table bulto_huevos
(
	folio INTEGER not null
		constraint bulto_huevos_pk
			primary key autoincrement,
	folio_agua INTEGER not null
		references agua_const,
	tipo_agua text default "const/var",
	cant_huevos INTEGER default 150,
	ciclos_hasta_eclosion INTEGER default null,
	tipo_infeccion INTEGER default -1,
	"_folio_agua" integer
		references agua_var
);

create table cant_agua_var
(
	folio_agua_var INTEGER not null
		constraint cant_agua_var_pk
			primary key
		references agua_var,
	cant_agua real default 0.1 not null
);

create table folios
(
	folio_agua_var INTEGER,
	folio_persona INTEGER,
	folio_moyote INTEGER,
	folio_bultos INTEGER
);

create table moyote
(
	folio INTEGER not null
		constraint moyote_pk
			primary key autoincrement,
	area_hogar INTEGER not null
		references area,
	fecha_nacimiento INTEGER not null,
	ciclos_de_vida INTEGER default 50000 not null,
	tipo_infeccion INTEGER default 0
);

create table infeccion_moyote
(
	folio_moyote INTEGER not null
		constraint infeccion_moyote_pk
			primary key
		references moyote,
	fecha_fin_incubacion INTEGER not null,
	sepa INTEGER default 1
);

create table persona
(
	folio INTEGER not null
		constraint persona_pk
			primary key autoincrement,
	area_hogar INTEGER not null
		references area,
	area_trabajo INTEGER not null
		references area,
	hora_entrada INTEGER,
	hora_salida INTEGER,
	"hospitalizado?" TEXT default null
);

create table infeccion_persona
(
	folio_persona INTEGER
		constraint infeccion_persona_pk
			primary key
		references persona,
	tipo INTEGER default 1,
	fecha_piquete INTEGER,
	fecha_fin_incubacion INTEGER default 300000,
	fecha_fin_contagio INTEGER,
	fecha_ini_sintomas INTEGER,
	fecha_fin_sintomas INTEGER
);

create table persona_area
(
	folio_persona INTEGER not null
		references persona,
	folio_area INTEGER not null
		constraint persona_area_pk
			primary key
		references area
);

create table tanque_moyote
(
	folio_moyote INTEGER not null
		constraint tanque_moyote_pk
			primary key
		references moyote,
	porcentaje_lleno REAL default 0.01
);

