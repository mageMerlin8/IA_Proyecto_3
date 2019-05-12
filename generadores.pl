/*GENERADORES DE agentes
*
*algunos son generados de forma aleatoria,
*otros, como las areas, son dados de forma explicita
*pues modelan de forma constante informacion especifica para imitar
*un ambiente real, por ejemplo Colima o Medellín*/

:-include(agentes).

area(15,4,1).
area(14,1,3).
area(13,2,4).
area(12,4,1).
area(11,3,2).
area(10,4,4).
area(9,4,3).
area(8,2,5).
area(7,1,5).
area(6,4,4).
area(5,4,2).
area(4,3,4).
area(3,3,5).
area(2,4,2).
area(1,5,1).
crea_medellin:-

  Vecinos = [
  % areas_vecinas(1,9).
  [1,9],
  % areas_vecinas(1,10).
  [1,10],
  % areas_vecinas(2,3).
  [2,3],
  % areas_vecinas(2,7).
  [2,7],
  % areas_vecinas(2,8).
  [2,8],
  % areas_vecinas(2,10).
  [2,10],
  % areas_vecinas(2,13).
  [2,13],
  % areas_vecinas(3,4).
  [3,4],
  % areas_vecinas(3,7).
  [3,7],
  % areas_vecinas(3,8).
  [3,8],
  % areas_vecinas(3,10).
  [3,10],
  % areas_vecinas(3,11).
  [3,11],
  % areas_vecinas(3,12).
  [3,12],
  % areas_vecinas(3,14).
  [3,14],
  % areas_vecinas(4,8).
  [4,8],
  % areas_vecinas(4,14).
  [4,14],
  % areas_vecinas(4,15).
  [4,15],
  % areas_vecinas(5,8).
  [5,8],
  % areas_vecinas(5,13).
  [5,13],
  % areas_vecinas(6,9).
  [6,9],
  % areas_vecinas(6,10).
  [6,10],
  % areas_vecinas(6,11).
  [6,11],
  % areas_vecinas(7,10).
  [7,10],
  % areas_vecinas(8,13).
  [8,13],
  % areas_vecinas(9,10).
  [9,10],
  % areas_vecinas(10,11).
  [10,11],
  % areas_vecinas(11,12).
  [11,12],
  % areas_vecinas(14,15).
  [14,15]
  ],
  %asignar vecinos
  asigna_vecinos(Vecinos),
  %crear urbe
  generar_urbe(1000,5000,0.1).
recreativas([1,2,3,4,5]).
laborales([6,7,8]).
areas([15,14,13,12,11,10,9,8,7,6,5,4,3,2,1]).

/*GENERA TODA LA URBE*/
% Infectados puede ser un porcentaje entre 0.0 y 1.0
generar_urbe(NumPersonas, NumMosquitos, PorcentajeI):-
    generar_personas(NumPersonas),
    generar_mosquitos_porcentaje(NumMosquitos,PorcentajeI).

% Este genera con cantidad de infectados especifica
generar_urbe2(NumPersonas, NumMosquitos, CantInfectados):-
    generar_personas(NumPersonas),
    generar_mosquitos_cantidad(NumMosquitos,CantInfectados).

%recibe los mosquitos por porcentaje un real entre 0.0 y 1.0)
generar_urbe_menosSepas(NumPersonas, NumMosquitos, PorcentajeI, NumSepas):-
    generar_personas(NumPersonas),
    generar_mosquitos_porcentaje(NumMosquitos,PorcentajeI,NumSepas).

/*PREDICADO GENERICOS*/

pos_from([X|_],Casilla,X):-
    Casilla is 1,!.

pos_from([_|Y],Casilla,X):-
    Nueva is Casilla - 1,
    pos_from(Y,Nueva,X).

getCabeza([X|_],X).

get_from_list([X|_],_,Pos,I,X):-
    I = Pos,!.

get_from_list([_|Y],[A|B],Pos,I,Resp):-
    INuevo is I-1,
    INuevo < A,
    get_from_list(Y,B,Pos,INuevo,Resp).

get_from_list(X,A,Pos,I,Resp):-
    INuevo is I-1,
    get_from_list(X,A,Pos,INuevo,Resp).


/*PREDICADOS AUXILIARES A LOS GENERADORES*/

getProbas(mosquitos,Probas,Tope):-
    findall(Densidad,area(_,Densidad,_),Densidades),
    enlazar_densidades(Densidades,[Tope|Probas]).

getProbas(habitantes,Probas,Tope):-
    findall(Densidad,area(_,_,Densidad),Densidades),
    enlazar_densidades(Densidades,[Tope|Probas]).

  /*La lista final representa los intervalos de probabilidad que tiene cada
  area de tener habitantes, probabilidades que reflejan la densidad esperada
  en cada area*/

enlazar_densidades([],[1]):-!.

enlazar_densidades([X|Y],[NuevoTope|LPrevia]):-
    enlazar_densidades(Y,LPrevia),
    getCabeza(LPrevia,Tope),
    NuevoTope is X + Tope.

asignar_horarios(H_E,H_S):-
    random(1,4,RanEntrada),
    pos_from([7,8,9],RanEntrada,H_E),
    random(1,5,RanSalida),
    pos_from([15,16,17,18],RanSalida,H_S).

/*Se asume que existen personas que trabajan en areas residenciales
de entre las cuales algunas son amas de casa y freelancers por lo que
trabajan en la misma area donde reciden. Lo mismo sucede para los
desempleados y jubilados. Para este modelo se */
asignar_area_laboral(A_T,A_H):-
  /*% 1/3 de la poblacion estara en su casa en horas laborales, lo que
  corresponde a amas de casa, jubilados, freelancers y desempleados*/
    random(1,4,Prob),!,
    asignar_area_laboral(Prob,A_T,A_H).

asignar_area_laboral(1,A_H,A_H).

/*Entra a este metodo en caso de no trabajar desde casa, pero se vuelve a
manejar un random donde 1/3 parte de la poblacion labora en areas residenciales
y 2/3 partes se concentran en laborales*/
asignar_area_laboral(_,A_T,_A_H):-
    random(1,4,Prob),!,
    getRandom_area_laboral(Prob,A_T).

getRandom_area_laboral(1,A_T):-
    random(1,6,A_T),!.

getRandom_area_laboral(_,A_T):-
    random(6,9,A_T).

/*No todas las areas tienen la misma densidad poblacional, y se puede vivir
en todas independientemente de que sean primordialmente recreativas, laborales
o residenciales. La distribución de probabilidad que cada area tiene se
establecio previamente con base en la ciudad que deseaba modelarse*/


asignar_area_hogar(A_H):-
    areas(Ls),
    getProbas(habitantes,Probas,Tope),
    /*Al usar random las probabilidades se multiplicaban modificandose, para
    resolverlo se opto por repartir la poblacion linealmente sobre la
    lista de probabilidades. Es decir, se generan ciclos de distribucion que
    van llenando las areas de 1 en 1 hasta que su -cupo- esta lleno y se
    pasa a poblar la que sigue*/
    % Tope2 is Tope + 1, random(1,Tope2,Pos),
    get_folio_persona(Folio),
    PosAux  is  Folio mod Tope,
    % la division modular del tope da 0 por lo que debe cambiarse el valor de
    % la posicion 0 por el tope
    revisarPos(PosAux, Tope, Pos),
    get_from_list(Ls,Probas,Pos,Tope,A_H).

revisarPos(0,Tope,Tope).
revisarPos(X,_,X).

asignar_area_mosquito(A_H):-
    areas(Ls),
    getProbas(mosquitos,Probas,Tope),
    /*Sucede lo mismo que en el metodo de arriba -asignar_area_hogar*/
    % Tope2 is Tope + 1, random(1,Tope2,Pos),
    get_folio_mosquito(Folio),
    PosAux  is  Folio mod Tope,
    revisarPos(PosAux, Tope, Pos),
    get_from_list(Ls,Probas,Pos,Tope,A_H).

  /*el primer assert de Folio se hace al crearse el primer agente,
  por eso debe obtenerse aparte*/
get_folio_persona(Folio):-
  folio_persona(F),
  % El folio es del actual, se desea el siguiente numero, corresponde al nuevo agente
  Folio is F + 1.
get_folio_persona(0).

get_folio_mosquito(Folio):-
  folio_moyote(F),
  Folio is F + 1.
get_folio_mosquito(0).



/*CODIGO PARA CREAR N PERSONAS
llama predicados auxiliares para asignar areas*/

generar_personas(0):-
    asignar_recreativas.

generar_personas(Num):-
    asignar_area_hogar(A_H),
    asignar_area_laboral(A_T,A_H),
    asignar_horarios(H_E,H_S),
    crea_persona(A_H,A_T,H_E,H_S),
    TotalNuevo is Num - 1,
    generar_personas(TotalNuevo).

getRecreativas(1,Folio,[X]):-
    recreativas(Ls),
    random(1,6,Pos),
    pos_from(Ls,Pos,X),
    assert(persona_area_recreativa(Folio,X)),!.

getRecreativas(Cant,Folio,Ls):-
    CantNueva is Cant -1,
    getRecreativas(CantNueva,Folio,LPrev),
    recreativas(LR),
    ord_subtract(LR,LPrev,LRestantes),
    Faltantes is 6 - CantNueva,
    random(1,Faltantes,Pos),
    pos_from(LRestantes,Pos,X),
    assert(persona_area_recreativa(Folio,X)),
    ord_union([X],LPrev,Ls).

asignar_recreativas:-
    persona(Folio,_,_,_,_,_,_),
    random(1,6,NumAreasR),
    getRecreativas(NumAreasR,Folio,_),
    fail.
% asignar_recreativas(N,Persona,)

/*CODIGO PARA CREAR N MOSQUITOS CON M INFECTADOS DADO UN RANGO DE SEPAS*/
% Si las sepas no se indican se generan de las 4
generar_mosquitos_porcentaje(Sanos, PInfectados):-
  % Envia al metodo con las 4 sepas por default
    generar_mosquitos_porcentaje(Sanos,PInfectados,4).

generar_mosquitos_porcentaje(Sanos, PInfectados, Aux):-
    Aux is PInfectados * Sanos,
    round(Aux,Infectados),
    generar_mosquitos_cantidad(Sanos,Infectados, Aux).

generar_mosquitos_cantidad(Sanos, Infectados):-
  % Manda con las 4 sepas por default
    generar_mosquitos_cantidad(Sanos,Infectados,4).

generar_mosquitos_cantidad(0,0,_):-!.

generar_mosquitos_cantidad(Sanos,Infectados,Aux):-
    random(1,21,Dado),
    asignar_sepa(Dado,Sanos,Infectados,Sanos2,Infectados2,Tipo_I),
    asignar_area_mosquito(Area),
    crea_moyote_auto(Area,0,Tipo_I),
    generar_mosquitos(Sanos2,Infectados2,Aux).

asignar_sepa(_,X,0,Sanos,0,-1):-
    Sanos is X -1.

asignar_sepa(1,Sanos,Infectados,Sanos,Infectados2,1):-
    Infectados2 is Infectados-1.

asignar_sepa(2,Sanos,Infectados,Sanos,Infectados2,2):-
    Infectados2 is Infectados-1.

asignar_sepa(3,Sanos,Infectados,Sanos,Infectados2,3):-
    Infectados2 is Infectados-1.

asignar_sepa(4,Sanos,Infectados,Sanos,Infectados2,4):-
    Infectados2 is Infectados-1.

asignar_sepa(_,Sanos, Infectados, Sanos2, Infectados,-1):-
    Sanos2 is Sanos-1.



/*CODIGO PARA CREAR LOS CUERPOS DE AGUA DE LAS AREAS*/

generar_cuerpos_agua:-
    area(Clave,Encharcamiento,_),
    % Genera entre 100 y 200 cuerpos
    Cant is 22 * Encharcamiento + 88,
    crear_cuerpos_agua(Clave,Cant),
    fail.

crear_cuerpos_agua(_,0):-!.

crear_cuerpos_agua(Area,Cant):-
    random(100,501,CapH),
    random(1,6,Aux),
    revisar_porcentaje(Aux,Cap),
    P_Vaciado is Cap/10.0,
    crea_agua_var(Area,CapH,P_Vaciado),
    Cant2 is Cant -1,
    crear_cuerpos_agua(Area,Cant2).

% cambia el 4 por siete para obtener solo 0.1, 0.2, 0.3, 0.5 y 0.7
revisar_porcentaje(4,7).
revisar_porcentaje(X,X).
