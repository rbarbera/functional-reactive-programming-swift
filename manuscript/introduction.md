# Introduction to Reactive Programming

## What’s Reactive Programming (RP)?
You might have heard before about RP, even you might have seen some examples. According to **Wikipedia**

> In computing, reactive programming is a programming paradigm oriented around **data flows** and the propagation of change. This means that it should be possible to express static or dynamic data flows with ease in the programming languages used, and that the underlying execution model will automatically propagate changes through the data flow.
> For example, in an imperative programming setting,  would mean that  is being assigned the result of  in the instant the expression is evaluated. Later, the values of  and  can be changed with no effect on the value of .
> In reactive programming, the value of  would be automatically updated based on the new values.

We understand RP as a paradigm where the information/data/events flow in an “channel” and our program/logic reacts according to these events. These channels where the information flows through  are called **streams** and the information sent are **events**.
All the events that take place in our app are now **events sources**, and these sources are **observables**. When they send event, we’re responsible to operate with them, combining, mapping, filter, or just simply, use them. Some examples of streams could be:

1. A web request where the data source would be the API client, and the events sent, the responses from the server.
2. The tap event on a button. The button itself would be the data source and the taps on the button would be the actions.
3. GPS user positions received from CoreLocation.

You might have noticed that almost everything can be modelled as a stream of data, and you’re right. The components that you find in Cocoa framework and in most of libraries don’t offer public RP. Instead, you’ll find **extensions** that add the reactive behaviour to existing frameworks. We can then, create a native API to model user interactions with the app, the app with local data sources, and also, why not? with remote data sources.

The events received from these streams will be mostly used directly and won’t require any manipulation before using them, but one of the main advantages of RP is the ease of applying operators to these events. These operators are defined as a functions that can be applied to the stream. The term functional appears, and joins the paradigm RP, **Functional Reactive Programming**. We couldn’t imagine RP without the use of functional concepts.

> An operator applied to a  stream is a function that given an input stream it returns another stream manipulating the events received by the source stream.

![Ejemplo que muestra dos operadores, uno de mapeo donde los eventos de un stream son convertidos en otro tipo de eventos, y un operador de filtrado.][image-1]

When we *consume* these events we can do it in two ways:
- **Observing**: We can directly observe the stream, and specify in a *closure* the actions to be executed depending on the type of event.
- **Binding**: Connecting streams with existing object. Every time an event is received from the stream, it automatically updates the object *(or object property)*.

For example, if we have a stream that sends collections of tasks to be shown in a table, and we have a collection that keeps a reference to the last returned collection, we can bind the signal that returns these collections to the collection property. That way it always reflect the last state when the stream sends new collections. It’s also very common use binding for UI elements. For example, updating the state of enabled in a button using a function that validates some text streams.

> Remember, in FRP we’re going to have three main components **Streams (observables), Operators and Bindings**. Later, we’ll see each of them with more details and the available operations. 

## Observation patters
When I started with the reactive concepts one of my firsts concerns was understanding which similar patters I had been used so far, the problems they presented, and how FRP could help or make them easier. You probably use some of them daily:

### KVO
Extensively used in Cocoa. It allows observing the state of the properties of a given object, and react to the changes. The main problem with KVO is that it’s not easy to use, the API is overloaded and it doesn’t offer and API based on blocks (closures in Swift).

\~\~\~\~\~\~
objectToObserve.addObserver(self, forKeyPath: "myDate", options: .New, context: &myContext)
\~\~\~\~\~\~

### Delegates

Uno de los primeros patrones que aprendes cuando das tus primeros pasos en el desarrollo para iOS/OSX ya que la mayoría de componentes de los frameworks de Apple lo implementan. *UITableViewDelegate, UITableViewDataSource, …* son algunos ejemplos. El principal problema que presenta este patrón es que sólo puede haber un delegado registrado. Si estamos ante un escenario más complejo donde con una entidad suscrita no es suficiente el patrón requiere de algunas modificaciones para que pueda soportar múltiples delegados.

\~\~\~\~\~\~
func tableView(tableView: UITableView,
  cellForRowAtIndexPath indexPath: NSIndexPath) -\> UITableViewCell {
return UITableViewCell()

}
\~\~\~\~\~\~

### Notificaciones
Cuando es complejo aproximarnos al componente fuente del evento para *subscribirnos* se usa el patrón que consiste en el envío de notificaciones. ¿Conoces NSNotificationCenter? CoreData lo utiliza por ejemplo para notificar cuando un contexto va a ejecutar una operación de guardado. El problema que tiene este patrón es que toda la información enviada se retorna en un diccionario, *UserInfo*, y el observador tiene que conocer previamente la estructura de este diccionario para poder interpretarlo. No hay por lo tanto seguridad ni en la estructura ni en los tipos enviados.

Las librerías reactivas disponibles actualmente ofrecen extensiones para pasar de esos patrones al formato reactivo. Desde generar señales para notificaciones enviadas al NSNotificationCenter, como para detectar los taps de un UIButton.

\~\~\~\~\~\~
NSNotificationCenter
  .defaultCenter()
  .addObserver(self, selector: "contextWillSave:", name: NSManagedObjectContextWillSaveNotification, object: self)
\~\~\~\~\~\~

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

\~\~\~\~\~\~
NSURLSession.sharedSession().rac\_dataWithRequest(URLRequest)
|\> retry(2)
|\> catch { error in
println("Network error occurred: \(error)")
return SignalProducer.empty
}
\~\~\~\~\~\~

- **Simplificación de estados:** Debido al hecho de que la información se modela en un stream unidireccional. El número de estados que puedan introducirse se reduce simplificando la lógica de nuestro código

## Desventajas
La principal desventaja que presenta la programación reactiva es el **acoplamiento** que provoca el hecho de depender de un framework para realizar implementaciones reactivas. Al no ser soportado de forma nativa los conceptos reactivos el desarrollador tiene que recurrir a frameworks existentes. Si usas Reactive en toda la aplicación toda la aplicación dependerá de este framework, desde elementos de UI hasta elementos relativos a la fuente de datos.

Por ello es muy importante que elijas muy bien la librería reactiva con la que deseas trabajar, que tenga una buena comunidad y sea activa. Aunque pueda parecer un problema bastante importante que exista ese acoplamiento si pensamos un poco ya tenemos ese acoplamiento con otros muchos frameworks que estamos usando en nuestras apps.

> ¿Cuántos de vosotros no usa AFNetworking o Alamofire para el networking de las apps? O cuantos de vosotros no ha usado MagicalRecord para operaciones relacionadas con CoreData

El acoplamiento es inherente en nuestros proyectos, por eso lo importante en estos casos es asegurar que nos estamos acoplando a una librería **estable, testeada y con bastante soporte**.

Un problema que puede a parecer al usar Reactive y si se no se diseñan correctamente los componentes es que tengamos problemas con elementos retenidos en memoria. El hecho de que en Reactive los eventos son consumidos obliga a tener definido un **closure** que especifica qué eventos se envían por el stream.

Por esa razón es muy importante cuando definamos el comportamiento de esas fuentes de eventos:

- Entender los elementos involucrados en ese closure
- Entender la importancia de retenerlos o no en el closure.
- Definir el comportamiento si el estado de esos elementos varía en su contexto fuera del contexto reactivo.

> Por ejemplo, podemos definir una fuente de eventos que ejecute una petición web cuando alguien se subscribe a esta fuente. El closure que define esa operación usa un cliente HTTP que tenemos definido a nivel de app como una instancia Singleton. Si lo retenemos en el closure y en algún punto intentáramos liberarlo, por el hecho de estar retenido en el closure el cliente no se liberaría. O incluso peor, si cambiáramos su estado fuera del closure, podríamos no contemplar el nuevo estado y actuaríamos suponiendo estados erróneos.

## Frameworks para Swift
Actualmente en Swift existen varias opciones para trabajar con Reactive, las dos más populares **RxSwift** y **ReactiveCocoa**.
RXSwift ofrece en su repositorio una interesante [tabla][1] comparativa para entender las diferencias con entre RxSwift y otros frameworks *(algunos de ellos no usan directamente el paradigma reactivo)*

Ambos ofrecen los componentes básicos para trabajar con Reactive, y en el caso de RxSwift algunas ventajas y funcionalidad que no están presentes en ReactiveCocoa. Además la nomenclatura y los custom operators varían de uno a otro.

Mi recomendación es elegir uno de ellos y familiarizarte con él.  Hasta ahora no he encontrado nada bloqueante en ReactiveCocoa que me haya forzado a migrar todas mis implementaciones reactivas a RxSwift.

### Añadir ReactiveCocoa en tus proyectos
Para integrar ReactiveCocoa en tus proyectos lo puedes hacer de varias formas. Las dos recomendadas son usando Carthage, o usando Cocoapods.

**Carthage**
Se trata de la forma de integración por defecto. Si todavía no conoces Carthage te recomiendo echar un vistazo a su [documentación][2] donde explican como instalarlo en tu sistema. Una vez lo tengas:

1. Edita o crea el fichero **Cartfile** y añade la siguiente linea: `github "ReactiveCocoa/ReactiveCocoa"`
2. Después ejecuta el comando: `carthage update`
3. Sigue los pasos de la documentación de Carthage para añadir el framework generado al proyecto.

**Cocoapods**
ReactiveCocoa no ofrece soporte directo para CocoaPods pero existen `.podspec` no oficiales para integrarlo en tus proyectos usando Cocoapods, [enlace][3]. Estos `.podspec` están ya incluidos en la lista de CocoaPods con lo cual podemos definirlos directamente en nuestro **Podfile** para ello:

1. Edita o crea el fichero **Podfile**. Si no has usado Cocoapods anteriormente, en este [enlace][4] tienes más información sobre la estructura del fichero Podfile.
2. Añade la linea que especifica el pod de ReactiveCocoa `pod "ReactiveCocoa"`
3. Ejecuta el comando `pod install` para integrar ReactiveCocoa
4. Recuerda abrir el proyecto usando el fichero `.xcworkspace`


Ya tienes ReactiveCocoa en tu proyecto. Para usarlo desde Swift recuerda hacer el import del framework en cualquier fichero Swift donde vayas hacer uso del framework.

\~\~\~\~\~\~
import ReactiveCocoa
\~\~\~\~\~\~

[1]:	https://github.com/ReactiveX/RxSwift "Fichero README del repositorio de RXSwift"
[2]:	https://github.com/Carthage/Carthage "Documentación de Carthage"
[3]:	https://github.com/CocoaPods/Specs/tree/master/Specs/ReactiveCocoa "Cocoapods specs para integrar ReactiveCocoa en los proyectos usando Cocoapods"
[4]:	https://cocoapods.org/ "Cómo empezar con CocoaPods"

[image-1]:	images/simple_operators.png "Operadores"