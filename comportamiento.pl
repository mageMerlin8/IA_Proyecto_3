:-include(datos_prueba).
main:-
  \+crea_mundo,
  crea_el_tiempo.

:- dynamic
  ciclo_actual/1.

%%%%%%%%
% UTIL %
%%%%%%%%

% A < B plox
numero_aleatorio_entre(A,B,Resp):-
  random(C),
  Diff is B-A,
  Resp is A + (Diff*C).
tira_moneda(P):-
  random(P1),
  P1<P,!;
  false.
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

%%%%%%%%%%
% TIEMPO %
%%%%%%%%%%
crea_el_tiempo:-
  assert(ciclo_actual(0)).
avanza_el_tiempo:-
  ciclo_actual(Pasado),
  Presente is Pasado + 1,
  retractall(ciclo_actual(_)),
  assert(ciclo_actual(Presente)).
hora_dia_actual(Hora,Dia):-
  ciclo_actual(Presente),
  Hora is Presente mod 24,
  Dia is div(div(Presente,24),7).
ciclar_mundo:-
  hora_dia_actual(Hora,Dia),
  %ciclar entidades
  ciclar_todos_los_moyotes(Hora),
  ciclar_todas_las_personas(Dia,Hora),
  avanza_el_tiempo.



%%%%%%%%%%%%
% PERSONAS %
%%%%%%%%%%%%

decision_persona(Persona,_,_,aiuda_toy_hospitalizado):-
  %falta ver que hacemos con los hospitalizados
  %tambien hay que checar si ya hay sintomas pa ver si va al hospital o algo
  persona(Persona,_,_,_,_,true,null).

decision_persona(Persona,Dia,Hora,go_home):-
  Dia < 5,
  %false y null para asegurarnos de que este fuera del hospital y vivo
  persona(Persona,_,_,_,H_S,false,null),
  Hora = H_S,!.
decision_persona(Persona,Dia,Hora,go_work):-
  Dia < 5,
  %false y null para asegurarnos de que este fuera del hospital y vivo
  persona(Persona,_,_,H_E,_,false,null),
  Hora = H_E,!.
decision_persona(Persona,Dia,Hora,stay_work):-
  Dia < 5,
  %false y null para asegurarnos de que este fuera del hospital y vivo
  persona(Persona,_,_,H_E,H_S,false,null),
  Hora > H_E,
  Hora < H_S,!.
decision_persona(Persona,Dia,Hora,home_for_the_day):-
  (Dia < 5,!);
  (Dia > 5, Hora > 22, Hora < 9),
  %false y null para asegurarnos de que este fuera del hospital y vivo
  persona(Persona,_,_,_,_,false,null),!.
decision_persona(Persona,_,_,rec_time):-
  persona(Persona,_,_,_,_,false,null).

persona_actua(Persona,Dia,Hora):-
  decision_persona(Persona,Dia,Hora,go_home),!,
  persona(Persona,A_H,_,_,_,false,null),
  mover_persona(Persona,A_H).
persona_actua(Persona,Dia,Hora):-
  decision_persona(Persona,Dia,Hora,home_for_the_day),!,
  persona(Persona,A_H,_,_,_,false,null),
  mover_persona(Persona,A_H).
persona_actua(Persona,Dia,Hora):-
  decision_persona(Persona,Dia,Hora,go_work),!,
  persona(Persona,_,A_T,_,_,false,null),
  mover_persona(Persona,A_T).
persona_actua(Persona,Dia,Hora):-
  decision_persona(Persona,Dia,Hora,stay_work),!,
  persona(Persona,_,A_T,_,_,false,null),
  mover_persona(Persona,A_T).
persona_actua(Persona,Dia,Hora):-
  decision_persona(Persona,Dia,Hora,rec_time),!,
  findall(X,persona_area_recreativa(Persona,X),Areas),
  length(Areas,Top),
  numero_aleatorio_entre(0,Top,C),
  Choice is floor(C),
  nth0(Choice,Areas,Area),
  mover_persona(Persona,Area).
persona_actua(Persona,Dia,Hora):-
  decision_persona(Persona,Dia,Hora,aiuda_toy_hospitalizado),!.

ciclar_todas_las_personas(Dia,Hora):-
  findall(P,persona(P,_,_,_,_,_,null),Personitas),
  ciclar_personas(Personitas,Dia,Hora).
ciclar_personas([Persona|Personas],Dia,Hora):-
  persona_actua(Persona,Dia,Hora),
  ciclar_personas(Personas,Dia,Hora).

% persona_cicla(Persona,Dia,Hora).



% TODO: implementar persona_picadura_infectada(persona,infeccion).
persona_picadura_infectada(_,_).
% TODO: implementar persona_contagiosa(Target,Sepa). (Tiene que ver con el momento)
persona_contagiosa(_,_):-false.
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
% TODO: implementar moyote_pica_infectado/2:
% moyote_pica_infectado(folio,sepa).
moyote_pica_infectado(_,_).
ciclo_moyote(Moyote,Hora):-
  %ver si me muero

  %intento poner huevos o los estoy 'incubando'

  %si no pude, intento comer
  ((moyote_intenta_picar(Moyote,Hora),!);
  write('moyote #'),write(Moyote),writeln('intento picar pero no pudo')).

ciclar_moyotes([],_).
ciclar_moyotes([Moyo|Moyots],Hora):-
  ciclo_moyote(Moyo,Hora),
  ciclar_moyotes(Moyots,Hora).

ciclar_todos_los_moyotes(Hora):-
  findall(X,moyote(X,_,_,_,_),Moyots),
  ciclar_moyotes(Moyots,Hora).

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
