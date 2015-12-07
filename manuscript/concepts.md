# Concepts

## Signal

A signal represents a stream of *events*. Think on a signal as an encapsulated operation that sends events of its execution status. Three kind of events are sent to a set of observers that are interested in the execution of that signal. Signals in **ReactiveCocoa** send events no matter if there aren't observers and the encapsulated operation is executed when the signal is initializeid:

> You can find scenarios where you're going to observe a signal and that has already sent some events. In other Reactive frameworks these signals are called *Hot Signals* because they are sending events even if nobody asked for them.

**Some examples of signals**
If you think about data sources that we're used to work with daily the ones shown below can be modeled as signals:

- **GPS positions**: When the GPS tracking is enabled, that returns a signal that we'll observe. Every new position is an event sent through the signal. When we are not interested in these events anymore or the GPS tracking gets disabled the signal will get completed.
- **Text introduced in a field text**: The life time of the signal would be the life time of the view where the the textfield view is. If during that period the user introduces text in the textfield we'll receive that text through a signal and we'll be able to manipulate and process that information.
- **Push notifications reception**: We can in this case model a signal that is active during the app life cycle and whose events are push notifications that have been received and notified to the AppDelegate of your application.

Sounds interesting, right? Three examples above use the delegate pattern to propagate information about what happened to the delegate entity of these components. Later on we'll learn how to turn these patterns into Reactive, and you'll learn how to create a signal of push notifications, or a signal for GPS positions that you can use wherever you want in your app.

In the example project you'll find the example `intro_signal.swift` where the GPS data source is modeled with Reactive. Don't worry if you don't know any of the concepts used there. What we do is create a `LocationManager` which is subclass of `CLLocationManager` and its delegate is itself. Internally we have two attributes, an *Observer* and a *Signal*. Signal allows us to observe events, and it's `internal` in order to have visibility in the target where this component is being used. We also have an observer that is like a sink where we can send the events through. Events sent to this observer are forwarded to the signal observers:

~~~~~~~~
import Foundation
import ReactiveCocoa
import CoreLocation

class LocationManager: CLLocationManager, CLLocationManagerDelegate {

    enum GPSError: ErrorType { }

    // MARK: - Attributes

    private let gpsObserver: Observer<CLLocation, GPSError>
    let gpsSignal: Signal<CLLocation, GPSError>


    // MARK: - Init

    override init() {
        let gps = Signal<CLLocation, GPSError>.pipe()
        gpsObserver = gps.1
        gpsSignal = gps.0
        super.init()
        self.delegate = self
    }


    // MARK: - Deinit

    deinit {
        gpsObserver.sendCompleted()
    }


    // MARK: - CLLocationManagerDelegate

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        gpsObserver.sendNext(location)
    }
}
~~~~~~~~

#### Event types

Apart from sending data event, signal also support sending events that mean the signal was completed due to any reason. Supposing we have a signal `Signal<Value, CustomError>` the events that can be delivered by this signal are:

- **Next(Value):** This event mean that there's a new value. Signals can send multiple events of this type before completion. Al subscribers receive same events.
- **Failed(CustomError):** If the operation fails for any reason, the signal sends a `Failed` event including the error that caused the operation failing. After this one, no more `Next` events will be sent.
- **Interrupted:** As signals can be *disposed*, they notify when they're disposed sending an `Interrupted` event. No more `Next` events are received after this one.
- **Completed:** When this event is received it means that the signal operation was completed, after this event we won't receive more `Next` events from that signal.

#### Creating a Signal

**Defining its operation in a closure**: You can create a signal that executes an specific operation that you can define using a closure as shown in the following example:

  ~~~~~~~~
  let signal: Signal<Void, NoError> = Signal { (observer) -> Disposable? in
      // Your operation
      return nil
  }
  ~~~~~~~~

  Notice that signals are generic and we have to specify the data type and the error type:
    - **Data type:** It can be a reference/value type and also `Void`. You can use Foundation types but also more complex ones depending on your requirements.
    - **Error type:** You can wether specify the error type or use `NoError`. If you specify the error type it has to conform the Swift 2.0 protocol `ErrorType`.

  The operation is defined in that closure that receives an **Observer** parameter as an input parameter and it returns an optional **Disposable**. The observer is an object that we have to send the events to:

  ~~~~~~~~
  observer.sendNext(newValue)
  observer.sendCompleted()
  observer.sendInterrupted()
  observer.sendFailed(.MyError)
  ~~~~~~~~

  The closure returns a class object that conforms the **Disposable** protocol. A disposable is a reference object that allows the operation disposing whenever we need it. For example if we want to cancel an import operation because something unexpected happened.

**Using a pipe**: If our *operation* cannot be encapsulated so that we can define it when the signal is initialized we can use `pipe()`. With pipe we create an an *Observer* and a *Signal*. As in the previous example the observer behaves as a sink that forwards the events to the signal. Observers are typically kept as private in terms of visibility and only the observers are exposed. That way you create a private scope where you can control the signal from. The example presented in `intro_signal.swift` conforms that pattern.

## Signal Producer

As we can imagine from its name, these components "produce signals". The easiest way to understand a signal producer is thinking on it as a signal that gets executed when we specify it. Signal producers encapsulate operations that are executed when we call a method in the producer, `start()`.

From now I'll refer to **Signals** when I talk about producers or signals in general. Explained concepts and operators are valid for both of them.

#### Creating a Signal Producer

Producers can be initialized on several ways depending on your requirements. The available options are listed below:

  **Operation in a closure:** When you initialize the signal producer you specify in a closure which operation has to be executed. This closure has two input parameters, the `observable` and the `disposable` and doesn't return anything. As with signals events are sent through the observer but in this case the disposable is passed as a `CompositeDisposable`, we'll see this kind of disposable with more detail but to have an idea, this is a `Disposable` compound by multiple disposables so if you dispose that one you're also disposing all of them.

  ~~~~~~~~
  private let prod: SignalProducer<String, NoError> = SignalProducer { (observer, disposable) in
      observer.sendNext("Ey ya!")
      observer.sendCompleted()
  }
  ~~~~~~~~

  **Using a buffer:** Buffer is the equivalent `pipe` for signal producers. In this case the `buffer` commands create a `signal producer` and an `observer`. Events sent to that observer are forwarded to the observers of the signal producer and can be buffered if we specify it. That way for example, if we specify that the buffer size is 2, we send events A, B, C and after that we observe the subscriber, that observer will receive the events B, C because these are in the buffer.

  ~~~~~~~~
  let _buffer = SignalProducer<String, NoError>.buffer(2)
  let bufferProducer = _buffer.0
  let bufferObserver = _buffer.1
  bufferProducer.startWithNext { value in
      print(value)
  }
  bufferObserver.sendNext("yai!")
  ~~~~~~~~

  **Value signal producer:** It's a signal producer that is initialized with a value. When it's started it returns that value and completes:

  ~~~~~~~~
  private let valueProducer: SignalProducer<String, NoError> = SignalProducer(value: "Ey ya!")
  ~~~~~~~~

  **Result signal producer:** This signal producer returns a `Result` object when it's started. A result object is a generic class that wraps a value and an error. ReactiveCocoa depends on a library called `Result` that adds this extra functionality. If you prefer specifying the producer returned value in this way, you can also do it:

  ~~~~~~~~
  private let resultProducer: SignalProducer<String, NoError> = SignalProducer(result: Result(value: "Ey ya!"))
  ~~~~~~~~

  **Error signal producer:** In this case the producer returns an error when it's initialized.

  ~~~~~~~~
  private enum Error: ErrorType { case Unknown }
  private let errorProducer: SignalProducer<String, Error> = SignalProducer(error: Error.Unknown)
  ~~~~~~~~

  **Empty signal producer:** This producer completes when it's started and doesn't return any value.

  ~~~~~~~~
  private let emptyProducer: SignalProducer<String, NoError> = SignalProducer.empty
  ~~~~~~~~

  **Never producer:** You can also create a producer that never sends events.

  ~~~~~~~~
  private let neverProducer: SignalProducer<String, NoError> = SignalProducer.never
  ~~~~~~~~


### Signal or Signal Producers?

After this quick introduction of these two concepts you might be wondering when you should use one or another. The seem similar, they encapsulate an operation that sends events of its status and we've a set of observers listening to these events. There's a a small difference though that make signals useful for some scenarios and signal producers for anothers. Remember:

- **Signal:** It's started when it's created.
- **Signal producer:** It's started when you call its `start()` method.

With that in mind the use of `signals` makes more sense in a context where we have continuous delivering of events and we can observe them at any time. Some example of continuous events that could be modeled with `signals` could be:

- Changes in the device connectivity: `Signal<Connectiviy, NoError>`
- New GPS locations: `Signal<CLLocation, NoError>`
- User taps in a button: `Signal<Void, NoError>`
- Text introduced in a text field: `Signal<String, NoError>`
- App lifecycle events: `Signal<LifeEvent, NoError>`

These lifetime of these signals depend of the lifetime of the component that is controlling the signal *(e.g. text introduced in a text field would be controlled by the textview delegate. When that delegate gets deallocated from memory, the signal will be completed and released)*.

On the other side `signal producers` are more useful in discrete operations whose execution we want to have control over. They are like commands but in this case observers are notified in a Reactive way with an stream of events. Some examples of operations that could be modeled with `signal producers` could be:

- HTTP web request: `SignalProducer<AnyObject, HTTPError>`
- Database fetching: `SignalProducer<Person, StoreError>`
- Data saving using NSFileManager: `SignalProducer<Void, FileError>`
- Applying filters to an image: `SignalProducer<UIImage, FilterError>`

> Whenever you have doubts about using a Signal or a SignalProducer think if the events will be delivered continuously for a long period of time. In that case you'll need a Signal. If the events have a more discrete behaviour in time, then you'll need a SignalProducer.

## Observers

Observers are like sinks that can receive `events`. It has a method for every type of event available:

~~~~~~~~
observer.sendNext("something happened")
observer.sendFailed()
observer.sendCompleted()
observer.sendInterrupted()
~~~~~~~~

## Properties
`Properties` in ReactiveCocoa are generic classes that wrap other values in order to add Reactive behaviour. These properties expose a `signal producer` that you can observe in oder to get notified when the wrapped value changes. It uses `willSet` statement in the wrapped value under the hood. ReactiveCocoa offer some types of Properties all of them conforming the same base protocol `PropertyType` that defines these couple of variables:

~~~~~~~~
public protocol PropertyType {
    typealias Value
    public var value: Self.Value { get }
    public var producer: ReactiveCocoa.SignalProducer<Self.Value, ReactiveCocoa.NoError> { get }
}
~~~~~~~~

**AnyProperty**: A read-only property that allows observation of its changes. It can be initialized with a value or with another signal producer that updates the wrapped value internally.

  ~~~~~~~~
  private let anyPropertyProducer: AnyProperty<String> = AnyProperty(initialValue: "initial-value", producer: SignalProducer(value: "new-value"))
    private let anyPropertySignal: AnyProperty<String> = AnyProperty(initialValue: "initial-value", signal: Signal<String, NoError> { observer -> Disposable? in
        observer.sendNext("new-value")
        return nil
    })
  ~~~~~~~~

**ConstantProperty**: A kind of property that never changes and it's initialized with a value.

  ~~~~~~~~
  private let constantProperty: ConstantProperty<String> = ConstantProperty("value")
  ~~~~~~~~

**MutableProperty**: Property that can mutate its `Value`. Instances of this class are thread-safe.

  ~~~~~~~~
  let name: MutableProperty<String> = MutableProperty<String>("")
  name.producer.startWithNext { newName in
    print("New name: \(newName)")
  }
  name.value = "Pedro"
  ~~~~~~~~

**DynamicProperty**: Wraps a `dynamic` property, or one defined in Objective-C. It uses KVO instead. ReactiveCocoa recommends trying to use `MutableProperty` because it's generally better. You might find some cases where its strongly required by the API you're using *(e.g. NSOperation)*


## Actions

An `Action` object receives `Input` values, then return zero or more values of type `Output` and/or fails with an error of type `Error`. Actions enforce serial execution. Any attempt to execute an action multiple times concurrently will return an error.

Actions are very useful when you wanna perform side-actions when any primary action takes place, for example when the user taps a button or when we receive a push notifications. Moreover these actions can be disabled based on a *property* value. ReactiveCocoa also provides a custom actions for `NSControl` and `UIControl` components that allow bridging actions to Objective-C.

Actions can be initialized in two ways. The first one is specifying in a closure the output producer given an input as you can see in the example below. Actions have a property, `values` which is a signal that you can observe. That signal will forward generated values from the input values.

~~~~~~~~
let action: Action<String, String, NoError> = Action<String, String, NoError> { (input) -> SignalProducer<String, NoError> in
    return SignalProducer(value: "hi \(input)")
}
action.values.observeNext { (output) -> () in
    print(output) // "hi Pedro"
}
_ = action.apply("Pedro")
~~~~~~~~

Actions also provide the following attributes in case you need them:

- **Events: Signal<Input, ErrorType>:** Signal with the events generated by the action.
- **Errors: Signal<Error, NoError>:** Signal with all the errors generated by the action
- **Enabled:** True if the action is enabled. When the action is *disabled* outputs are not generated from inputs.
- **Executing:** True if the action is currently being executed.
We can also initialize `Actions` passing a property whose value determines whether the action is enabled or not.

~~~~~~~~
let isEnabled: MutableProperty<Bool> = MutableProperty(true)
let action: Action<Void, Void, NoError> = Action<Void, Void, NoError>(enabledIf: isEnabled) { (input) -> SignalProducer<Void, NoError> in
    return SignalProducer(value: ())
}
action.values.observeNext { () -> () in
    print("User did tap")
}
_ = action.apply(()) // User did tap
isEnabled.value = false
_ = action.apply(()) // Nothing will be printed
~~~~~~~~

In the example above we create a property that determines the enabled value of the action. The first time we apply a value to the signal the message will be printed because the property value is true but the second time it's applied it won't print anything because the enabled value is `false`.

> Notice that we can specify `Void` as Input and Output types. It's very useful if the action doesn't necessarily reflects a type (e.g. an user tap over a button).

#### Cocoa Actions

`CocoaAction` allow us to bridge Objective-C selectors with ReactiveCocoa actions. In order to use these actions:

1. We define an `Action` that will be responsible of getting input values and transforming them to be observed.
2. Then, we initialize the `CocoaAction` with the previous `Action` specifying how the input object from the selector will be transformed.
3. Finally, we set that `CocoaAction` as the target of the selector, and we get the selector name from the static property `CocoaAction.selector`.

> Note: CocoaAction has to be retained when the components that are using it are alive, otherwise the action will be released and the events won't be propagated. These actions can be used not only from UIButtons but any component that uses target-selector pattern.

~~~~~~~~
let loginButton: UIButton = UIButton()
let action: Action<Void, Void, NoError> = Action<Void, Void, NoError> { SignalProducer(value: ()) }
let cocoaAction = CocoaAction(action) { $0 }
loginButton.addTarget(cocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
~~~~~~~~

## Disposables

You might have noticed that every time we observe a `Signal` or `SignalProducer` it returns a `Disposable` object. `Disposable` is a mechanism that ReactiveCocoa offers for memory management and cancellation of actions. Depending on wether the `Disposable` comes from a `Signal` or a `SignalProducer` the behaviour is different.

- **SignalProducer**: When a disposable is returned by a `SignalProducer` is called it will cancel the operation (e.g. background processing, network requests, etc.), clean up all temporary resources and will send an `Interrupted` event upon the particular `Signal` that was created.
- **Signal**: In this case calling the disposable will prevent the observers from receiving future events from the signal but it won't have any effect on the operation *(e.g. it won't be cancelled or resources cleaned)*.

`Disposable` itself is defined as a protocol in  ReactiveCocoa. That protocol has the structure shown below where *disposed* indicates wether the `Disposable` has been disposed or not and a function `dispose()` to dispose the action:

~~~~~~~~
public protocol Disposable {
	var disposed: Bool { get }
	func dispose()
}
~~~~~~~~

ReactiveCocoa provides with multiple disposable from the simplest one to more complex that allow combination of simple disposables:

- **SimpleDisposable:** Simplest disposable version. It just references the disposed status.
- **ActionDisposable:** Disposable that executes an action when the Disposable gets disposed. This action is defined when the `ActionDisposable` is initialized.
- **CompositeDisposable:** Disposable that is initialized with multiple disposables. When it's disposed all the internal disposables are disposed simultaneusly.
- **ScopedDisposable:** Disposable that will be disposed once it's deallocated *(it uses deinit internally)*
- **SerialDisposable:** Disposable that wraps an internal disposable. Whenever that internal disposable is updated, the previous one is disposed automatically.

> ReactiveCocoa offers a custom operator `+=` for `CompositeDisposable` so you can add new disposables to an existing disposable.

## Schedulers

Schedulers in ReactiveCocoa represents a queue of actions to be executed within a particular context. Schedulers are very useful to specify in which thread we'll observe the events reported by our `Signals` or `SignalProducers` no matter in which thread they executed their operations. All available schedulers conform the same protocol `SchedulerType` that defines a base method for enqueuing actions:

~~~~~~~~
func schedule(action: () -> ()) -> Disposable?
~~~~~~~~

Notice that the method returns a `Disposable`. That  `Disposable` can be used to cancel the action before it begins. ReactiveCocoa also defines an extra `Scheduler` protocol, `DateSchedulerType` that allows scheduling actions after a given date:

~~~~~~~~
func scheduleAfter(date: NSDate, action: () -> ()) -> Disposable?
func scheduleAfter(date: NSDate, repeatingEvery: NSTimeInterval, withLeeway: NSTimeInterval, action: () -> ()) -> Disposable?
~~~~~~~~

Compared with Grand Central Dispatch queues, schedules **support cancellation** via disposables, an always execute serially. With exception of the `InmediateScheduler`, schedulers do not offer synchronous execution. This helps avoid deadlocks, and encourages the use of signal and signal producer primitives instead of blocking work.

Schedulers are also somewhat similar to `NSOperationQueue`, but schedulers do not allow tasks to be reorder or depend on one another.

#### Types

- **ImmediateScheduler:** It executes the action immediately.
- **UIScheduler:** Scheduler that executes the actions in the `MainThread`
- **QueueScheduler:** Scheduler that executes the actions in a provided GCD queue.

#### How to use Schedulers?

`Signals` and `SignalProducers` have a method, `observeOn` where you can specify where the events are observed from. For example, in the example below we have a `SignalProducer` that executes a request in a background thread and return it results in that thread. We're using the response directly in the UI so it's very important to update UI elements in the `MainThread`. We can specify it very easily using `Schedulers`:

~~~~~~~~
let producer: SignalProducer<Issues, ApiError> = request("/api/issues", .GET, Issue.mapper)
producer
  .observeOn(UIScheduler())
  .startWithNext { issues in
    // Update the UI with the issues
  }
~~~~~~~~
