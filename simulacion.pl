:-include(comportamiento).
:-include(metricas).
% main:-
%   \+crea_mundo_prueba,
%   crea_el_tiempo.%,
%   % guitracer.
main:-
  % spy(asignar_todas_recreativas),
  % guitracer,trace,
  crea_medellin,
  crea_el_tiempo.

:-dynamic
  ciclo_actual/1,
  panico/1.

%%%%%%%%
% UTIL %
%%%%%%%%
numero_muertes_dia(Num,Dia):-
  Ciclo is Dia * 24,
  findall(X,persona(X,_,_,_,_,_,Ciclo),Muertes),
  Muertes = [],!,
  Num is 0.
numero_muertes_dia(Num,Dia):-
  Ciclo is Dia * 24,
  findall(X,persona(X,_,_,_,_,_,Ciclo),Muertes),
  length(Muertes,Num).

%%%%%%%%%%
% TIEMPO %
%%%%%%%%%%
crea_el_tiempo:-
  assert(ciclo_actual(0)),
  assert(panico(null)).
avanza_el_tiempo:-
  ciclo_actual(Pasado),
  Presente is Pasado + 1,
  retractall(ciclo_actual(_)),
  assert(ciclo_actual(Presente)).
dia_hora_actual(Dia,Hora):-
  ciclo_actual(Presente),
  Hora is Presente mod 24,
  Dia is div(div(Presente,24),7).

%%%%%%%%%%
% PANICO %
%%%%%%%%%%
is_it_time_to_panic(true):-
  all_reasons_to_panic(Reasons),
  length(Reasons,Num),
  poblacion_inicial(Pob),
  % 5% de la poblacion
  Threshold is Pob*0.05,
  Num > Threshold,!.
is_it_time_to_panic(false).

change_panic(Panic):-
  panico(Panic),!.
change_panic(Panic):-
  retractall(panico(_)),
  assert(panico(Panic)),!.

cicla_panico_dia:-
  panico(null),
  is_it_time_to_panic(X),X=false,!.
cicla_panico_dia:-
  panico(null),
  is_it_time_to_panic(true),
  change_panic(1),!.
cicla_panico_dia:-
  panico(Panic),
  NewPanic is Panic + 1,
  change_panic(NewPanic),!.

p_personas_concientes(0):-
  panico(null),!.
p_personas_concientes(P):-
  panico(Dias),
  0<Dias,Dias < 27,!,
  logistic_personas_concientes(Dias,P).
p_personas_concientes(P):-
  panico(Dias),
  Dias > 26,!,
  D1 is Dias - 40,
  logistic_personas_concientes(D1,P1),
  P is 1-P1.
p_personas_concientes(0).

b(0.740818220682).
logistic_personas_concientes(Dias,P_personas_concientes):-
  b(B),
  P_personas_concientes is 1 / (1 + 8*(B**Dias)).

quita_charcos_por_panico:-
  p_personas_concientes(P_cons),
  %hasta 20-40% de los charcos en un dia
  random(0,2.4,R),P is R * P_cons,
  findall(C,agua_var(C,_,_,_),Charcos),
  length(Charcos,Lch),NumAQuitar is floor(Lch * P),
  random_permutation(Charcos,Charcos_permute),
  quita_muchos_charcos(Charcos_permute,NumAQuitar).

mata_moyotes_por_panico:-
  % mueren hasta 10-30% por panico
  p_personas_concientes(P_cons),
  random(0.1,0.3,R),P is R * P_cons,
  findall(M,moyote(M,_,_,_,_),Moyotes),
  length(Moyotes,Lch),NumAQuitar is floor(Lch * P),
  random_permutation(Moyotes,Moyotes_permute),
  quita_muchos_moyotes(Moyotes_permute,NumAQuitar).

quita_muchos_charcos([Charco|Otros],N):-
  N>0,!,
  elimina_agua_var(Charco),
  M is N-1,
  quita_muchos_charcos(Otros,M).
quita_muchos_charcos([],_):-!.
quita_muchos_charcos(_,0):-!.

quita_muchos_moyotes([Moyo|Otros],N):-
  N>0,!,
  mata_moyote(Moyo),
  M is N-1,
  quita_muchos_moyotes(Otros,M).
quita_muchos_moyotes([],_):-!.
quita_muchos_moyotes(_,0):-!.
%%%%%%%%%%
% CICLOS %
%%%%%%%%%%
ciclar_mundo_n_veces(N):-
  N > 0,
  ciclar_mundo,
  M is N-1,
  ciclar_mundo_n_veces(M).
ciclar_mundo_n_veces(0).
ciclar_mundo:-
  dia_hora_actual(Dia,Hora),
  % ciclo_actual(Presente),
  % write('Ciclo #'),writeln(Presente),
  % writeln('------------------'),
  %ciclar entidades
  ciclar_todos_los_moyotes(Hora),
  ciclar_todas_las_personas(Dia,Hora),
  avanza_el_tiempo.
ciclar_mundo_muchos_dias(0):-!.
ciclar_mundo_muchos_dias(N):-
  ciclar_mundo_dia,
  M is N-1,
  ciclar_mundo_muchos_dias(M).
ciclar_mundo_dia:-
  avanza_embarazamiento_de_moyotes_dia,
  ciclar_todos_los_huevos_dia,
  ciclo_del_agua_dia,
  hospitalizar_personas_dia(_NumHospitalizados),
  matar_personas_dia,
  mata_moyotes_por_panico,
  quita_charcos_por_panico,
  ciclo_actual(Presente),
  Dia is div(Presente, 24),
  % numero_muertes_dia(_NumMuertes,Dia),

  cicla_panico_dia,
  p_personas_concientes(Panic),

  % tell(user),
  crea_nombre_archivo(Dia,1,NomFile),
  tell(NomFile),
  write('Dia #'),writeln(Dia),
  writeln('------------------'),
  write('Panico: '),writeln(Panic),
  % write('Hospitalizaciones hoy: '),writeln(NumHospitalizados),
  % write('Muertes hoy: '),writeln(NumMuertes),
  write('Reporte Diario: '),nl,
  writeln('------------------'),
  reporte_diario,
  write('Metricas Totales: '),nl,
  writeln('------------------'),
  metricas_totales,

  write('Metricas Areas: '),nl,
  writeln('------------------'),
  metricas_areas,
  told,

  ciclar_mundo_n_veces(24).
crea_nombre_archivo(Dia,FolioSim,NomFile):-
  atom_string(Dia,StrDia),
  %root
  atom_string('sim/',Sim),
  %sim
  atom_string(FolioSim,StrFolioSim),
  atom_string('_',S1),

  string_concat(Sim,StrFolioSim,S2),
  string_concat(S2,S1,S3),

  string_concat(S3,StrDia,File),
  atom_string(NomFile,File).

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COSAS DE TODOS LOS DIAS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

hospitalizar_personas_dia(NumAHospitalizar):-
  panico(null),!,
  personas_sintomaticas(Enfermitos),
  separar_enfermos_hosp(Enfermitos,_,NoHosp),
  length(NoHosp,NumEnf),
  % porcentaje que va al hospital:
  numero_aleatorio_entre(0.1,0.35,P1),
  % P1 is 0.5,
  NumAHospitalizar is floor(NumEnf * P1),
  random_permutation(NoHosp,Enfermitos_permutados),
  hospitalizar_primeros_n_enfermitos(Enfermitos_permutados,NumAHospitalizar).
hospitalizar_personas_dia(NumAHospitalizar):-
  p_personas_concientes(X),!,0=<X,!,
  personas_sintomaticas(Enfermitos),
  separar_enfermos_hosp(Enfermitos,_,NoHosp),
  length(NoHosp,NumEnf),
  % porcentaje que va al hospital:
  numero_aleatorio_entre(0.80,0.90,P1),
  % * X por que solo X% de la gente sabe de la enfermedad
  NumAHospitalizar is floor(min(0.4,P1 * X) * NumEnf ),
  random_permutation(NoHosp,Enfermitos_permutados),
  hospitalizar_primeros_n_enfermitos(Enfermitos_permutados,NumAHospitalizar).
hospitalizar_primeros_n_enfermitos(_,0):-!.
hospitalizar_primeros_n_enfermitos([Hospitalizado|Enfermitos],N):-
  hospitalizar_persona(Hospitalizado),
  M is N-1,
  hospitalizar_primeros_n_enfermitos(Enfermitos,M).
matar_personas_dia:-
  personas_sintomaticas(Enfermitos),
  separar_enfermos_hosp(Enfermitos,Hospitalizados,NoHospitalizados),
  intenta_matar_hosp(Hospitalizados),
  intenta_matar_no_hosp(NoHospitalizados).
intenta_matar_hosp([]).
intenta_matar_hosp([Enf1|Enfermos]):-
  findall(Tipo,infeccion_persona(Enf1,Tipo,_,_,_,_,_,_),Infecciones),
  length(Infecciones,1),!,
  % una sepa es 0-10% o 0-5% mortandad
  numero_aleatorio_entre(0,0.1,P),
  ((tira_moneda(P),!,
  ciclo_actual(Presente),
  matar_persona(Enf1,Presente));
  (true)),
  intenta_matar_hosp(Enfermos).
intenta_matar_hosp([Enf1|Enfermos]):-
  % mas de una sepa => 40-60% mortalidad
  numero_aleatorio_entre(0.4,0.6,P),
  ((tira_moneda(P),!,
  ciclo_actual(Presente),
  matar_persona(Enf1,Presente));
  (true)),
  intenta_matar_no_hosp(Enfermos).
intenta_matar_no_hosp([]).
intenta_matar_no_hosp([Enf1|Enfermos]):-
  findall(Tipo,infeccion_persona(Enf1,Tipo,_,_,_,_,_,_),Infecciones),
  length(Infecciones,1),!,
  % una sepa es 0-10% o 0-5% mortandad
  numero_aleatorio_entre(0.1,0.3,P),
  ((tira_moneda(P),!,
  ciclo_actual(Presente),
  matar_persona(Enf1,Presente));
  (true)),
  intenta_matar_no_hosp(Enfermos).
intenta_matar_no_hosp([Enf1|Enfermos]):-
  % mas de una sepa => 40-60% mortalidad
  numero_aleatorio_entre(0.90,1,P),
  ((tira_moneda(P),!,
  ciclo_actual(Presente),
  matar_persona(Enf1,Presente));
  (true)),
  intenta_matar_no_hosp(Enfermos).

separar_enfermos_hosp([E1|Enfermos],[E1|Hosp],NoHosp):-
  persona(E1,_,_,_,_,true,_),!,
  separar_enfermos_hosp(Enfermos,Hosp,NoHosp).
separar_enfermos_hosp([E1|Enfermos],Hosp,[E1|NoHosp]):-
  separar_enfermos_hosp(Enfermos,Hosp,NoHosp).
separar_enfermos_hosp([],[],[]).


:-main.
