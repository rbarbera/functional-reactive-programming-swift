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

Más adelante entraré en más detalles en las ventajas y desventajas pero cuando empiezas a disfrutar con reactive verás como las APIs de tus componentes se simplifican y trabajar con ellas se convertirá en un juego de manipulación de streams.

## ¿Por qué en Swift?
La razón de elegir Swift para este libro, aparte de porque mola *(y lo sabes)* se debe a varias razones:
- **Fluent Interface:** Es decir, abandonamos la sintaxis de corchetes característica de *Objective-C* dónde de encadenar varias operaciones tendríamos algo un fragmento de corchetes imposible de analizar, y en su lugar en Swift concatenamos las operaciones con un simple punto. La principal ventaja de las APIs Fluent[^1] es que la concatenación de varias operaciones es mucho más legible. El concatenar varios operadores aplicados a una fuente de datos es algo típico en la programación reactiva, por ello la importancia de tener esta característica en el lenguaje. Si observamos el ejemplo  a continuación concatenamos varias operaciones usando operadores custom para obtener finalmente una *señal* resultado de aplicar varias operaciones a la señal original*

~~~~~~~~
searchTextField.rx_text
    >- throttle(0.3, MainScheduler.sharedInstance)
    >- distinctUntilChanged
    >- map { query in
        API.getSearchResults(query)
            >- retry(3)
            >- startWith([]) // clears results on new search term
            >- catch([])
    }
    >- switchLatest
~~~~~~~~

- **Operadores custom:**

- **Seguridad de tipos:** 






La forma de programar está cambiando, en sus orígenes programábamos directamente con lenguajes de programación a más bajo nivel, programábamos directamente instrucciones que eran interpretadas por el sistema donde estas instrucciones eran ejecutadas. La evolución ha tendido hacia la abstracción, tratar de simplificar y facilitar la forma de expresarse al desarrollador pero sin perder por ello la potencia de trabajar a más bajo nivel. 


## Motivación
Me encanta aprender y transmitir los conocimientos adquiridos. De la misma forma que aprendemos de otros, otros podrán aprender de lo que nosotros enseñemos. Cuando empecé a dar mis primeros pasos en la *Reactive* es cierto que pensé en abandonar y seguir siendo feliz con lo que hasta ahora había estado haciendo ¿Por qué cambiar la forma de pensar de la noche a la mañana? Te muestran ejemplos muy interesantes, pero que ves de forma muy idealizada y te preguntas si realmente acabarás teniendo un caso tan perfecto dentro de tu aplicación. Ese ese momento en el que o das un empujón y te adentras en estos conceptos, o abandonas. Yo lo hice, y ahora disfruto manipulando *señales* y *eventos*, y sobre todo más ahora cuando en Swift podemos definir nuestros propios operadores y tener seguridad en los tipos. Por ello me gustaría motivar de la misma forma a otros desarrolladores a que se animen y empiecen a usar *Reactive* en sus proyectos. 
Quería  que este libro además fuera cercano para cualquier desarrollador de OSX/iOS por lo que ofreceré ejemplos de interacción no sólo con los Frameworks del sistema sino con conocidos Frameworks con los que trabajamos a diario *(Alamofire, Realm, UIKit)*. Si después de este libro consigo que empieces a introducir elementos reactivos en tu proyecto, espero que lo disfrutes y que transmitas esa ilusión a otros desarrolladores.

## TODO
Hacer una breve introducción al por qué del libro. 
- ¿De donde he aprendido a manejar los conceptos reactivos?

[^1]:	API Fluent: [https://en.wikipedia.org/wiki/Fluent\_interface][1]

[1]:	https://en.wikipedia.org/wiki/Fluent_interface
