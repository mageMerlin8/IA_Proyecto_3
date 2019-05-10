:-include(datos_prueba).
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

% A < B plox
numero_aleatorio_entre(A,B,Resp):-
  random(C),
  Diff is B-A,
  Resp is A + (Diff*C).
% tira_moneda(chance_of_success)
tira_moneda(P):-
  random(P1),
  P1<P,!;
  false.
numero_mayor_o_igual_a_lista(Num,[N1|Ls]):-
  N1 =< Num,
  numero_mayor_o_igual_a_lista(Num,Ls).
numero_mayor_o_igual_a_lista(_,[]).
area_no_vacia(Area):-
  persona_area(_,Area),!.
persona_aleatoria_area(Area,Personita):-
  findall(X,persona_area(X,Area),Personas),
  \+(Personas = []),!,
  length(Personas,TotPersonas),
  numero_aleatorio_entre(0,TotPersonas,T),
  Ti is floor(T),
  nth0(Ti,Personas,Personita).
persona_aleatoria_area(_,-1).
poblacion_inicial(Num):-
  findall(Z,persona(Z,_,_,_,_,_,_),Pob),
  length(Pob,Num).
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
aguas_con_cupo_area(Area,Aguas):-
  findall(X,agua_con_cupo_area(X,Area),Aguas).
agua_con_cupo_area(Agua,Area):-
  agua_var(Agua,Area,_,_),
  cupo_huevos_agua(Agua,H),H>0.
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
%%%%%%%%%%%%
% PERSONAS %
%%%%%%%%%%%%

decision_persona(Dia,Hora,_,H_S,go_home):-
  Dia < 5,
  Hora = H_S.
decision_persona(Dia,Hora,H_E,_,go_work):-
  Dia < 5,
  Hora = H_E.
decision_persona(Dia,Hora,H_E,H_S,stay_work):-
  Dia < 5,
  Hora > H_E,
  Hora < H_S.
decision_persona(Dia,Hora,H_E,H_S,home_for_the_day):-
  (Dia < 5, Hora < H_E,!);
  (Dia < 5, Hora > H_S,!);
  (Dia > 5, Hora > 22, Hora < 9).
decision_persona(_,_,_,_,rec_time).

% persona_actua(folio, a_h, a_t, h_e, h_s, hosp, Dia, Hora)
% decide salirse cuando se cura, no hace nada de otra manera
persona_actua(Persona,_,_,_,_,true,_,_):-
  persona_sana(Persona),!,
  deshospitalizar_persona(Persona).
persona_actua(_,_,_,_,_,true,_,_):-!.

% persona_actua(folio, a_h, a_t, h_e, h_s, hosp, Dia, Hora)
% go_home
persona_actua(Persona,A_H,_,_,H_S,false,Dia,Hora):-
  decision_persona(Dia,Hora,_,H_S,go_home),!,
  % write('Persona #'),write(Persona),writeln(' va a casa'),
  mover_persona(Persona,A_H).
% go_work
persona_actua(Persona,_,A_T,H_E,_,false,Dia,Hora):-
  decision_persona(Dia,Hora,H_E,_,go_work),!,
  % write('Persona #'),write(Persona),writeln(' va a trabajar'),
  mover_persona(Persona,A_T).
% stay_work
persona_actua(Persona,_,A_T,H_E,H_S,false,Dia,Hora):-
  decision_persona(Dia,Hora,H_E,H_S,stay_work),!,
  % write('Persona #'),write(Persona),writeln(' se queda en el trabajo'),
  mover_persona(Persona,A_T).
% home_for_the_day
persona_actua(Persona,A_H,_,H_E,H_S,false,Dia,Hora):-
  decision_persona(Dia,Hora,H_E,H_S,home_for_the_day),!,
  % write('Persona #'),write(Persona),writeln(' se queda en casa'),
  mover_persona(Persona,A_H).
% rec_time
persona_actua(Persona,A_H,A_T,H_E,H_S,false,Dia,Hora):-
  decision_persona(Dia,Hora,H_E,H_S,rec_time),!,
  % write('Persona #'),write(Persona),writeln(' se pasea'),

  findall(X,persona_area_recreativa(Persona,X),A1),
  length([A_H,A_T|A1],Top),
  numero_aleatorio_entre(0,Top,C),
  Choice is floor(C),
  nth0(Choice,[A_H,A_T|A1],Area),
  mover_persona(Persona,Area).

ciclar_todas_las_personas(Dia,Hora):-
  findall(P,persona(P,_,_,_,_,_,null),Personitas),
  ciclar_personas(Personitas,Dia,Hora).
ciclar_personas([],_,_).
ciclar_personas([Persona|Personas],Dia,Hora):-
  persona(Persona,A_H,A_T,H_E,H_S,Hosp,null),!,
  persona_actua(Persona,A_H,A_T,H_E,H_S,Hosp,Dia,Hora),
  ciclar_personas(Personas,Dia,Hora).
ciclar_personas([_|Personas],Dia,Hora):-
  ciclar_personas(Personas,Dia,Hora).

persona_picadura_infectada(Persona,Sepa):-
  %Chacar primero que no tenga infeccion activa
  \+persona_infeccion_activa(Persona,_),
  ciclo_actual(Fecha_Piquete),
  %incubacion entre 5 y 7 dias o 120 y 168 horas
  numero_aleatorio_entre(120,168,F2),
  Fecha_Fin_Incubacion is Fecha_Piquete + floor(F2),
  %contagioso hasta 4-5 dias o 96 y 120 horas dias despues de fin de incubacion
  numero_aleatorio_entre(96,120,F3),
  Fecha_Fin_Contagio is Fecha_Fin_Incubacion + floor(F3),
  %sintomas se muestran a partir del segundo dia de ser contagioso
  numero_aleatorio_entre(24,48,F4),
  Fecha_Ini_Sintomas is Fecha_Fin_Incubacion + floor(F4),
  Fecha_Fin_Sintomas is Fecha_Fin_Contagio,
  %area donde se encuentra la persona
  persona_area(Persona,Area_Picadura),

  %se crea la infeccion
  crea_infeccion_persona(Persona,
                         Sepa,
                         Fecha_Piquete,
                         Fecha_Fin_Incubacion,
                         Fecha_Fin_Contagio,
                         Fecha_Ini_Sintomas,
                         Fecha_Fin_Sintomas,
                         Area_Picadura).
all_reasons_to_panic(Reasons):-
  findall(Z,reason_to_panic(Z),Reasons).
  % findall(Z,hospitalizacion(Z),L1),
  % findall(X,persona_muerta(X),L2).
reason_to_panic(Persona):-
  hospitalizacion(Persona).
reason_to_panic(Persona):-
  persona_muerta(Persona).
infecciones_personas_visibles(Personas):-
  findall(X,infeccion_persona_visible(X),Personas).
infeccion_persona_visible(Folio):-
  infeccion_persona(Folio,_,_,_,_,FechaIS,_,_),
  ciclo_actual(Presente),
  FechaIS =< Presente.
personas_contagiosas(Personas):-
  findall(X,persona_contagiosa(X),Personas).
persona_contagiosa(Persona,Sepa):-
  infeccion_persona(Persona,Sepa,_,FechaFI,FechaFC,_,_,_),
  ciclo_actual(Presente),
  FechaFI =< Presente, Presente < FechaFC.
personas_sintomaticas(Personas):-
  findall(X,persona_sintomatica(X),Personas).
persona_sintomatica(Persona):-
  infeccion_persona(Persona,_,_,_,_,FechaIS,FechaFS,_),
  persona(Persona,_,_,_,_,_,null),
  ciclo_actual(Presente),
  FechaIS =< Presente, Presente < FechaFS.
personas_con_infeccion_activa(Personas):-
  findall(X,persona_infeccion_activa(X),Personas).
persona_infeccion_activa(Persona,Sepa):-
  infeccion_persona(Persona,Sepa,FechaP,_,FechaFC,_,_,_),
  ciclo_actual(Presente),
  FechaP =< Presente, Presente < FechaFC.
personas_muertas(Personas):-
  findall(Z,persona_muerta(Z),Personas).
persona_muerta(Persona):-
  persona(Persona,_,_,_,_,_,_),
  \+persona(Persona,_,_,_,_,_,null).
persona_sana(Persona):-
  findall(Fsintomas,infeccion_persona(Persona,_,_,_,_,_,Fsintomas,_),Fechas),
  ciclo_actual(Presente),
  numero_mayor_o_igual_a_lista(Presente,Fechas).


%%%%%%%%%%%
% MOYOTES %
%%%%%%%%%%%
tendencia_picar(alta,X):-
  numero_aleatorio_entre(0.50,0.80,X).
tendencia_picar(media,X):-
  numero_aleatorio_entre(0.30,0.50,X).
tendencia_picar(baja,X):-
  numero_aleatorio_entre(0.10,0.30,X).
porcentaje_llenado_tanque(alto,X):-
  numero_aleatorio_entre(0.70,0.90,X).
porcentaje_llenado_tanque(medio,X):-
  numero_aleatorio_entre(0.30,0.50,X).
porcentaje_llenado_tanque(bajo,X):-
  numero_aleatorio_entre(0.10,0.30,X).

moyote_quiere_picar(Hora):-
  Hora > 5,
  Hora < 11,!,
  %es hora de poco movimiento => tendencia baja
  tendencia_picar(alta,P),
  tira_moneda(P).
moyote_quiere_picar(Hora):-
  Hora > 17,
  Hora < 23,!,
  %es hora de poco movimiento => tendencia baja
  tendencia_picar(alta,P),
  tira_moneda(P).
moyote_quiere_picar(Hora):-
  Hora > 10,
  Hora < 18,!,
  %es hora de poco movimiento => tendencia baja
  tendencia_picar(baja,P),
  tira_moneda(P).
moyote_quiere_picar(Hora):-
  Hora > 22,!,
  %es hora de dormir => tendencia media
  tendencia_picar(media,P),
  tira_moneda(P).
moyote_quiere_picar(Hora):-
  Hora < 6,!,
  %es hora de dormir => tendencia media
  tendencia_picar(media,P),
  tira_moneda(P).

moyote_intenta_picar(Folio,Hora):-
  moyote_quiere_picar(Hora),
  moyote_pica(Folio,Hora).

% TODO: implementar moyote_pica_infectado/2:
% moyote_pica_infectado(folio,sepa).
moyote_pica_infectado(Moyote,Infeccion):-
  moyote_sano(Moyote),
  ciclo_actual(Presente),
  % 5-7 dias 120-168
  numero_aleatorio_entre(120,168,T),TiempoIncInfeccion is floor(T),
  FechaFin is Presente + TiempoIncInfeccion,
  crea_infeccion_moyote(Moyote,FechaFin,Infeccion).

moyote_pica(Folio,Hora):-
  moyote(Folio,Area,_,_,Infeccion),
  area_no_vacia(Area),
  persona_aleatoria_area(Area,Target),

  %reload
  (
    (Hora> 5,Hora<11,porcentaje_llenado_tanque(medio,Llenado),!);
    (Hora>17,Hora<23,porcentaje_llenado_tanque(medio,Llenado),!);
    (Hora>10,Hora<18,porcentaje_llenado_tanque(medio,Llenado),!);
    (Hora>22        ,porcentaje_llenado_tanque(alto ,Llenado),!);
    (Hora< 6        ,porcentaje_llenado_tanque(alto ,Llenado),!)
  ),
  llena_tanque_moyote(Folio,Llenado),
  %interaccion por si se pica a un enfermo
  (
  (persona_contagiosa(Target,Sepa),
  moyote_pica_infectado(Folio,Sepa),!);
  %si la persona no es contagiosa
  (true)
  ),
  %interaccion por si hay picadura infectada
  (
    %no pasa nada si no es contagioso el moyote
    (Infeccion is -1,!);
    %se infecta una persona si es contagioso el moyote
    (persona_picadura_infectada(Target,Infeccion))
  ).
moyote_intenta_morir(Folio):-
  moyote(Folio,_,F_nac,Ciclos_vida,_),
  F_muerte is F_nac+Ciclos_vida,
  ciclo_actual(Presente),
  F_muerte =< Presente,
  mata_moyote(Folio).
moyte_intenta_parir(Moyote):-
  moyote(Moyote,Area,_,_,Infeccion),
  %areas
  aguas_con_cupo_area(Area,Aguas),
  length(Aguas,La),numero_aleatorio_entre(0,La,N),Ni is floor(N),
  nth0(Ni,Aguas,Agua_huevos),
  %huevos
  numero_aleatorio_entre(150,250,N2),NumHuevos is floor(N2),
  %dias
  numero_aleatorio_entre(4,5,N3),Dias is ceil(N3),
  crea_bulto_huevos(Agua_huevos,NumHuevos,Dias,Infeccion).

%ver si me muero
ciclo_moyote(Moyote,_):-
  moyote_intenta_morir(Moyote),!.
%toi incubando
ciclo_moyote(Moyote,_):-
  c_moyote(Moyote,Ciclos,_),
  \+Ciclos = null,
  Ciclos > 0,!.
%intento parir
ciclo_moyote(Moyote,_):-
  c_moyote(Moyote,Ciclos,_),
  \+Ciclos = null,
  Ciclos is 0,
  moyte_intenta_parir(Moyote),
  !.
%intento incubar
ciclo_moyote(Moyote,_):-
  c_moyote(Moyote,_,Tank),
  Tank > 0.85,
  numero_aleatorio_entre(4,5,N),
  Ciclos is floor(N),
  set_ciclos_hasta_parir_moyote(Moyote,Ciclos),!.
%intento comer
ciclo_moyote(Moyote,Hora):-
  ((moyote_intenta_picar(Moyote,Hora),!);
    true %write('moyote #'),write(Moyote),writeln(' intento picar pero no pudo')
  ).

ciclar_moyotes([],_).
ciclar_moyotes([Moyo|Moyots],Hora):-
  ciclo_moyote(Moyo,Hora),
  ciclar_moyotes(Moyots,Hora).

ciclar_todos_los_moyotes(Hora):-
  findall(X,moyote(X,_,_,_,_),Moyots),
  ciclar_moyotes(Moyots,Hora).
avanza_embarazamiento_de_moyotes_dia:-
  findall(Z,avanza_embarazado_1_dia(Z),_).
avanza_embarazado_1_dia(X):-
  moyote_embarazado(X),
  baja_ciclos_hasta_parir_moyote(X,1).
moyote_embarazado(Moyote):-
  c_moyote(Moyote,Dias,_),
  Dias > 0.

moyote_sano(Moyote):-
  moyote(Moyote,_,_,_,-1),
  \+infeccion_moyote(Moyote,_,_).
% tendencia_picar_hora/3 es para probar que esté funcionando bien lo de arriba
tendencia_picar_hora(_,0,0):-!.
tendencia_picar_hora(Hora,N,Ten):-
  moyote_quiere_picar(Hora),!,
  M is N-1,
  tendencia_picar_hora(Hora,M,T),
  Ten is T + 1.
tendencia_picar_hora(Hora,N,Ten):-
  M is N-1,!,
  tendencia_picar_hora(Hora,M,Ten).

%%%%%%%%%%
% HUEVOS %
%%%%%%%%%%
ciclar_todos_los_huevos_dia:-
  findall(X,bulto_huevos(X,_,_,_,_),TodosLosHuevos),
  ciclar_muchos_huevos(TodosLosHuevos).
ciclar_huevos_dia(Huevos):-
  bulto_huevos(Huevos,_,_,D,_),
  D > 0,!,
  quita_dias_huevos(Huevos,1).
ciclar_huevos_dia(Huevos):-
  bulto_huevos(Huevos,Agua,_,_,_),
  cant_agua_var(Agua,CantA),CantA>0,!,
  ciclo_actual(Presente),
  eclosiona_huevos(Huevos,Presente).
ciclar_huevos_dia(Huevos):-
  bulto_huevos(Huevos,_,_,_,_),!,
  destruye_bulto(Huevos).
ciclar_muchos_huevos([]).
ciclar_muchos_huevos([Huevos|MasHuevos]):-
  ciclar_huevos_dia(Huevos),
  ciclar_muchos_huevos(MasHuevos).
  hora(0).
  hora(1).
  hora(2).
  hora(3).
  hora(4).
  hora(5).
  hora(6).
  hora(7).
  hora(8).
  hora(9).
  hora(10).
  hora(11).
  hora(12).
  hora(13).
  hora(14).
  hora(15).
  hora(16).
  hora(17).
  hora(18).
  hora(19).
  hora(20).
  hora(21).
  hora(22).
  hora(23).
  dia(0).
  dia(1).
  dia(2).
  dia(3).
  dia(4).
  dia(5).
  dia(6).

:-main.
