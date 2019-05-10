:-include(comportamiento).
:-include(metricas).
main:-
  \+crea_mundo,
  crea_el_tiempo.%,
  % guitracer.

:-dynamic
  ciclo_actual/1,
  panico/1.

%%%%%%%%
% UTIL %
%%%%%%%%
numero_muertos(Num):-
  findall(X,persona_muerta(X),Muertas),
  length(Muertas,Num).
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
  assert(panico(false)).
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
ciclar_mundo_dia:-
  avanza_embarazamiento_de_moyotes_dia,
  ciclar_todos_los_huevos_dia,
  ciclo_del_agua_dia,
  hospitalizar_personas_dia(NumHospitalizados),
  matar_personas_dia,
  ciclo_actual(Presente),
  Dia is div(Presente, 24),
  numero_muertes_dia(NumMuertes,Dia),

  is_it_time_to_panic(Panic),
  change_panic(Panic),

  write('Dia #'),writeln(Dia),
  writeln('------------------'),
  write('Panico: '),writeln(Panic),
  write('Hospitalizaciones hoy: '),writeln(NumHospitalizados),
  write('Muertes hoy: '),writeln(NumMuertes),

  ciclar_mundo_n_veces(24).

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COSAS DE TODOS LOS DIAS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

hospitalizar_personas_dia(NumAHospitalizar):-
  panico(true),!,
  personas_sintomaticas(Enfermitos),
  separar_enfermos_hosp(Enfermitos,_,NoHosp),
  length(NoHosp,NumEnf),
  % porcentaje que va al hospital:
  % numero_aleatorio_entre(0.60,0.80,P1),
  numero_aleatorio_entre(0.70,0.90,P1),
  NumAHospitalizar is floor(NumEnf * P1),
  random_permutation(NoHosp,Enfermitos_permutados),
  hospitalizar_primeros_n_enfermitos(Enfermitos_permutados,NumAHospitalizar).
hospitalizar_personas_dia(NumAHospitalizar):-
  panico(false),
  personas_sintomaticas(Enfermitos),
  separar_enfermos_hosp(Enfermitos,_,NoHosp),
  length(NoHosp,NumEnf),
  % porcentaje que va al hospital:
  % numero_aleatorio_entre(0.01,0.02,P1),
  P1 is 0.5,
  NumAHospitalizar is floor(NumEnf * P1),
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
