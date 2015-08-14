# Introducción a la programación reactiva

## ¿Qué es?
Puede que antes hayas escuchado sobre la programación Reactiva, incluso puede que hayas visto algunos ejemplos anteriormente. Según **Wikipedia**

> In computing, reactive programming is a programming paradigm oriented around **data flows** and the propagation of change. This means that it should be possible to express static or dynamic data flows with ease in the programming languages used, and that the underlying execution model will automatically propagate changes through the data flow.
> For example, in an imperative programming setting,  would mean that  is being assigned the result of  in the instant the expression is evaluated. Later, the values of  and  can be changed with no effect on the value of .
> In reactive programming, the value of  would be automatically updated based on the new values.

Entendemos la programación reactiva como una forma de trabajar en la cual la información se recibe, y actuamos conforme a ella. Se asocia ese fluir de información con el concepto de **stream**
y cada información que se envía con **eventos** que se envían a través de ese stream.
El conjunto de sucesos que tienen lugar en nuestra aplicación se convierten en **fuentes de eventos**, son elementos **observables** y cuando estos envían algún eventos, somos nosotros, responsables de manipular esos eventos, combinarlos, y decidir qué hacer con ellos. Ejemplos de streams pueden ser:

1. Una petición web cuya fuente de datos sería el cliente de la API, y los eventos enviados, la respuesta del servidor.
2. El tap de un usuario sobre un botón, siendo la fuente de datos el propio botón y los eventos las acciones que ejecuta el usuario sobre el propio botón.
3. Las posiciones GPS del usuario que llegan desde el módulo GPS del dispositivo abstraído en un framework.

Habrás notado que prácticamente todo es modelaba como un stream de datos, estás en lo cierto. Los componentes que encuentras en el framework de Cocoa y en muchas librerías que puedas encontrar en internet no ofrecen este concepto en sus APIs. En su lugar encontrarás **extensiones** que añaden carácter reactivo a otros frameworks ya existentes. Podemos por tanto crear una API nativa para modelar interacciones del usuario con la app, de la app con fuentes de datos locales, y también ¿Por qué no? con fuentes de  datos remotos.

A través de estos streams recibimos eventos que en algunos casos utilizaremos directamente pero que en otros nos interesará manipular previa su utilización. Aparece entonces el concepto de **Functional Reactive Programming** en la programación reactiva a través de **operadores**

> Un operador aplicado sobre un stream o señal de eventos es una función que dada una señal de entrada retorna una señal de salida manipulando los eventos recibidos por la señal fuente.

![Ejemplo que muestra como los eventos de un stream pueden ser mapeados y convertidos en otro tipo de eventos][image-1]


## ¿Por qué?

## De donde viene reactive

## Patrones actuales

## Ventajas
- Simplificación del código
- API más leglible

## Desventajas
- Acoplamiento con el framework
- Retain

## Otras plataformas

 Qué es
- ¿Por qué?
- ¿De donde viene?
- Otras plataformas?
- 

[image-1]:	images/map_operator.png "Operador de mapeo"