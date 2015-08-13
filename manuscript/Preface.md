# Preface
Es probable que en estos momentos estés leyendo el libro porque seas desarrollador y desde hace tiempo sentías la curiosidad por **Reactive**. Yo la tenía hace tiempo pero cada vez que entraba a analizar este paradigma de programación no veía ventaja alguna que me motivara a cambiar la forma en la que ahora había estado programando.

La mayoría de de los desarrolladores estamos acostumbrados a programar de forma **imperativa**, que como bien su nombre indica consiste en dar órdenes. Decimos al programa **qué** tiene que hacer y las condiciones de ejecución:

- Presenta una nueva vista
- Descarga los datos de la API
- Actualiza la vista con los modelos que provienen de esta fuente de datos.

> **Programación Imperativa - Wikipedia**
> La programación imperativa, en contraposición a la programación declarativa, es un paradigma de programación que describe la programación en términos del estado del programa y sentencias que cambian dicho estado. Los programas imperativos son un conjunto de instrucciones que le indican al computador cómo realizar una tarea.

Entre otras **razones** programamos de esa forma porque los frameworks y la mayoría de recursos animan a hacerlo así, se trata de nuestra zona de confort. ¿Por qué si los recursos siguen un formato imperativo, las APIs de los frameworks de Cocoa también así como todos los totorales de internet, iba a cambiar mi forma de programar? 

*Para simplificar tu código y la lógica de tus aplicaciones.*

Más adelante entraré en más detalles en las ventajas y desventajas pero cuando empiezas a disfrutar con reactive verás como las APIs de tus componentes se simplifican y trabajar con ellas te sentirás como un niño, pero jugando con streams.

## ¿Por qué en Swift?

La razón de elegir Swift para este libro, aparte de porque mola *(y lo sabes)* se debe a varias razones:
- **Fluent Interface:** Es decir, abandonamos la sintaxis de corchetes característica de *Objective-C* dónde de encadenar varias operaciones tendríamos algo un fragmento de corchetes imposible de analizar, y en su lugar en Swift concatenamos las operaciones con un simple punto. La principal ventaja de las APIs Fluent[^1] es que la concatenación de varias operaciones es mucho más legible. El concatenar varios operadores aplicados a una fuente de datos es algo típico en la programación reactiva, por ello la importancia de tener esta característica en el lenguaje. Si observamos el ejemplo  a continuación concatenamos varias operaciones usando operadores custom para obtener finalmente una *señal* resultado de aplicar varias operaciones a la señal original\*

\~\~\~\~\~\~\~\~
searchTextField.rx\_text
	>- throttle(0.3, MainScheduler.sharedInstance)
	>- distinctUntilChanged
	>- map { query in
	    API.getSearchResults(query)
	        >- retry(3)
	        >- startWith([])
	        >- catch([])
	}
	>- switchLatest
\~\~\~\~\~\~\~\~

- **Operadores custom:** Que complementan a la sintaxis Fluent anterior. En el ejemplo anterior se está usando el operador custom `>-` que la propia librería ha definido para mapear una señal en otra señal después de haberle aplicado una **función**. El uso de funciones tiene mucha importancia en la programación reactiva pues serán la forma de manipular los streams de datos.

- **Generics y seguridad de tipos:** Con Objective-C era imposible specificar a la hora de definir un stream de datos cual iba a ser el formato de los datos que este stream iba a emitir. Se hacía uso de tipos genéricos NSArray, NSDictionary, NSObject, y las entidades consumidoras de esos datos acababan haciendo cast de los datos y validación *en tiempo de ejecución*. Gracias a Swift y a la introducción de generics, ahora es posible definir fuentes de eventos de un tipo determinado. Los consumidores conocen de antemano el tipo de los eventos introduciendo seguridad en tiempo de compilación.

## Aprendiendo Reactive

Me encanta aprender y transmitir los conocimientos adquiridos. De la misma forma que aprendemos de otros, otros podrán aprender de lo que nosotros enseñemos. En los recursos que puedas encontrar muestran ejemplos muy interesantes, pero que ves de forma muy idealizada y te preguntas si realmente acabarás teniendo un caso tan perfecto dentro de tu aplicación. Ese ese momento en el que o das un empujón y te adentras en estos conceptos, o abandonas. Yo lo hice, y ahora disfruto manipulando *señales* y *eventos*, y sobre todo más ahora cuando en Swift podemos definir nuestros propios operadores y tener seguridad en los tipos. Por ello me gustaría motivar de la misma forma a otros desarrolladores a que se animen y empiecen a usar *Reactive* en sus proyectos. 
Quería  que este libro además fuera cercano para cualquier desarrollador de OSX/iOS por lo que ofreceré ejemplos de interacción no sólo con los Frameworks del sistema sino con conocidos Frameworks con los que trabajamos a diario *(Alamofire, Realm, UIKit)*. Si después de este libro consigo que empieces a introducir elementos reactivos en tu proyecto, espero que lo disfrutes y que transmitas esa ilusión a otros desarrolladores. Recuerda:

- Si los conceptos te empiezan a saturar deja el libro pausado, toma un poco el aire y conecta más tarde. Es importante que los conceptos los aprendas bien para no perderte en las partes más avanzadas del libro.
- No te preocupes si al principio tienes problemas para asimilar los conceptos, no son fácilmente asimilables ya que requieren cambiar ligeramente la forma en la que pensamos respecto a las fuente de datos. Yo te ayudaré a que puedas entenderlo más fácilmente.
- Si aún así crees que algo no queda claro o se podría explicar de otra forma más fácil de entender, no dudes en contactarme, ¡hagamos de este libro una referencia para otros muchos desarrolladores que tengan ilusión por aprender!

[^1]:	API Fluent: [https://en.wikipedia.org/wiki/Fluent\_interface][1]

[1]:	https://en.wikipedia.org/wiki/Fluent_interface