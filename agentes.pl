
:-dynamic
  area/2,
  areas_vecinas/2,

  agua_var/4,
  cant_agua_var/2,
  folio_agua_var/1,

  persona/7,
  persona_area/2,
  hospitalizacion/1,
  persona_area_recreativa/2,
  folio_persona/1,

  moyote/5,
  c_moyote/3,
  folio_moyote/1,
  bulto_huevos/5,
  folio_bultos/1,

  infeccion_moyote/3,
  infeccion_persona/8.

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
  asserta(areas_vecinas(X,Y)),
  asigna_vecinos(Vecinos).
asigna_vecinos([]).
% Hacemos el hecho de vecinididad conmutativo:
areas_vecinas(X,Y):-
  areas_vecinas(Y,X),!.

/*
 agua_var(folio,folioArea,tipo(art/nat),capacidadHuevos,%vaciado)

 cant_agua_var(folioAgua,cant(%))
 //para tipo art(artificial)
 agua_var_unsafe(folioAgua)
*/
crea_agua_var(FolioA,CapH,P_Vaciado):-
  folio_agua_var(F),!,
  Folio is F+1,
  retractall(folio_agua_var(_)),
  assert(folio_agua_var(Folio)),
  assert(agua_var(Folio,FolioA,CapH,P_Vaciado)),
  % le damos un valor inicial de 0.1%(lleno) al cuerpo de agua para modificar despues
  assert(cant_agua_var(Folio,0.1)).
crea_agua_var(FolioA,CapH,P_Vaciado):-
  Folio is 0,
  assert(folio_agua_var(0)),
  assert(agua_var(Folio,FolioA,CapH,P_Vaciado)),
  assert(cant_agua_var(Folio,0.1)).

elimina_agua_var(Folio):-
  retractall(cant_agua_var(Folio,_)),
  retractall(agua_var(Folio,_,_,_)),
  retractall(bulto_huevos(_,Folio,_,_,_)).
cupo_huevos_agua(Agua,Cupo):-
  agua_var(Agua,_,Cap,_),
  findall(Z,bulto_huevos(_,Agua,Z,_,_),Huevos),
  sum_list(Huevos,Num_huevos),
  Cupo is Cap - Num_huevos.

llena_agua_var(Folio,P):-
  cant_agua_var(Folio,P_actual),
  New is max(0,min(1,P_actual + P)),
  retractall(cant_agua_var(Folio,_)),
  assert(cant_agua_var(Folio,New)).
vacia_agua_var(Folio,P):-
  P2 is -1*P,
  llena_agua_var(Folio,P2).
/*
persona(folio,
        area_hogar,
        area_trabajo,
        hora_entrada,
        hora_salida,
        hospitalizado?,
        fecha_muerte).


persona_area(folioP,folioA)
persona_area_recreativa(Persona,Area)

*/
crea_persona(A_H,A_T,H_E,H_S):-
  folio_persona(F),!,
  Folio is F + 1,
  retractall(folio_persona(_)),
  assert(folio_persona(Folio)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,false,null)),
  assert(persona_area(Folio,A_H)).

crea_persona(A_H,A_T,H_E,H_S):-
  Folio is 0,
  assert(folio_persona(Folio)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,false,null)),
  assert(persona_area(Folio,A_H)).

crea_persona_empleo_normal(A_H,A_T):-
  crea_persona(A_H,A_T,9,17).
mover_persona(Persona,Target):-
  persona_area(Persona,Target),!.
mover_persona(Persona,Target):-
  retractall(persona_area(Persona,_)),
  assert(persona_area(Persona,Target)).

matar_persona(Folio,Fecha):-
  persona(Folio,A_H,A_T,H_E,H_S,Hops,null),!,
  retractall(persona(Folio,_,_,_,_,_,_)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,Hops,Fecha)),
  retractall(persona_area(Folio,_)).
matar_persona(Folio,_):-
  write('no se pudo matar a la persona #'),writeln(Folio).


hospitalizar_persona(Folio):-
  persona(Folio,A_H,A_T,H_E,H_S,_,null),!,
  retractall(persona(Folio,_,_,_,_,_,_)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,true,null)),
  assert(hospitalizacion(Folio)),
  retractall(persona_area(Folio,_)).
hospitalizar_persona(Folio):-
  write('Se intento hospitalizar persona invalida: '),writeln(Folio).

deshospitalizar_persona(Folio):-
  persona(Folio,A_H,A_T,H_E,H_S,_,null),!,
  retractall(persona(Folio,_,_,_,_,_,_)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,false,null)).
deshospitalizar_persona(Folio):-
  write('Se intento deshospitalizar persona invalida: '),writeln(Folio).

cambiar_trabajo_persona(Folio,Area_trabajo,H_E,H_S):-
  persona(Folio,A_H,_,_,_,Hosp,F),
  retractall(persona(Folio,_,_,_,_,_,_)),
  assert(persona(Folio,A_H,Area_trabajo,H_E,H_S,Hosp,F)).
%cambia el area de trabajo sin cambiar el horario
cambiar_trabajo_persona(Folio,Area_trabajo):-
  persona(Folio,A_H,_,H_E,H_S,Hosp,F),
  retractall(persona(Folio,_,_,_,_,_,_)),
  assert(persona(Folio,A_H,Area_trabajo,H_E,H_S,Hosp,F)).

agregar_area_rec_persona(FolioP,FolioA):-
  persona_area_recreativa(FolioP,FolioA).
agregar_area_rec_persona(FolioP,FolioA):-
  assert(persona_area_recreativa(FolioP,FolioA)).
quitar_area_rec_persona(FolioP,FolioA):-
  retractall(persona_area_recreativa(FolioP,FolioA)).

/*
moyote(folio,
       area_hogar,
       fecha_nacimiento,
       ciclos_de_vida)
*/
crea_moyote(Area,FechaN,Ciclos,Infeccion):-
  folio_moyote(F),!,
  Folio is F+1,
  retractall(folio_moyote(_)),
  assert(folio_moyote(Folio)),
  assert(moyote(Folio,Area,FechaN,Ciclos,Infeccion)),
  assert(c_moyote(Folio,-1,0)).
crea_moyote(Area,FechaN,Ciclos,Infeccion):-
  Folio is 0,
  assert(folio_moyote(Folio)),
  assert(moyote(Folio,Area,FechaN,Ciclos,Infeccion)),
  assert(c_moyote(Folio,-1,0)).
crea_moyote_auto(Area,FechaN,Infeccion):-
  random(C),
  Ciclos is 168 + floor(C*504),
  crea_moyote(Area,FechaN,Ciclos,Infeccion).
crea_moyote_sano(Area,FechaN,Ciclos):-
  Infeccion is -1, % -1 representa un mosquito sano
  crea_moyote(Area,FechaN,Ciclos,Infeccion).
crea_n_moyotes_auto(Area,FechaN,Inf,N):-
  N>0,
  M is N-1,
  crea_moyote_auto(Area,FechaN,Inf),
  crea_n_moyotes_auto(Area,FechaN,Inf,M).
crea_n_moyotes_auto(_,_,_,0).
mata_moyote(Folio):-
  retractall(moyote(Folio,_,_,_,_)),
  retractall(infeccion_moyote(Folio,_,_)),
  retractall(c_moyote(Folio,_,_)).
set_ciclos_hasta_parir_moyote(Folio,Ciclos):-
  c_moyote(Folio,_,Tanque),
  retractall(c_moyote(Folio,_,_)),
  assert(c_moyote(Folio,Ciclos,Tanque)).
baja_ciclos_hasta_parir_moyote(Folio,Ciclos):-
  c_moyote(Folio,C1,Tanque),
  New_ciclos is max(0,C1-Ciclos),
  retractall(c_moyote(Folio,_,_)),
  assert(c_moyote(Folio,New_ciclos,Tanque)).
llena_tanque_moyote(Folio,Cant):-
  c_moyote(Folio,Ciclos,C1),
  % max y min son para que se quede en el intervalo: [0,1]
  C2 is max(min(1,C1 + Cant),0),
  retractall(c_moyote(Folio,_,_)),
  assert(c_moyote(Folio,Ciclos,C2)).
vacia_tanque_moyote(Folio,Cant):-
  Cant1 is -1 * Cant,
  llena_tanque_moyote(Folio,Cant1).

infectar_moyote(Moyote,Tipo):-
  %para asegurarnos de no infectar moyotes mas de una vez
  moyote(Moyote,Area,FechaN,Ciclos,-1),!,
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
crea_bulto_huevos(FolioAgua,CantH,Dias,Inf):-
  folio_bultos(F),!,
  Folio is F+1,
  retractall(folio_bultos(_)),
  assert(folio_bultos(Folio)),
  assert(bulto_huevos(Folio,FolioAgua,CantH,Dias,Inf)).
crea_bulto_huevos(FolioAgua,CantH,Dias,Inf):-
  asserta(folio_bultos(0)),
  crea_bulto_huevos(FolioAgua,CantH,Dias,Inf).
destruye_bulto(Folio):-
  retractall(bulto_huevos(Folio,_,_,_,_)).
eclosiona_huevos(Huevos,Fecha):-
  bulto_huevos(Huevos,Area,Cant,_,Inf),
  %nace 40% de la poblacion
  numero_aleatorio_entre(0.3,0.5,P),NumNuevos is floor(P*Cant),
  %nace entre 1 y 10% enferma
  numero_aleatorio_entre(0.01,0.1,P2),NumInf is floor(P2*NumNuevos),
  NumSanos is Cant-NumInf,
  crea_n_moyotes_auto(Area,Fecha,Inf,NumInf),
  crea_n_moyotes_auto(Area,Fecha,-1,NumSanos).
quita_dias_huevos(Huevos,Dias):-
  bulto_huevos(Huevos,Agua,Cant,D1,Tipo),
  D2 is max(0,D1-Dias),
  retractall(bulto_huevos(Huevos,_,_,_,_)),
  assert(bulto_huevos(Huevos,Agua,Cant,D2,Tipo)).

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
crea_infeccion_persona(Persona,T,F1,F2,F3,F4,F5,FolioArea):-
  assert(infeccion_persona(Persona,T,F1,F2,F3,F4,F5,FolioArea)).
destruye_infeccion_persona(Persona):-
  retractall(infeccion_persona(Persona,_,_,_,_,_,_)).
