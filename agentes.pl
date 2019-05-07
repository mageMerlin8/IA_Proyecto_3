
:-dynamic
  area/2,
  areas_vecinas/2,
  agua_const/2,

  agua_var/5,
  cant_agua_var/2,
  agua_var_unsafe/2,
  folio_agua_var/1,

  persona/6,
  persona_area/2,
  folio_persona/1,

  moyote/4,
  tanque_moyote/2,
  folio_moyote/1,
  bulto_huevos/6,
  folio_bultos/1,

  infeccion_moyote/3,
  infeccion_persona/7.
  
% Area(folio,constanteDeEcharcamiento)
crea_area(Folio,Const):-
  assert(area(Folio,Const)).
/*
  asigna_vecinos(Vec):- Vec es una lista donde cada elemento es una vertice en
                      el grafo del area de la forma [Area1,Area2] (Area1 y
                      Area2 son el folio de dos areas adyacentes). Se considera
                      que es una grafica sin direccion.
*/
asigna_vecinos([[X,Y]|Vecinos]):-
  assert(areas_vecinas(X,Y)),
  asigna_vecinos(Vecinos).
asigna_vecinos([]).
% Hacemos el hecho de vecinididad conmutativo:
areas_vecinas(X,Y):-
  areas_vecinas(Y,X).

/*
 agua_const(folio,folioArea) :- vamos a considerar que estas fuentes tienen
                        capacidad infinita de huevos ya que son permanentes
                        (tienen mucha agua)
*/
/*
 agua_var(folio,folioArea,tipo(art/nat),capacidadHuevos,%vaciado)

 cant_agua_var(folioAgua,cant(%))
 //para tipo art(artificial)
 agua_var_unsafe(folioAgua)
*/
crea_agua_const(FolioA):-
  findall(X,agua_const(X,_),Ls),
  Ls =\= [],
  max_list(Ls, F),
  Folio is F+1,
  assert(agua_const(Folio,FolioA)).
crea_agua_const(FolioA):-
  Folio is 0,
  assert(agua_const(Folio,FolioA)).

escribe_agua_var(Folio):-
  agua_var(Folio,FolioA,Tipo,CapH,P_Vaciado),
  cant_agua_var(Folio,Cant),

  write('Agua Variable # '),writeln(Folio),
  write('Area: '),writeln(FolioA),
  write('Tipo: '),writeln(Tipo),
  write('Cantidad Agua: '),write(Cant),writeln('%'),
  write('Taza de perdida: '),write(P_Vaciado),writeln('%'),
  % Poner tambien numero total de huevos aqui
  write('CapHuevos: '),writeln(CapH).


crea_agua_var(FolioA,Tipo,CapH,P_Vaciado):-
  folio_agua_var(F),
  Folio is F+1,
  retractall(folio_agua_var(_)),
  assert(folio_agua_var(Folio)),
  assert(agua_var(Folio,FolioA,Tipo,CapH,P_Vaciado)),
  % le damos un valor inicial de 0.1%(lleno) al cuerpo de agua para modificar despues
  assert(cant_agua_var(Folio,0.1)).
crea_agua_var(FolioA,Tipo,CapH,P_Vaciado):-
  Folio is 0,
  assert(folio_agua_var(0)),
  assert(agua_var(Folio,FolioA,Tipo,CapH,P_Vaciado)),
  assert(cant_agua_var(Folio,0.1)),
  writeln('Agua variable creada:'),
  escribe_agua_var(Folio).

elimina_agua_var(Folio):-
  retractall(cant_agua_var(Folio,_)),
  retractall(agua_var(Folio,_,_,_,_)),
  retractall(agua_var_unsafe(Folio)),
  retractall(bulto_huevos(_,Folio,var,_,_,_)).

llena_agua_var(Folio,P):-
  cant_agua_var(Folio,P_actual),
  New is P_actual + P,
  retractall(cant_agua_var(Folio,_)),
  assert(cant_agua_var(Folio,New)).
vacia_agua_var(Folio,P):-
  P2 is -1*P,
  llena_agua_var(Folio,P2).
make_water_unsafe(Folio):-
  agua_var(Folio,_,art,_,_),
  assert(agua_var_unsafe(Folio)).
make_water_safe(Folio):-
  agua_var(Folio,_,art,_,_),
  retractall(agua_var_unsafe(Folio)).

/*
persona(folio,area_hogar,area_trabajo,hora_entrada,hora_salida,hospitalizado?).

persona_area(folioP,folioA)

*/
crea_persona(A_H,A_T,H_E,H_S):-
  folio_persona(F),
  Folio is F + 1,
  retractall(folio_persona(_)),
  assert(folio_persona(Folio)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,false)),
  assert(persona_area(Folio,A_H)).

crea_persona(A_H,A_T,H_E,H_S):-
  Folio is 0,
  assert(folio_persona(Folio)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,false)),
  assert(persona_area(Folio,A_H)).

crea_persona_empleo_normal(A_H.A_T):-
  crea_persona(A_H,A_T,9,17).

mover_persona(Persona,Target):-
  retractall(persona_area(Persona,_)),
  assert(persona_area(Persona,Target)).

matar_persona(Folio):-
  retractall(persona(Folio,_,_,_,_,_)),
  retractall(persona_area(Folio,_)),
  retractall(infeccion_persona(Folio,_,_,_,_,_,_)).

hospitalizar_persona(Folio):-
  persona(Folio,A_H,A_T,H_E,H_S,_),
  retractall(persona(Folio,_,_,_,_,_)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,true)).
deshospitalizar_persona(Folio):-
  persona(Folio,A_H,A_T,H_E,H_S,_),
  retractall(persona(Folio,_,_,_,_,_)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,false)).

/*
moyote(folio,
       area_hogar,
       fecha_nacimiento,
       ciclos_de_vida)
*/
crea_moyote(Area,FechaN,Ciclos,Infeccion):-
  folio_moyote(F),
  Folio is F+1,
  retractall(folio_moyote(_)),
  assert(folio_moyote(Folio)),
  assert(moyote(Folio,Area,FechaN,Ciclos,Infeccion)),
  assert(tanque_moyote(Folio,0)).
crea_moyote(Area,FechaN,Ciclos,Infeccion):-
  Folio is 0,
  assert(folio_moyote(Folio)),
  assert(moyote(Folio,Area,FechaN,Ciclos,Infeccion)),
  assert(tanque_moyote(Folio,0)).

crea_moyote_sano(Area,FechaN,Ciclos):-
  Infeccion is -1, % -1 representa un mosquito sano
  crea_moyote(Area,FechaN,Ciclos,Infeccion).

mata_moyote(Folio):-
  retractall(moyote(Folio,_,_,_,_)),
  retractall(infeccion_moyote(Folio)),
  retractall(tanque_moyote(Folio)).

llena_tanque_moyote(Folio,Cant):-
  tanque_moyote(Folio,C1),
  C2 is C1 + Cant,
  retractall(tanque_moyote(Folio,_)),
  assert(tanque_moyote(Folio,C2)).
vacia_tanque_moyote(Folio,Cant):-
  Cant1 is -1 * Cant,
  llena_tanque_moyote(Folio,Cant1).

infectar_moyote(Moyote,Tipo):-
  %para asegurarnos de no infectar moyotes mas de una vez
  moyote(Moyote,Area,FechaN,Ciclos,-1),
  retractall(moyote(Moyote,_,_,_,_)),
  assert(moyote(Moyote,Area,FechaN,Ciclos,Tipo)).

infectar_moyote(_,_):-
  write('Se intento infectar un moyote invalido').

/*
bulto_huevos(folio,
             folio_agua,
             tipo_agua,
             cant_huevos,
             ciclos_hasta_eclosion,
             tipo_infeccion)
*/
crea_bulto_huevos(FolioAgua,TipoAgua,CantH,Ciclos,Inf):-
  folio_bultos(F),!,
  Folio is F+1,
  retractall(folio_bultos(_)),
  assert(folio_bultos(Folio)),
  assert(bulto_huevos(Folio,FolioAgua,TipoAgua,CantH,Ciclos,Inf)).
crea_bulto_huevos(FolioAgua,TipoAgua,CantH,Ciclos,Inf):-
  asserta(folio_bultos(0)),
  crea_bulto_huevos(FolioAgua,TipoAgua,CantH,Ciclos,Inf).
destruye_bulto(Folio):-
  retractall(bulto_huevos(Folio,_,_,_,_,_)).

/*
infeccion_moyote(folioM,fecha_fin_incubacion,sepa)
*/
crea_infeccion_moyote(Moyote,FechaFI,Sepa):-
  assert(infeccion_moyote(Moyote,FechaFI,Sepa)).
destruye_infeccion_moyote(Moyote):-
  retractall(infeccion_moyote(Moyote,_,_)).
/*
infeccion_persona(folioP,
                  tipo,
                  fechaP,
                  fecha_f_inc,
                  fecha_f_con,
                  fecha_i_sin,
                  fecha_f_sin)
*/
crea_infeccion_persona(Persona,T,F1,F2,F3,F4,F5):-
  assert(infeccion_persona(Persona,T,F1,F2,F3,F4,F5)).
destruye_infeccion_persona(Persona):-
  retractall(infeccion_persona(Persona,_,_,_,_,_,_)).
