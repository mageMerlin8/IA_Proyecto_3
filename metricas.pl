/*
Predicados para conseguir las métricas en un instante estático de la propagacion
*/

% Funciones Generales
tam_lista([],X):-
X=0.

tam_lista([_|Cola],Contador):-
tam_lista(Cola,Acumulado),
Contador = Acumulado + 1.

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

area_mayor_contagio(Area):-
  .

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
findall(Folio,persona(Folio,_,_,_,_,_,null),P),
tam_lista(P,TP),
write('Numero de habitantes: '), write(TP),nl,

fallecimientos(_,TD),
PD is 100 / ((TP/TD)+1),
write('Numero de defunciones: '), write(TD),
write(' ('), write(PD), write('%)'), nl,

personasXsepa(1,U),
personasXsepa(2,D),
personasXsepa(3,T),
personasXsepa(4,C),
TI is U + D + T + C,
PInf is TI * 100 / TP,
write('Numero de personas infectadas: '), write(TI),
write(' ('), write(PInf), write('%)'), nl,

mayorClave([1,2,3,4],[U,D,T,C],PeorSepa, Cont),
PSepa = Cont * 100 / TI,
write('Sepa de mayor contagio: '),write(PeorSepa),
write(' ('), write(PSepa), write('%)'), nl,

findall(Folio2,moyote(_,_,_,_,_),LM),
findal(Folio3,moyote(_,_,_,_,-1),LMSanos),
tam_lista(Lm,TM),
tam_lista(LMSanos, TMS),
TMEnf is TM - TMS,
PEnf is TMEnf *100/TM,
write('Poblacion de mosquitos: '), write(TM),nl,
write('Mosquitos infectados: '), write(TMenf),
write(' ('), write(Penf),write('%)'), nl.