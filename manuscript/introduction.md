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

A través de estos streams recibimos eventos que en algunos casos utilizaremos directamente pero que en otros nos interesará manipular previa su utilización. Aparece entonces el concepto de **Functional Reactive Programming** en la programación reactiva a través de **operadores** qué son definidos como funciones.

> Un operador aplicado sobre un stream o señal de eventos es una función que dada una señal de entrada retorna una señal de salida manipulando los eventos recibidos por la señal fuente.

![Ejemplo que muestra dos operadores, uno de mapeo donde los eventos de un stream son convertidos en otro tipo de eventos, y un operador de filtrado.][image-1]

El resultado de estas señales son eventos que han de ser **consumidos**. La subscripción puede ser realizada de dos formas:

- **Observando**: Podemos directamente observar la señal, para ello especificamos en un *closure* las acciones a ejecutar en función del tipo de evento que se reciba.
- **Bindeando**: La otra opción disponible es hacer binding de los  eventos que provienen del stream con un objeto o el atributo de un objeto determinado.

Por ejemplo, si tenemos un stream que envía colecciones de tareas para ser mostradas en una tabla y tenemos una colección que mantiene una referencia a la última colección retornada, podemos bindear una señal que retorna esas colecciones con esta colección de forma que esta siempre esté actualizada cuando la señal a la que está bindeado envíe nuevas colecciones. También es muy común hacer binding con elementos de UI. Por ejemplo, actualizar el estado de enabled de un botón en función de la validación de unos campos de texto. 

> Recuerda, en Reactive vamos a tener tres componentes principales **Streams (observables), Operadores y Bindings**. Más adelante veremos cada uno de ellos en detalle así como las operaciones que podemos realizar con ellos.

## ¿El origen de la programación Reactiva?
//TODO

## Patrones de observación
Cuando empecé a introducir los conceptos reactivos una de mis primeras inquietudes fue entender qué patrones similares había estado usando hasta ahora, que problemas presentaban, y de qué forma la programación reactiva ayudaba o facilitaba estos patrones. La mayoría de ellos los usas a diario:

### KVO
Extensivamente usado en Cocoa. Permite observar el estado de las properties de un objeto determinado y reaccionar antes sus cambios. El mayor problema de KVO es que no es fácil de usar, su API está demasiado recargada y todavía no dispone de una interfaz basada en bloques (o closures en Swift)

~~~~~~
objectToObserve.addObserver(self, forKeyPath: "myDate", options: .New, context: &myContext)
~~~~~~

### Delegados
Uno de los primeros patrones que aprendes cuando das tus primeros pasos en el desarrollo para iOS/OSX ya que la mayoría de componentes de los frameworks de Apple lo implementan. *UITableViewDelegate, UITableViewDataSource, …* son algunos ejemplos. El principal problema que presenta este patrón es que sólo puede haber un delegado registrado. Si estamos ante un escenario más complejo donde con una entidad suscrita no es suficiente el patrón requiere de algunas modificaciones para que pueda soportar múltiples delegados.

~~~~~~
func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -\> UITableViewCell {

return UITableViewCell()

}
~~~~~~

### Notificaciones
Cuando es complejo aproximarnos al componente fuente del evento para *subscribirnos* se usa el patrón que consiste en el envío de notificaciones. ¿Conoces NSNotificationCenter? CoreData lo utiliza por ejemplo para notificar cuando un contexto va a ejecutar una operación de guardado. El problema que tiene este patrón es que toda la información enviada se retorna en un diccionario, *UserInfo*, y el observador tiene que conocer previamente la estructura de este diccionario para poder interpretarlo. No hay por lo tanto seguridad ni en la estructura ni en los tipos enviados.

Las librerías reactivas disponibles actualmente ofrecen extensiones para pasar de esos patrones al formato reactivo. Desde generar señales para notificaciones enviadas al NSNotificationCenter, como para detectar los taps de un UIButton.

~~~~~~
NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextWillSave:", name: NSManagedObjectContextWillSaveNotification, object: self)
~~~~~~

## Ventajas
La programación reactiva tiene grandes ventajas usada en esos ámbitos donde es bastante directo aplicar el sentido de stream. Como bien comentaba al comienzo, todo puede ser modelado como un stream, y podrías de hecho tener un proyecto completamente reactivo pero bajo mi punto de vista, acabarías teniendo una compleja lógica de generación de streams que acabará dificultando la lectura del código.

> Con la programación Reactiva sucede algo similar a la programación Funcional. Se trata de un paradigma de programación que ha tenido un gran impulso en el desarrollo de iOS/OSX con la llegada de Swift pero no es necesario agobiarse y sentir una presión inmensa por migrar proyectos hacia esos paradigmas. Usa estos en tus proyectos a medida que te vayas sintiendo cómodo y notes que tu proyecto te los pide en determinadas partes. ¡Eras feliz sin ellos!, ahora puedes serlo incluso más, pero con tranquilidad…

Después de unos meses usando ReactiveCocoa en mis proyectos, especialmente en la parte relativa a la fuente de datos (local & remota) percibí una serie de ventajas:

- **Múltiples subscriptores:** Un stream no limita el número de subscriptores, pueden subscribirse tantos como deseen, todos ellos recibirán los eventos enviados por el stream de forma simultánea. Se pueden especificar incluso políticas de *buffer* para que nuevos subscriptores reciban eventos ya enviados anteriormente a otros subscriptores en lugar de volver a solicitar a la fuente el envío de eventos.
- **Seguridad de tipos:** Gracias al uso de genéricos podemos tener validación de tipos a nivel de compilador y evitar tener que estar trabajando con tipos genéricos como *AnyObject o NSObjects*.
- **Facilita la manipulación de datos:** Los eventos recibidos a través de los streams pueden ser mapeados, filtrados, reducidos. Gracias al uso de funciones definidas podemos aplicar infinidad de operaciones sobre los eventos.
- **Subscripción en threads:** Independientemente de la gestión interna de threads que pueda llevar a cabo la ejecución de un stream *(por ejemplo, una petición web)*, podemos indicar en qué thread subscribirnos para escuchar las respuestas. La forma de indicar el thread de subscripción se traduce en una simple linea de código.
- **Fácil composición y reusabilidad:** Los streams pueden ser combinados de infinitas formas *(gracias a los operadores que los propios frameworks facilitan)*. Además podemos generar los nuestros propios de forma que podamos obtener streams de eventos a partir de una combinación de otros muchos.
- **Gestión de errores:** Por defecto los frameworks reactivos dan la opción de reintentar la operación fuente del stream en el caso de fallo. Por ejemplo, si un stream recibe la respuesta de una petición web y queremos que está se reintente en el caso de fallo podemos usar el operador y la petición se volverá a ejecutar:

~~~~~~
NSURLSession.sharedSession().rac_dataWithRequest(URLRequest)
|\> retry(2)
|\> catch { error in
println("Network error occurred: \(error)")
return SignalProducer.empty
}
~~~~~
- **Simplificación de estados:** Debido al hecho de que la información se modela en un stream unidireccional. El número de estados que puedan introducirse se reduce simplificando la lógica de nuestro código

## Desventajas
- Acoplamiento con el framework
- Retain

## Frameworks para Swift
Actualmente en Swift existen varias opciones para trabajar con Reactive, las dos más populares **RXSwift** y **ReactiveCocoa**. La tabla inferior muestra una comparativa de frameworks disponibles *(extraída del [repositorio][1] de RXSwift)*

|                                                           | Rx[Swift]() |      ReactiveCocoa     | Bolts | PromiseKit |
|:---------------------------------------------------------:|:---------:|:----------------------:|:-----:|:----------:|
| Language                                                  |   swift   |       objc/swift       |  objc | objc/swift |
| Basic Concept                                             |  Sequence | Signal SignalProducer  |  Task |   Promise  |
| Cancellation                                              |     •     |            •           |   •   |      •     |
| Async operations                                          |     •     |            •           |   •   |      •     |
| map/filter/...                                            |     •     |            •           |   •   |            |
| cache invalidation                                        |     •     |            •           |       |            |
| cross platform                                            |     •     |                        |   •   |            |
| blocking operators for unit testing                       |     •     |                        |  N/A  |     N/A    |
| Lockless single sequence operators (map, filter, ...)     |     •     |                        |  N/A  |     N/A    |
| Unified hot and cold observables                          |     •     |                        |  N/A  |     N/A    |
| RefCount                                                  |     •     |                        |  N/A  |     N/A    |
| Concurrent schedulers                                     |     •     |                        |  N/A  |     N/A    |
| Generated optimized narity operators (combineLatest, zip) |     •     |                        |  N/A  |     N/A    |
| Reentrant operators                                       |     •     |                        |  N/A  |     N/A    |

** Comparison with RAC with respect to v3.0-RC.1

## Otras plataformas

[1]:	https://github.com/ReactiveX/RxSwift/blob/master/README.md


[image-1]:	images/simple_operators.png "Operadores"