
:-dynamic
  area/2,
  areas_vecinas/2,
  agua_const/2,
  % folio_area/1,

  agua_var/5,
  cant_agua_var/2,
  agua_var_unsafe/2,
  folio_agua_var/1,

  persona/7,
  persona_area/2,
  persona_area_recreativa/2,
  folio_persona/1,

  moyote/5,
  tanque_moyote/2,
  folio_moyote/1,
  bulto_huevos/6,
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
  \+(Ls = []),
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
  folio_agua_var(F),!,
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
  retractall(persona_area(Persona,_)),
  assert(persona_area(Persona,Target)).

matar_persona(Folio,Fecha):-
  % retractall(infeccion_persona(Folio,_,_,_,_,_,_)).

  persona(Folio,A_H,A_T,H_E,H_S,Hops,null),!,
  retractall(persona(Folio,_,_,_,_,_,_)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,Hops,Fecha)),
  retractall(persona_area(Folio,_)).
matar_persona(Folio,_):-
  write('no se pudo matar a la persona #'),write(Folio).


hospitalizar_persona(Folio):-
  persona(Folio,A_H,A_T,H_E,H_S,_),
  retractall(persona(Folio,_,_,_,_,_)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,true)),
  retractall(persona_area(Folio,_)).

deshospitalizar_persona(Folio):-
  persona(Folio,A_H,A_T,H_E,H_S,_),
  retractall(persona(Folio,_,_,_,_,_)),
  assert(persona(Folio,A_H,A_T,H_E,H_S,false)).

cambiar_trabajo_persona(Folio,Area_trabajo,H_E,H_S):-
  persona(Folio,A_H,_,_,_,Hosp),
  retractall(persona(Folio,_,_,_,_,_)),
  assert(persona(Folio,A_H,Area_trabajo,H_E,H_S,Hosp)).
%cambia el area de trabajo sin cambiar el horario
cambiar_trabajo_persona(Folio,Area_trabajo):-
  persona(Folio,A_H,_,H_E,H_S,Hosp),
  retractall(persona(Folio,_,_,_,_,_)),
  assert(persona(Folio,A_H,Area_trabajo,H_E,H_S,Hosp)).

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
crea_infeccion_persona(Persona,T,F1,F2,F3,F4,F5,FolioArea):-
  assert(infeccion_persona(Persona,T,F1,F2,F3,F4,F5,FolioArea)).
destruye_infeccion_persona(Persona):-
  retractall(infeccion_persona(Persona,_,_,_,_,_,_)).

  /*
  Predicados para conseguir las métricas en un instante estático de la propagacion
  */

% Funciones Generales
tam_lista([],X):-
  X=0.

tam_lista([_|Cola],Contador):-
  tam_lista(Cola,Acumulado),
  Contador = Acumulado + 1.

/*Metodos usados para calcular claves, se hicieron mas eficientes abajo
mayor(X,Y,X):-
  X>Y.
mayor(_,Y,Y).

mayor_clave(X,SX,Y,SY,X,SX):-
  X>Y.
mayor_clave(_,_,Y,SY,Y,SY).*/

mayorClave([],[],-1,-1).

mayorClave([_|B],[X|Y],S,N):-
  mayorClave(B,Y,S,N),
  N>X.

mayorClave([A|_],[X|_],A,X).

fallecimientos(Ls,Cant):-
  findall(Folio1,persona(Folio1,_,_,_,_,_,null),Ls1),
  findall(Folio2,persona(Folio2,_,_,_,_,_,_),Ls2),
  ord_subtract(Ls2,Ls1,Ls)
  tam_lista(Ls,Cant).

abrirPareja([X,Y],X,Y).


% Contadores
moyotesXsepa(Serotipo,Cant):-
  findall(F, moyote(F,_,_,_,Serotipo),Ls),
  tam_lista(Ls,Cant).

contar_moyotes(Y):-
  findall(F, moyote(F,_,_,_,_),Ls),
  tam_lista(Ls,Y).

moyotesXarea(Area,Serotipo,Cant):-
  findall(Folio,moyote(Folio,Area,_,_,Serotipo),Ls),
  tam_lista(Ls,Cant).

personasXsepa(X,Y):-
  findall(F,persona(F,_,_,_,_,_,null),Ls1),
  findall(F2,infeccion_persona(F2,X,_,_,_,_,_,_),Ls2),
  ord_intersect(Ls1,Ls2,Ls),
  tam_lista(Ls,Y).

infectadosXsepa(X,Ls,Y):-
  findall(Folio,infeccion_persona(Folio,X,_,_,_,_,_,_),Ls),
  tam_lista(Ls,Y).

combo_mortal(ClaveC,Cant):-
  fallecidosXsepa(1,Ls,),
  fallecidosXsepa(2,Ls2),
  fallecidosXsepa(3,Ls3),
  fallecidosXsepa(4,Ls4),
  calcularCombo(1,2,N1,C1),
  calcularCombo(1,3,N2,C2),
  calcularCombo(1,4,N3,C3),
  calcularCombo(2,3,N4,C4),
  calcularCombo(2,4,N5,C5),
  calcularCombo(3,4,N6,C6),
  mayorClave([C1,C2,C3,C4,C5,C6],[N1,N2,N3,N4,N5,N6],ClaveC,Cant).

cant_habXarea(Area, residencia, Lista, Cant):-
  findall(Folio,persona(Folio,Area,_,_,_,false,null),Lista),
  tam_lista(Lista,Cant).

cant_habXarea(Area,trabajo, Lista, Cant):-
  findall(Folio,persona(Folio,_,Area,_,_,false,null),Lista),
  tam_lista(Lista,Cant).

cant_habXarea(Area,recreacion, Lista, Cant):-
  findall(Folio,persona(Folio,_,_,_,_,true,null),Lista1))
  findall(Folio2,persona_area_recreativa(Folio2,Area),Lista2),
  ord_subtract(Lista2,Lista1,Lista),
  tam_lista(Lista,Cant).

infectadosXarea(Area,Sepa,Ls):-
  findall(Folio,infeccion_persona(Folio,Sepa,_,_,_,_,_,Area), Ls).

% reportes de metricas
% Estado general de la urbe
metricas_totales:-
  write('METRICAS DE LA URBE: '), nl,
  metricas_mosquitoXsepa(), nl,
  metricas_personasXsepa(), nl,
  metricas_fallecidos(),nl.


metricas_mosquitoXsepa:-
  moyotesXsepa(-1,S),
  moyotesXsepa(1,U),
  moyotesXsepa(2,D),
  moyotesXsepa(3,T),
  moyotesXsepa(4,C),
  Total is S + U + D + T + C,
  write('Total de mosquitos: '), write(Total), nl,
  write('   Sanos: '), write(S), nl,
  write('   Con serotipo 1: '), write(U), nl,
  write('   Con serotipo 2: '), write(D), nl,
  write('   Con serotipo 3: '), write(T), nl,
  write('   Con serotipo 4: '), write(C),nl.

metricas_personasXsepa:-
  personasXsepa(-1,S),
  personasXsepa(1,U),
  personasXsepa(2,D),
  personasXsepa(3,T),
  personasXsepa(4,C),
  findall(F,persona(F,_,_,_,_,_,null),Ls1),
  tam_lista(Ls1,Total),
  write('Total de Personas: '), write(Total), nl,
  write('   Sanas: '), write(S), nl,
  write('   Con serotipo 1: '), write(U), nl,
  write('   Con serotipo 2: '), write(D), nl,
  write('   Con serotipo 3: '), write(T), nl,
  write('   Con serotipo 4: '), write(C), nl,
  write('Nota: una persona puede tener mas de 1 serotipo.').

% No se dividio en varios metodos para evitar contar varias veces las mismas listas
metricas_fallecidos:-
  fallecimientos(Lf,F),
  write('Total de fallecimientos: '), write(F), nl,
  % metricas de fallecimientos de una unica sepa
  findall(Folio,infeccion_persona(Folio,1,_,_,_,_,_,_),Ls1),
  findall(Folio2,infeccion_persona(Folio2,2,_,_,_,_,_,_),Ls2),
  findall(Folio3,infeccion_persona(Folio3,3,_,_,_,_,_,_),Ls3),
  findall(Folio4,infeccion_persona(Folio4,4,_,_,_,_,_,_),Ls4),
  % intersectando los fallecidos con cada sepa para obtener las poblaciones
  ord_intersect(Lf,Ls1,Lfs1),
  ord_intersect(Lf,Ls2,Lfs2),
  ord_intersect(Lf,Ls3,Lfs3),
  ord_intersect(Lf,Ls4,Lfs4),
  % se calculan los tamaños de cada poblacion
  tam_lista(Lfs1,U),
  tam_lista(Lfs2,D),
  tam_lista(Lfs3,T),
  tam_lista(Lfs4,C),
  mayorClave([1,2,3,4],[U,D,T,C],S,N),
  P is N * 100 / F,
  write('Serotipo con mayor mortandad: '), write(S), nl,
  write('Porcentaje de responsabilidad: '), write(P), nl,
  % ahora se calculan las metricas de combiancion de 2 sepas
  ord_intersect(Lfs1,Lfs2,L12),
  ord_intersect(Lfs1,Lfs3,L13),
  ord_intersect(Lfs1,Lfs4,L14),
  ord_intersect(Lfs2,Lfs3,L23),
  ord_intersect(Lfs2,Lfs4,L24),
  ord_intersect(Lfs3,Lfs4,L34),
  % obtenemos el tamaño de cada combinacion
  tam_lista(L12,UD),
  tam_lista(L13,UT),
  tam_lista(L14,UC),
  tam_lista(L23,DT),
  tam_lista(L24,DC),
  tam_lista(L34,TC),
  mayorClave([[1,2],[1,3],[1,4],[2,3],[2,4],[3,4]],[UD,UT,UC,DT,DC,TC],[S1,S2],C),
  PC is C * 100 / F,
  write('Combinación par con mayor mortandad: Serotipo'), write(S1), write(' y Serotipo'), write(S2),nl
  write('Porcentaje de responsabilidad: '), write(PC),nl,
  % metricas para la mortandad de 3 sepas
  % intersectamos una combinacion con el conjunto faltante para hacer triadas
  ord_intersect(Lfs1,L23,L123),
  ord_intersect(Lfs1,L34,L134),
  ord_intersect(Lfs1,L24,L124),
  ord_intersect(Lfs2,L34,L234),
  tam_lista(L123,UDT),
  tam_lista(L134,UTC),
  tam_lista(L124,UDC),
  tam_lista(L234,DTC),
  mayorClave([[1,2,3],[1,3,4],[1,2,4],[2,3,4]],[UDT,UTC,UDC,DTC],[A1|B],T),
  abrirPareja(B,A2,A3),
  PT is T * 100 / F,
  write('Tercia de serotipos con mayor mortandad: '), write(A1), write(', '),
  write(A2), write(' y '), write(A3),nl
  write('Porcentaje de responsabilidad: '), write(PT),nl,
  /*metricas para la mortandad de las 4 sepas
  dado que ya se cuentan con intersecciones pares, se intersecta una combinacion
  que incluya los 4 conjuntios*/
  ord_intersect(L12,L34,Ltot),
  tam_lista(Ltot,UDTC),
  Ptot is UDTC * 100 / F,
  write('Porcentaje de fallecimientos por los 4 serotipos: '), write(Ptot),nl.
  % quiza valga agregar el area con mayor numero de fallecimientos

metricas_areas:-
  area(X,_),
  metricas_areas(X).

metricas_areas(X):-
  write('INFORMACION DEL AREA '), write(X), nl,
  datos_area(X),nl,
  metricas_registroXarea(X),nl,
  metricas_infectadosXarea(X), nl,
  metricas_moyotesXArea(X),nl,
  metricas_defuncionesXarea(X),nl,
  Y is X - 1,
  Y>0,
  metricas_areas(Y).

metricas_areas(_):-
  !.

datos_area(X):-
  write('DATOS DEL AREA'), nl,
  cant_habXarea(X,residencia,LsR,R),
  cant_habXarea(X,trabajo,LsT,T),
  cant_habXarea(X,recreacion,LsD,D),
  mayorClave(['RESIDENCIAL','LABORAL','RECREATIVA'],[R,T,D],Tipo,_),
  write('Es principalmente '), write(Tipo),nl,
  write('Residentes del area: '), write(R),nl,
  write('Trabajan en el area: '), write(T),nl,
  write('Se recrean en el area: '), write(D),nl.

metricas_moyotesXArea(X):-
  write('DATOS DE LOS MOSQUITOS QUE HABITAN EL AREA'), nl,
  moyotesXarea(X,-1,M0),
  moyotesXarea(X,1,M1),
  moyotesXarea(X,2,M2),
  moyotesXarea(X,3,M3),
  moyotesXarea(X,4,M4),
  Mtot is M0+M1+M2+M3+M4,
  write('Totales: '), write(Mtot), nl,
  write('   Sanos: '), write(M0),
  write('   Serotipo 1: '), write(M1), nl,
  write('   Serotipo 2: '), write(M2), nl,
  write('   Serotipo 3: '), write(M3), nl,
  write('   Serotipo 4: '), write(M4), nl.

metricas_registroXarea(X):-
  write('REGISTRO HISTORICO COMPLETO DE INFECTADOS DEL AREA'), nl,
  infectadosXarea(X,1,I1),
  infectadosXarea(X,2,I2),
  infectadosXarea(X,3,I3),
  infectadosXarea(X,4,I4),
  /*opera los 4 conjuntos para saber el numero de infectados total
  sin duplicar los infectdos por dos o mas serotipos*/
  ord_union(I1,I2,I12),
  ord_union(I3,I4,I34),
  ord_union(I12,I34,ITodos),
  tam_lista(ITodos,NumI),
  write('Infectados totales: '), write(NumI), nl,
  tam_lista(I1,T1),
  tam_lista(I2,T2),
  tam_lista(I3,T3),
  tam_lista(I4,T4),
  write('   Serotipo 1: '), write(T1), nl,
  write('   Serotipo 2: '), write(T2), nl,
  write('   Serotipo 3: '), write(T3), nl,
  write('   Serotipo 4: '), write(T4), nl,
  write('Nota: una persona puede haber tenido mas de un serotipo'),
  write('Nota2: Incluye todos los infectados actuales y fallecidos,
  es un registro acumulado del area').

metricas_infectadosXarea(X):-
  write('INFECTADOS ACTUALES DEL AREA'), nl,
  fallecimientos(Lf,_),
  infectadosXarea(X,1,I1b),
  infectadosXarea(X,2,I2b),
  infectadosXarea(X,3,I3b),
  infectadosXarea(X,4,I4b),
  % Se restan los fallecimientos de los infectados para tener la poblacion viva
  ord_subtract(I1b,Lf,I1),
  ord_subtract(I2b,Lf,I2),
  ord_subtract(I3b,Lf,I3),
  ord_subtract(I4b,Lf,I4),
  /*Ae intersectan todos para conocer restar los folios duplicados de
  infectados de mas de un serotipo*/
  ord_union(I1,I2,I12),
  ord_union(I3,I4,I34),
  ord_union(I12,I34,ITodos),
  tam_lista(ITodos,NumI),
  write('Infectados vivos totales: '), write(NumI), nl,
  tam_lista(I1,T1),
  tam_lista(I2,T2),
  tam_lista(I3,T3),
  tam_lista(I4,T4),
  write('   Serotipo 1: '), write(I1), nl,
  write('   Serotipo 2: '), write(I2), nl,
  write('   Serotipo 3: '), write(I3), nl,
  write('   Serotipo 4: '), write(I4), nl,
  write('Nota: una persona puede haber tenido mas de un serotipo').

metricas_defuncionesXarea(X):-
  write('REGISTRO DE LAS DEFUNCIONES DEL AREA'), nl,
  fallecimientos(Lf,_),
  infectadosXarea(X,1,I1b),
  infectadosXarea(X,2,I2b),
  infectadosXarea(X,3,I3b),
  infectadosXarea(X,4,I4b),
  % Se restan los fallecimientos de los infectados para tener la poblacion viva
  ord_intersection(I1b,Lf,I1),
  ord_intersection(I2b,Lf,I2),
  ord_intersection(I3b,Lf,I3),
  ord_intersection(I4b,Lf,I4),
  /*Ae intersectan todos para conocer restar los folios duplicados de
  infectados de mas de un serotipo*/
  ord_union(I1,I2,I12),
  ord_union(I3,I4,I34),
  ord_union(I12,I34,ITodos),
  tam_lista(ITodos,NumI),
  write('Fallecidos totales: '), write(NumI), nl,
  tam_lista(I1,T1),
  tam_lista(I2,T2),
  tam_lista(I3,T3),
  tam_lista(I4,T4),
  write('   Serotipo 1: '), write(I1), nl,
  write('   Serotipo 2: '), write(I2), nl,
  write('   Serotipo 3: '), write(I3), nl,
  write('   Serotipo 4: '), write(I4), nl,
  write('Nota: una persona puede haber fallecido por mas de una serotipo').

  reporte_diario:-
    write('Reporte dia '), write(Date),nl,
    findall(Folio,persona(Folio,_,_,_,_,_,null),P),
    tam_lista(P,TP),
    write('Numero de habitantes: '), write(TP),nl,
    fallecimientos(_,TD),
    PD is 100 / ((TP/TD)+1)
    write('Numero de defunciones: '), write(TD),
    write(' ('), write(PD), write('%)'), nl,
    .
