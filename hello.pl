
hello:-write('hello world').

 % agentes
% Revisar vcuantas veces en 1 dia debio picar para poder reproducirse
mosquito(folioM,claveA, sexo, lifespan, cicloLastEaten, infectado).
persona(folioP,claveA_T, claveA_V, horaEntrada, horaSalida, sepa, hospital).
muerto([sepas], folioP).
% 1 es fijo como fuentes artificiales, 2 fuentes naturales constantes, 3 temporales naturales
cuerpoAgua(folioCuerpo, claveA, tipo, tam).
bultosHuevos(folioCuerpo, #huevos)
hospitalizado(folioP, dias)

mosquito(folio, sexo, cicloNac, lifespan, infectado).
picadura(folioM,folioP,ciclo).
persona(folio,[rec],[sepa] ).
persona_trabaja(folioP,folioA,hE,hS).
persona_vive(folioP,folioA).
lugar_agente(folioL,folioA).



  %Factores ambientales
area(claveA).
margenPanico(numero).

agentes_en_lugar(Lugar,Agentes):-
  findall(X,lugar_agente(Lugar,X),Agentes).

lugarAgente(hora,folio,claveA, dia).-
persona(Z,X,Y,E,S,_,0),
dia < 6
E>hora,
hora>S,
claveA = X,
folio =Z.

lugarAgente(hora,folio,claveA,dia).-
persona(Z,X,Y,E,S,_,0),
dia< 6,
hora<E,
hora>S,
claveA = Y,
folio =Z.

lugaragente(_,folio,claveA,_).-
persona(X,_,....),
randomArea(areaAletoria),
claveA=clavealeatoria,
folio.

personasEnArea(lista,hora, dia, claveA).-
repita,
luegarAgente(hora, folio, claveA, dia),
agregar(lista, folio).

mosquitosEnArea(lista, claveA, lista2).-
mosquito(folioM,claveA,macho,...),
agrega(lista, folioM, lista2).

picargente(dia, hora).-
area(claveA),
personasEnArea(lista, horas, dia,claveA),
mosquitosEnArea(lista2,...),
infectar()aquí hago picaduras y borro y declaro mosquitos y personas para agregar los infectados, si la persona tiene la misma sepa del mosquito no pasa nada.

modelarLluvia(listaArea, listaCantidad).-
cantagua>0,
% El numero de assets depende de la cantidad de agua
assert(cuerpoAgua(claveA,3, cantagua*5);
cuerpoAgua(X,claveA, 3, tam-4),
si tam-4 <0 retract cuerpoAgua(X, claveA,_,_).

mosquitoReproducir(folioM).-


ciclodia(numDia).-
porcada Area del 1 a 24 horas picar gente,
checo mosquitos:
si pico 1 vez no hace nada,
si pico 2, se reproduce,
si pico 0 se muere;
checo personas:
si tenia sepa previa y la infectan de nueva se muere,
si se infecto decide si ir al hospital o no y depende del numero de enfermos registrados,
si no se infecto, decide ir al hospital o no,
deshospitalizar gente actualizar sepa,
llover.

modelar(numerodias).-
del 1 al numero de dias
ciclodia(numerodias%7),
imprimir inforamacion final: picados, muertos, sanos, hospitalizados, por area: mosquitos sanos, mosquitos infectados.

ciclo():-
  current_ciclo(numero),
  dia(numero,D),
  hora(numero,H),
  %por cada agente:


  persona_trabaja(folioP,folioA,hE,hS).
ciclar_persona(folioP,numCiclo):-
  hora(numCiclo,H),
  persona_trabaja(folioP,Trabajo,He,Hs),
  (H = He, se va al trabajo, assert(lugar_agente(Trabajo,folioP), retract(lugar_agente(%buscar casa y se la pones))));
  (H = Hs, se va a su casa igual que arriba)
  (puede hacer otras cosas).
