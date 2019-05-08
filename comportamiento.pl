:-include(datos_prueba).
main:-
  \+crea_mundo.
:-main.


%%%%%%%%%%%
%   UTIL  %
%%%%%%%%%%%

% A < B plox
numero_aleatorio_entre(A,B,Resp):-
  random(C),
  Diff is B-A,
  Resp is A + (Diff*C).
tira_moneda(P):-
  random(P1),
  P1<P,!;
  false.

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
