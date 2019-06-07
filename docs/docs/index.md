# Inteligencia Artificial Proyecto Final

Se realizó un sistema multi agente para modelar la propagación del dengue en Medellín, Colombia. La modelación de agentes y el entorno se realizó en SwiProlog por requerimientos de la clase. Se utilizó python para analizar la información generada. El documento escrito entregado para la materia se puede encontrar [aqui](https://github.com/mageMerlin8/IA_Proyecto_3/blob/master/docs/docs/modelado_multiagente.pdf).

## Módulos del Sistema de Simulación

* `agentes.pl` - Define la creación y desctrucción de todos los agentes dentro de la base de datos.
* `comportamiento.pĺ` - Define el comportamiento de los agentes.
* `datos_prueba.pl` - Genera un entorno de prueba (con agentes) suficiente para correr las pruebas.
* `generadores.pl` - Funciona muy parecido al módulo datos_prueba pero genera datos modelando Medellín.
* `metricas.pl` - Módulo encargado de imprimir métricas acerca del estado actual de la simulacion.
* `simulacion.pl` - Módulo encargado de correr la simulacion.
