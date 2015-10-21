# Conceptos Reactivos

## Signal

Una señal representa un stream de *eventos*. La forma de interpretar una señal es como un canal a través del cual una fuente de eventos hace llegar información a todos los subscriptores. Las señales en **ReactiveCocoa** envían eventos independientemente de que hayan o no subscriptores:

> Puedes encontrar escenarios en los que vayas a subscribirte a una señal y esta ya haya enviado algunos eventos. En otras librerías reactivas estas señales reciben el nombre de *Hot Signals* porque están emanando eventos en caliente sin que nadie se lo haya solicitado

**Algunos ejemplos de señales**
Si piensas en las fuentes de datos con las que estamos acostumbrados a trabajar a diario las que tienes a continuación podrían moldearse como señales:

- **Posiciones recibidas de GPS**: Activamos posicionamiento, esto nos retorna una señal que escuchamos. Cada nueva posición es un evento que se envía a través de la señal. Cuando no nos interese o el posicionamiento se desactive la señal se completará.
- **Texto introducido en un campo de texto**: El tiempo de vida de la señal sería el tiempo de vida de la vista donde este campo de texto está contenido. Si durante ese periodo el usuario introduce texto en ese campo lo recibiremos a través de la señal y podremos manipular y procesar esta información.
- **Recepción de notificaciones push**: Podemos en este caso modelar una señal que se mantiene activa durante el tiempo de vida de la aplicación y cuyos eventos son notificaciones push que han sido recibida y notificadas al AppDelegate de tu aplicación.

¿Suena interesante verdad? Los tres ejemplos anteriores usan el patrón de datos delegado para propagar información sobre lo sucedido a la entidad delegate de esos componentes. Más adelante aprenderemos cómo convertir cada uno de esos patrones a reactivo, de esta forma aprenderás a crear una señal de notificaciones push, o una señal de posiciones GPS que puedas usar dónde quieras en tu app.


## Signal Producer

Como su nombre indica, “producen señales”. Aunque después de escuchar esto igual nos hemos quedado igual, tranquilo. La forma más fácil de entender un SignalProducer es como una señal que sólo se ejecuta cuando se lo indicamos. Los productores de señales encapsulan acciones que son lanzadas cuando iniciamos al productor.

> Nota: Habrás percibido que los Signal y SignalProducers son genéricos y por lo tanto tienen asociados un tipo tanto de error como de data en el evento. Esto permite en cualquier paso del proceso de manipulación de los eventos, on incluso desde la posición de los subscriptores saber el tipo de información que se está enviando en cada momento. El uso de genéricos en estos componentes también asegura en tiempo de compilación que no estamos erróneamente mezclando tipos.

De ahora en adelante por simplificación hablaré simplementen de señales ya que debido a la definición de señal los conceptos presentados son intercambiables. Aquellos que no lo sean, serán explicados en detalle.

# Event
Un evento representa la información que se envía a través de los Signals y de los SignalProducers. Estos son modelados en ReactiveCocoa mediante un enum y los hay de distintos tipos:

- **Next**: Es el evento encapsula los datos enviados a través de la señal. El evento Next contiene objetos del tipo que haya definido la señal (recordamos que es un tipo genérico).
- **Error**: Como su nombre indica se trata de un evento que indica que algo sucedió en la operación. Los errores en ReactiveCocoa son structs del tipo `ErrorType`. Para aquellas señales que no envían errores se usa el tipo de error `NoError`. Más adelante veremos algunas situaciones en las que la señal puede no necesitar enviar errores.
- **Completed**: Este evento indica que la señal se ha completado y que por lo tanto ya no se recibirán más eventos del tipo `Next`.
- **Interrupted**: Si por alguna razón la señal es cancelada (es posible gracias al objeto *"Disposable"*) la señal es interrumpida y se notifica a los observers con el envío de este tipo de evento.



# Pipe & Buffer

# Observable

# Disposable

////// DON'T FORGET
- Mention the reference documentation: https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/BasicOperators.md
- Mention this util website: http://rxmarbles.com/
- Give examples with each reactive concept.
