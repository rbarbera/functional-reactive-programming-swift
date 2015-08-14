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

~~~~~~
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
~~~~~~

- **Operadores custom:** Que complementan a la sintaxis Fluent anterior. En el ejemplo anterior se está usando el operador custom `>-` que la propia librería ha definido para mapear una señal en otra señal después de haberle aplicado una **función**. El uso de funciones tiene mucha importancia en la programación reactiva pues serán la forma de manipular los streams de datos.

- **Generics y seguridad de tipos:** Con Objective-C era imposible specificar a la hora de definir un stream de datos cual iba a ser el formato de los datos que este stream iba a emitir. Se hacía uso de tipos genéricos NSArray, NSDictionary, NSObject, y las entidades consumidoras de esos datos acababan haciendo cast de los datos y validación *en tiempo de ejecución*. Gracias a Swift y a la introducción de generics, ahora es posible definir fuentes de eventos de un tipo determinado. Los consumidores conocen de antemano el tipo de los eventos introduciendo seguridad en tiempo de compilación.

## Un libro, una aventura
No me gusta hablar de mí, pero creo necesario un poco de contexto para entender las razones que me llevaron a este punto.
Mi nombre es Pedro Piñera Buendía, en la mayoría de redes sociales me puedes encontrar como *@pepibumur*. Aunque soy Graduado en Tecnologías y Servicios de Telecomunicación *(es decir, Teleco)*, mi actividad profesional la he desarrollado principalmente como desarrollador móvil.

En 2010 cuando comenzaba la Universidad en Valencia, me hice con mi primer Macbook Pro, fue por aquél entonces cuando di mis primeros pasos con la programación. No se trataba ni de Objective-C, sino de **C**. El profesor de la asignatura de primero insistía en la importancia de enseñar C como lenguaje de programación para alumnos que no hayan hecho programación antes en su vida. Se negaba totalmente a enseñar Java, y a introducir la programación orientada a objetos sin tener claros los conceptos bases de programación, tipos, funciones, operadores básicos…

> Recuerdo a compañeros sudando para acabar una práctica con los conceptos más básicos de C ¿Qué hubiera pasado si el profesor hubiese introducido programación orientada a objetos?

Aparte de C también trabajábamos con otros dos lenguajes de programación, **Matlab** para prácticamente casi todas las asignaturas de la carrera y **Java** que lo usábamos para pequeñas aplicaciones que replicaban servicios telepáticos tales como “implementación de un servidor web”, “implementación de un servidor de DNS”, …

Por aquél entonces Java me parecía muy feo, no entendía el por qué de esa sintaxis tan compleja, algunos elementos los usaba sin ni siquiera entender el por qué. 

Unos meses más tarde descargué **XCode** y con la ayuda de algunos tutoriales en internet, empecé a hacer pruebas con Objective-C. Fue con este lenguaje con el que me fui introduciendo en la **Programación Orientada a Objetos** y en los patrones de diseños de Apple. Recuerdo leer qué era el patrón *Delegate* y tener que releerlo varias veces para conseguir entenderlo. También recuerdo gestionar el *reference counting* manualmente sin ni siquiera tener claro del todo de qué se trataba. Empecé a aprender el lenguaje como si estuviera explorando una selva, a base de experimentar, probar, fallar, y recurrir a un montón de recursos disponibles online *(también me hice con algunos libros que todavía conservo)*.

De estos primeros años con Objective-C salieron algunas apps que todavía están disponibles en la App Store y cuyo código puede ser lo más parecido a un plato de espaguetis. Durante los siguientes años fui lanzando varias aplicaciones, cada una más completa que la anterior, pero sin enfocarme en temas tan importante en proyectos de software como **arquitectura, patrones, organización del código, escalabilidad, …**

> Si tienes curiosidad por algunas de las aplicaciones desarrolladas y lanzadas durante este periodo puedes echar un vistazo mi [perfil en la  App Store][2] o si lo prefieres, en mi [perfil de Github][3] donde además distribuyo como librerías Open Source distintos frameworks en los que he trabajado.

Fue ya en el verano de 2014 cuando entré a formar parte en el equipo de desarrollo de **Redbooth**, startup de Barcelona cuyo producto era una herramienta de gestión de tareas para empresas. A Redbooth entramos tanto mi compañero, *Isaac Roldán*, como yo, y fue durante el año que estuve trabajando en esta empresa donde considero que crecí enormemente como desarrollador. Aprendí aspectos tales como:
- Trabajo en equipo
- Organización de proyectos y metodologías ágiles
- Importancia de la arquitectura y el estilo del código.
- Git & Github *(lo sé, me enamoré un poco tarde, pero ahora no puedo vivir sin él)*
- Primeros pasos en Android *(todavía recuerdo lo angustioso que era dejar Objective-C para desarrollar en Java y esperar a que Gradle decidiera compilar el proyecto)*

Un año más tarde me uní al proyecto **8fit**[^2] pasando a ser responsable Lead del equipo Mobile de la empresa. El proyecto estaba empezando y tenía un largo camino por delante no solo en el desarrollo para iOS sino también en Android. Durante el tiempo que llevo en 8fit he tenido la libertad de experimentar y de seguir probando:
- Desde las primeras versiones de **Swift** hemos ido añadiendo nuevos componentes a la aplicación escritos totalmente en Swift. De hecho hemos traído la filosofía de Swift al proyecto y cualquier nuevo componente deberá estar forzadamente escrito y testado en Swift.
- Desarrollamos una aplicación para **Apple Watch**
- Interacción de web con implementaciones nativas y diseño de migración hacia un approach de features completamente nativo.
Además tener la posición de Lead me ha permitido crecer en el ámbito organizativo y aprender técnicas y trucos para coordinar, gestionar, motivar y alinear a un grupo humano con las necesidades de un proyecto.

Mi primer contacto con Reactive vino sin embargo con un proyecto que llevo desarrollando durante unos meses en mi tiempo libre con algunos compañeros del gremio, e trata de **GitDo**[^3].  

> Gitdo es una aplicación para iOS/OSX que facilita la gestión de issues de Github gracias a un nuevo formato basado en gestión de tareas y a la integración nativa con las plataformas móviles y de escritorio. [Enlace][4]

Fue en el desarrollo del **Core** de esta aplicación donde implementé toda la fuente de datos y lógica de negocios de forma reactiva, y fue entonces cuando descubrí las ventajas de la programación Reactiva, especialmente en su uso con Swift. Desde entonces he ido trasladando Reactive a otros proyectos, incluido 8fit y promoviendo el concepto de Reactive en el que muchos desarrolladores tienen miedo a adentrarse.

Mi gran ilusión en estos momentos es poner en marcha este proyecto y viajar por el mundo desarrollando y manteniendo la aplicación que ayude entre otros a desarrolladores como tú que quieran centrar toda la gestión de sus proyectos en Github. Con tu compra del libro ayudarás al desarrollo de esta aplicación, que esperamos tener disponible en breve. Muchas gracias por todo y espero que disfrutes del libro así como yo lo he hecho escribiéndolo.

   
## Enseñando Reactive

Disfruto aprendiendo y transmitiendo los conocimientos adquiridos. De la misma forma que aprendemos de otros, otros podrán aprender de lo que nosotros enseñemos. En los recursos que puedas encontrar muestran ejemplos muy interesantes, pero que ves de forma muy idealizada y te preguntas si realmente acabarás teniendo un caso tan perfecto dentro de tu aplicación. Ese ese momento en el que o das un empujón y te adentras en estos conceptos, o abandonas. Yo lo hice, y ahora disfruto manipulando *señales* y *eventos*, y sobre todo más ahora cuando en Swift podemos definir nuestros propios operadores y tener seguridad en los tipos. Por ello me gustaría motivar de la misma forma a otros desarrolladores a que se animen y empiecen a usar *Reactive* en sus proyectos. 
Quería  que este libro además fuera cercano para cualquier desarrollador de OSX/iOS por lo que ofreceré ejemplos de interacción no sólo con los Frameworks del sistema sino con conocidos Frameworks con los que trabajamos a diario *(Alamofire, Realm, UIKit)*. Si después de este libro consigo que empieces a introducir elementos reactivos en tu proyecto, espero que lo disfrutes y que transmitas esa ilusión a otros desarrolladores. Recuerda:

- Si los conceptos te empiezan a saturar deja el libro pausado, toma un poco el aire y conecta más tarde. Es importante que los conceptos los aprendas bien para no perderte en las partes más avanzadas del libro.
- No te preocupes si al principio tienes problemas para asimilar los conceptos, no son fácilmente asimilables ya que requieren cambiar ligeramente la forma en la que pensamos respecto a las fuente de datos. Yo te ayudaré a que puedas entenderlo más fácilmente.
- Si aún así crees que algo no queda claro o se podría explicar de otra forma más fácil de entender, no dudes en contactarme, ¡hagamos de este libro una referencia para otros muchos desarrolladores que tengan ilusión por aprender!

[^1]:	API Fluent: [https://en.wikipedia.org/wiki/Fluent\_interface][1]

[^2]:	http://8fit.com

[^3]:	http://gitdo.io

[1]:	https://en.wikipedia.org/wiki/Fluent_interface
[2]:	https://itunes.apple.com/es/artist/pedro-pinera-buendia/id454075497
[3]:	https://github.com/pepibumur "Github pepibumur"
[4]:	http://gitdo.io