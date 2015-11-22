Reactive design
===============

Once you get this point, you have the enough concepts to start thinking in Reactive. The reason why most of developers stop learning Reactive or don't start doing it is because there're no enough examples that can show them real uses of Reactive within their projects, in this case in Swift projects. In this chapter we will see different uses of Reactive from different layers in apps (data, presentation, ...). We'll also review steps to migrate existing Cocoa patterns to Reactive and some tips and recommendations we should keep in mind when working with Reactive.

## Principles

- **Threading:** Although you can observe the events from any thread using `Schedulers` it's strongly recommended to keep the threading map simple. If you have large chain of operators and they're changing between threads it'll affect the performance and also the battery, the more threads you make use of the more consume of resources you'll do. When you design your `Signals` or `SignalProducers` decide the thread where its operations will be executed and use the same thread for consecutive operators. If you need the events to be observed from a different thread, then add the `observeOn()` at the end of that chain.

- **Avoid mutable states:** When designing your actions, try to think them in a Mathematical way, given an input, we return an output. Don't use side variables that might mutate and introduce extra, not taken into account, statuses that cause unexpected events in your resulting Signal. Signals generators should have the following structure:

  ~~~~~~~~
  func concatenateSignal(inputA: String, inputB: String) -> SignalProducer<Void, Error> {
    return Signal { observer -> Disposable? in
      observer.sendNext("\(inputA)\(inputB)")
      observer.sendCompleted()
      return nil
    }  
  }
  ~~~~~~~~

- **Unidirectional flow:** Related with the previous statement, this one is also very important. The core idea of Reactive programming is representing the data propagation as an unidirectional stream. When you design signals try to keep that core idea and avoid lateral dependencies. If at one point of your stream wee ned data from a previous point we should pass that data through the stream and use it as input parameter. *Don't use external variables to reference an state during the data flow. If you find that case in your code, rethink your stream design.*

  ~~~~~~~~
  // Bad design
  var isEmpty: Bool = false
  textInput
    .onNext { text in
      isEmpty = text == ""
    }
    .onNext { text in
      if isEmpty {
        print("It's empty")
      }
    }

  // God design
  textInput
    .filter { $0 == "" }
    .onNext { _ in
      print("It's empty")
    }
  ~~~~~~~~

  When you start working on a new Reactive operation I recommend you to follow these steps:
    1. Understand what are the **inputs** of your equation.
    2. Define what should be the **outputs** of our equation. These outputs must only depend on the input values.
    3. Check if there're any possible **intermediate** variables that could help at any point of your stream.
    4. Implement your function that generates the `Signal` or `SignalProducer`.
    5. Test that given all the possible inputs we get the expected outputs.

- **Use existing operators:** ReactiveCocoa operators have been perfectly designed and tested before being added to the framework. Before working on a new operators we should try to use any of the existing one or combine existing operators. The design of new operators might lead to problems with multi-thread access, signals retained in memory, disposables not properly combined...

## Cocoa patterns
### Completion closures
When blocks where introduced back with Objective-C most of common framework started using this pattern notifying the completion of its operations. In Swift, blocks where renamed to closures adding some advantages like the option to specify the retainmend of external variables when the closure is defined. The migration of that pattern to Reactive is relatively easy.

Let's say we have the method shown below:

~~~~~~~~
func save(objects: AnyObject, withCompletion completion: (error: NSError?) -> Void)
~~~~~~~~

That function saves objects in the disk an notifies calling the completion closure when the saving operation has been completed. This closure has an optional error that has a value in case that something went wrong during the saving process. The Reactive format of that function would be *(depending if we need a Signal or a SignalProducer)*:

~~~~~~~~
// Signal Producer
func save(objects: [AnyObject]) -> SignalProducer<Void, NSError> {
  return SignalProducer { (observer, disposable) in
    var error: NSError?
    if disposable.disposed {
      return
    }
    // Same operation we had before
    if let error = error {
      observer.sendFailed(error)
    }
    else {
      observer.sendCompleted()
    }
  }
}

// Signal
func save(objects: [AnyObject]) -> Signal<Void, NSError> {
  return Signal { observer -> Disposable? in
    var error: NSError?
    let disposable: Disposable = SimpleDisposable()
    // Same operation we had before
    if let error = error {
      observer.sendFailed(error)
    }
    else {
      observer.sendCompleted()
    }
    return disposable
  }
}
~~~~~~~~

We could then use the functions above instead of the initial completion closure based approach:

~~~~~~~~
save(myObjects).startWithCompleted {
  print("\(myObjects.count) objects saved")
}
~~~~~~~~

## Data layer
### Remote
#### HTTP

Most of apps nowadays access internet to get data from or report data where HTTP/S is the protocol we used for that data interaction. The current *NSURLSession* kit that Apple offers in `Foundation` provides a blocks/closure based API. Some frameworks that are commonly used for web interaction like **Alamofire** or **AFNetorking** also offer block/closured based API but the community have extended it in order to provide a Reactive access to its features.

In this section we'll learn how to bring Reactive to our HTTP data interactions through the following steps:

1. Create a request function that generates a `SignalProducer` encapsulating the request.
2. Create a mapper for these requests to support JSON APIs.
3. Define a mapper for JSON responses to map them into plain objects.

##### 1. Request generator
The first step is defining which variables we need to create a request:
  1. **Method:** GET/POST/PUT/PATCH/DELETE
  2. **BaseURL:** Base url of our requests, we'll concatenate the path to that url.
  3. **Path:** Path that points to the resource we want to access.
  4. **Parameters:** Dictionary with parameters that has to be sent with the request.
  5. **Session:** In case we're accessing HTTP resources that require authentication we will need the user session. It's represented in the example below with a `Session` struct object. That session structure will depend on the authentication mechanism of the API you'r accessing to.

~~~~~~~~
enum Method: String {
  case POST, PUT, PATCH, DELETE, GET
}

enum HttpError: ErrorType {}

struct Session {
  let accessToken: String
  init(accessToken: String) {
    self.accessToken = accessToken
  }
}

func request(baseURL: String)(path: String)(method: Method, parameters: [String: AnyObject])(session session: Session) -> SignalProducer<AnyObject, HttpError> {
  return SignalProducer { (observer, disposable) in

  }
}

// 1. Unauthenticated request for a given base url
let githubRequest = request("https://api.github.com")

// 2. Unauthenticated request pointing to a given resource
let userRequest = githubRequest("/user")

// 3. Unauthenticated request getting a resource
let showUserRequest = userRequest(.GET, parameters: [:])

// 4. Authenticated request getting a resource
showUserRequest(session: mySession).startWithEvent { event in
  switch event {
    case .Next(let response):
      print("Response: \(response)")
    case .Failed(let error):
      print("Failed: \(error)")
    default:
      break
  }
}
~~~~~~~~

Let's analyze it:

- **Method:** We define an enum that contains the REST method that we're using in the request. That way we introduce a value safety which is implicit in the enum itself.
- **HttpError:** We're defining a custom error type for our requests. That way we've more flexibility to support more errors in the future.
- **Session:** We define an struct that contains information about the user session. In the example presented the user access token.
- **Request:** Request function is implemented **currying**, why? If we call that curry function passing the base URL then we have a request generator for a given base url. Does the `APIClient` singleton instance sound familiar to you? We could say that that request is the functional equivalent to your API clients.

##### 2. JSON requests

~~~~~~~~

~~~~~~~~

##### 3. Plain objects mapping

~~~~~~~~

~~~~~~~~


### Local persistence
#### Keychain
#### NSUserDefaults
#### CoreData
#### Realm

## Presentation layer
### IBActions
### MVVM




## I DON'T KNOW
- Best practices
- Pitfalls
- Retain cycles
- Signal & view lifecycles
- Objects retainment (in producers)
- Threading
