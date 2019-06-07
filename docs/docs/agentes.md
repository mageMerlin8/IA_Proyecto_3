# Agentes
En este módulo se definen todas las interacciones de bajo nivel con la base dinámica del lenguaje. Se puede entender como un manejador de base de datos.  [La base de datos completa](diagrama_base.png) maneja toda la información de los agentes en cada momento del tiempo.


Se crearon los siguientes tipos de agentes:

- Personas: `persona/7`
- Mosquitos: `moyote/5`
- Huevos: `bulto_huevos/5`
- Agua(charco): `agua_var/4`

Además todos los agentes están relacionados con algún área (`area/3`) a través de varios predicados dinámicos.

## Área
Predicado dinámico que guarda la información acerca de un área. Todos los agentes deben estar en algún area si están vivos y sanos.

Las áreas adyacientes geográficamente se asignan como `areas_vecinas(F1,F2)` o bien, como aristas de una gráfica sin direccion.

La información de sus parámetros es del siguiente orden:

- `folio` índice en la base de datos
- `const_encharcamiento` número entero en proporción al número de depósitos de agua que se crean cuando llueve en el agua.
- `densidad_poblacional` número entero que representa la proporción de poblacion que hay en el área.

#### Funciones principales

- `crea_area(F,C,D)` : crea un área con folio F, const_encharcamiento C y densidad poblacional D.
- `asigna_vecinos(Vecinos)` : Vecinos es la lista de aristas (lista de dos elementos donde cada elemento es el folio de un área distinta) de la grafica de las áreas.

## Persona
[Persona](diag_persona.png)
Persona es uno de los principales agentes. Persona modela el comportamiento básico de las personas: va y viene al trabajo a su horario y va a areas recreativas en su tiempo libre.
La información de sus parámetros es del siguiente orden:

- `folio` índice en la base de datos
- `area_hogar` relación a área del lugar dónde la persona duerme y vive
- `area_trabajo` relación a área del lugar dónde la persona trabaja
- `hora_entrada` número entero de la hora del dia (0-23) de la entrada al trabajo.
- `hora_salida` número entero de la hora del dia (0-23) de la salida al trabajo.
- `hospitalizado?` booleana que indica si la persona está hospitalizada.
- `fecha_muerte` número entero que guarda el ciclo en el que muere la persona.

#### Funciones principales

- `crea_persona_empleo_normal(AreaH,AreaT)` : crea una persona con área de hogar AreaH y área de trabajo AreaT. Con horario de trabajo de 9 a 17.
- `mover_persona(Folio,Area)` : Mueve a la persona con folio Persona al área Area.
- `matar_persona(Folio,Fecha)` : Hace los cambios necesarios para que la persona con folio Folio se guarde como muerta. Esta persona ya no es parte de la poblacion (no está en algún área).
- `hospitalizar_persona(Folio)` : Quita a la persona con folio Folio de todas las áreas y modifica el parametro de hospitalización.
- `deshospitalizar_persona(Folio)` : Regresa a la persona con folio Folio a su rutina normal.
- `cambiar_trabajo_persona(Folio,Area_trabajo,HoraEntrada,HoraSalida)`
- `agregar_area_rec_persona(FolioP,FolioA)`
- `quitar_area_rec_persona(FolioP,FolioA)`

## Moyote

> Nota: relevante Moyote es otra palabra para mosquito.


[Moyote](diag_moyote.png) es uno de los principales agentes. Moyote modela el comportamiento básico de los mosquitos: estos viven en un área toda su vida, comen durante el dia y ponen huevos cuando llenan su tanque.

La información de sus parámetros es del siguiente orden:

- `folio` índice en la base de datos
- `area_hogar` relación a área del lugar dónde la persona duerme y vive
- `fecha_nacimiento` numero entero que guarda el ciclo en el que nace el mosquito.
- `ciclos` número entero del número máximo de ciclos que puede vivir el mosquito.
- `infeccion` número entero de la sepa de infeccion del mosquito. Es -1 si no está infectado.

El tanque del moyote se guarda como un float del 0 al 1 que representa el porcentaje de llenado. El tanque se incrementa con `llena_tanque_moyote(Moyote,Cant)`. Además, los moyotes dejan de comer durante un periodo de incubación una vez que deciden poner huevos. Para manipular el periodo de incubación se utilizan los predicados `set_ciclos_hasta_parir_moyote(Moyote,Ciclos)` y `baja_ciclos_hasta_parir_moyote(Moyote,Ciclos)`

Esta información se guarda por separado del moyote porque se modifica con mucha más frecuencia que los demás atributos.
El tanque del moyote se guarda en un predicado separado (`c_moyote/3`) porque se modifica con frecuencia.




#### Funciones principales

- `infectar_moyote(Folio,Sepa)` : infecta al moyote con folio Folio de la sepa Sepa.
- `crea_moyote(Area,FechaN,Ciclos,Infeccion)`
- `crea_moyote_auto(Area,FechaN,Infeccion)`
- `crea_moyote_sano(Area,FechaN,Ciclos)`
- `crea_n_moyotes_auto(Area,FechaN,Inf,N)`
- `mata_moyote(Folio)`


## Huevos/Agua

[Diagrama.](diag_moyote.png)
