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
func tableView(tableView: UITableView, 
  cellForRowAtIndexPath indexPath: NSIndexPath) -\> UITableViewCell {
return UITableViewCell()

}
~~~~~~

### Notificaciones
Cuando es complejo aproximarnos al componente fuente del evento para *subscribirnos* se usa el patrón que consiste en el envío de notificaciones. ¿Conoces NSNotificationCenter? CoreData lo utiliza por ejemplo para notificar cuando un contexto va a ejecutar una operación de guardado. El problema que tiene este patrón es que toda la información enviada se retorna en un diccionario, *UserInfo*, y el observador tiene que conocer previamente la estructura de este diccionario para poder interpretarlo. No hay por lo tanto seguridad ni en la estructura ni en los tipos enviados.

Las librerías reactivas disponibles actualmente ofrecen extensiones para pasar de esos patrones al formato reactivo. Desde generar señales para notificaciones enviadas al NSNotificationCenter, como para detectar los taps de un UIButton.

~~~~~~
NSNotificationCenter
  .defaultCenter()
  .addObserver(self, selector: "contextWillSave:", name: NSManagedObjectContextWillSaveNotification, object: self)
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
|> retry(2)
|> catch { error in
println("Network error occurred: \(error)")
return SignalProducer.empty
}
~~~~~~

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

~~~~~~
import ReactiveCocoa
~~~~~~

[1]:	https://github.com/ReactiveX/RxSwift "Fichero README del repositorio de RXSwift"
[2]:	https://github.com/Carthage/Carthage "Documentación de Carthage"
[3]:	https://github.com/CocoaPods/Specs/tree/master/Specs/ReactiveCocoa "Cocoapods specs para integrar ReactiveCocoa en los proyectos usando Cocoapods"
[4]:	https://cocoapods.org/ "Cómo empezar con CocoaPods"

[image-1]:	images/simple_operators.png "Operadores"
