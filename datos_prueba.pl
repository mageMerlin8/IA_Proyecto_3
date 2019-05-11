:-include(agentes).
crea_areas:-
  Casas is 1,
  Trabajos is 2,
  Rec is 3,
  %res
  crea_area(Casas,3),
  crea_agua_var(Casas,500,0.10),
  agua_var(C1,Casas,_,_),!,
  llena_agua_var(C1,1),
  %tra
  crea_area(Trabajos,1),
  crea_agua_var(Trabajos,500,0.10),
  agua_var(T1,Trabajos,_,_),!,
  llena_agua_var(T1,1),
  %rec
  crea_area(Rec,5),
  crea_agua_var(Rec,500,0.10),
  agua_var(R1,Rec,_,_),!,
  llena_agua_var(R1,1),
  asigna_vecinos([[Casas,Trabajos],[Trabajos,Rec],[Rec,Casas]]).

crea_agentes:-
  crea_N_personas_p(300),!,
  findall(X,persona(X,_,_,_,_,_,_),Folios),
  asigna_areas_rec_personas(Folios),
  crea_moyotes_en_lugares_aleatorios(1000,0.9).

crea_N_personas_p(N):-
  N > 0,!,
  crea_persona_empleo_normal(1,2),
  M is N-1,
  crea_N_personas_p(M).
crea_N_personas_p(_):-!.
asigna_areas_rec_personas([Folio|Folios]):-
  agregar_area_rec_persona(Folio,3),
  asigna_areas_rec_personas(Folios).
asigna_areas_rec_personas([]).
% N es el numero de moyotes y P es el porcentaje de moyotes sanos
crea_moyotes_en_lugares_aleatorios(N,P):-
  N > 0,
  random(P1),
  P1 > P,!,
  random(A),
  Area is floor(A*3)+1,
  random(C),
  Ciclos is 168 + floor(C*504),
  random(S),
  Sepa is floor(S*3),
  crea_moyote(Area,0,Ciclos,Sepa),
  M is N-1,
  crea_moyotes_en_lugares_aleatorios(M,P).
crea_moyotes_en_lugares_aleatorios(N,P):-
  N > 0,
  random(A),
  Area is floor(A*3)+1,
  random(C),
  Ciclos is 168 + floor(C*504),
  crea_moyote_sano(Area,0,Ciclos),
  M is N-1,
  crea_moyotes_en_lugares_aleatorios(M,P).

crea_mundo:-
  crea_areas,
  crea_agentes.

% main:-
%   guitracer,
%   spy(crea_moyotes_en_lugares_aleatorios/2),
%   trace,
%   crea_mundo.
% :-main.
