# Concepts

This section will get you through RP concepts and the components that implement these concepts in both, ReactiveCocoa and RxSwift. This section is structured as a reference. If you are already familiar with RP concepts, or you have use any other ReactiveX framework before, you can jump directly into the next section. If not, this section is very important, do not skip it.


I> If you're interested in learning only one of the frameworks (ReactiveCocoa or RxSwift) you can just read only the subsections that belong to your selected framework. There are some subsections that make a comparison between both of them that are interesting in order to understand the principles of both Reactive solutions.

I> RxSwift documentation is available [here](https://github.com/ReactiveX/RxSwift/tree/master/Documentation)
I> ReactiveCocoa documentation is available [here](https://github.com/ReactiveCocoa/ReactiveCocoa/tree/master/Documentation)

## Observables

As you might have guessed from its name, an `Observable` is *"something"* whose changes can be observed. In RP `Observable`s behave like streams, thus, they start sending data, deliver one or multiple events and then complete, successfuly or not. `Observable`s can be **Hot** and **Cold**. According to [ReactiveX.io](http://reactivex.io)

> When does an Observable begin emitting its sequence of items? It depends on the Observable. A “hot” Observable may begin emitting items as soon as it is created, and so any observer who later subscribes to that Observable may start observing the sequence somewhere in the middle. A “cold” Observable, on the other hand, waits until an observer subscribes to it before it begins to emit items, and so such an observer is guaranteed to see the whole sequence from the beginning.

In order to make this distinction more clear in ReactiveCocoa they decided to use a different naming more explicit. ReactiveCocoa defines cold `Observables` as `SignalProducers`, and hot `Observables` as `Signals` but the meaning at the end is the same. This distinction might be initially confusing but as you go through RP it becomes more clear.

Extracted form [RxSwift](https://github.com/ReactiveX/RxSwift/edit/master/Documentation/HotAndColdObservables.md) the following table shows a comparative between Hot and Cold observables:

| Hot Observables                                                                                         | Cold observables                                                              |
|---------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| ... are sequences                                                                                       | ... are sequences                                                             |
| Use resources ("produce heat") no matter if there is any observer subscribed.                           | Don't use resources (don't produce heat) until observer subscribes.           |
| Variables / properties / constants, tap coordinates, mouse coordinates, UI control values, current time | Async operations, HTTP Connections, TCP connections, streams                  |
| Usually contains ~ N elements                                                                           | Usually contains ~ 1 element                                                  |
| Sequence elements are produced no matter if there is any observer subscribed.                           | Sequence elements are produced only if there is a subscribed observer.        |
| Sequence computation resources are usually shared between all of the subscribed observers.              | Sequence computation resources are usually allocated per subscribed observer. |
| Usually stateful                                                                                        | Usually stateless

### Examples

####  Hot Observables / Signals

If we think about data sources that we are used to work with daily the ones shown below can be modeled as a `Signal`/`Hot Observable`:

- **GPS positions**: When the GPS tracking is enabled, that returns a signal that we'll observe. Every new position is an event sent through the signal. When we are not interested in these events anymore or the GPS tracking gets disabled the signal will get completed.
- **Text introduced in a field text**: The life time of the signal would be the life time of the view where the the textfield view is. If during that period the user introduces text in the textfield we will receive that text through a signal and we will be able to manipulate and process that information.
- **Push notifications reception**: We can in this case model a signal that is active during the app life cycle and whose events are push notifications that have been received and notified to the AppDelegate of your application.

Sounds interesting, right? Three examples above use the delegate pattern to propagate information about what happened to the delegate entity of these components. Later on we will learn how to turn these patterns into Reactive.

#### Examples of Cold Observables / SignalProducers

A `SignalProducer`/`Cold Observable` represents an operation whose execution is controlled. They generally return a value before completing. Some examples of these could be:

- **HTTP Request**: An observable could model an HTTP Request. When it gets executed instead of returning the values using completion closures as we are used to in the Imperative Programming, request response is forwarded through the stream. Observers automatically recevie the response.
- **Database Fetch Operation**: Our designed observable can execute a fetch into the database and return the results through the stream to notify all the interested observers.
- **View Presentation**: And not only data, we can also encapsulate UI-related operations. For example, a presentation of an `UIViewController` could be encapsulated in an operation. Once subscribed, the view will be presented.

### Event types

Apart from sending data event, signal also support sending events that mean the signal was completed due to any reason.

**ReactiveCocoa**

`Signal`s and `SignalProducer`s in Reactive Cocoa are generic types. You ca specify the data and the error type of these objects.

~~~~~~~~
Signal<CLLocation, NSError>
SignalProducer<Account, ApiError>
~~~~~~~~

Thanks to *generics* we can now at every point the kind of data we're expecting.

**RxSwift**

RxSWfit also provide their `Observable`s as generic types but in this ase you can only specify the value.

~~~~~~~~
Observable<CLLocation>
~~~~~~~~

In Reactive Programming the list of events that can be delivered are:

- **Next(Value):** This event means that there is a new value. Multiple events of this type can be sent before the completion. All subscribers receive same events.
- **Failed(CustomError):** If the operation fails for any reason, a `Failed` event  is sent  including the error that caused the operation failing. After this one, no more `Next` events will be sent since the stream completed.
- **Completed:** When this event is received it means that the operation was completed successsfuly, after this event we won't receive more `Next` events through the stream.

There is an extra event that ReactiveCocoa implements and that is not available in RxSwift:

- **Interrupted:** As signals can be disposed *(cancelled)*, they notify when they're disposed sending an `Interrupted` event. No more `Next` events are received after this one.


### Creating Signals (ReactiveCocoa)

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

**Using a pipe**: If our *operation* cannot be encapsulated so that we can not define it when the signal is initialized we can use `pipe()`. With pipe we create an an *Observer* and a *Signal*. As in the previous example the observer behaves as a sink that forwards the events to the signal. Observers are typically kept as private in terms of visibility and only the signals are exposed. That way you create a private scope where you can control the signal from.

//TODO

### Creating SignalProducers (ReactiveCocoa)

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

### Creating Observables (RxSwift)

// TODO


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

- **Events: Signal<Input, ErrorType>:** Signal of the events generated by the action.
- **Errors: Signal<Error, NoError>:** Signal of the errors generated by the action
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

- **SignalProducer**: When a disposable returned by a `SignalProducer` is called, it will cancel the operation (e.g. background processing, network requests, etc.), clean up all temporary resources and it will send an `Interrupted` event upon the particular `Signal` that was created.
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

Schedulers in ReactiveCocoa represents a queue of operations to be executed within a particular context. Schedulers are very useful to specify in which thread we'll observe the events reported by our `Signals` or `SignalProducers` no matter in which thread they executed their operations. All available schedulers conform the same protocol `SchedulerType` that defines a base method for enqueuing actions:

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
