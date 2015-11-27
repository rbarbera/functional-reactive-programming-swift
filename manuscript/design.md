# Design

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

### Notifications
//TODO
<!-- Notifications enable registering multiple observers easily, but they are also untyped. Values need to be extracted from either userInfo or original target once they fire.
They are just a notification mechanism, and initial value usually has to be acquired in some other way.
That leads to this tedious pattern: -->

### KVO
//TODO
<!-- KVO is a handy observing mechanism, but not without flaws. It's biggest flaw is confusing memory management.
In case of observing a property on some object, the object has to outlive the KVO observer registration otherwise your system will crash with an exception. -->

### Delegates
//TODO
<!-- Delegates can be used both as a hook for customizing behavior and as an observing mechanism.
Each usage has it's drawbacks, but Rx can help remedy some of the problem with using delegates as a observing mechanism.
Using delegates and optional methods to report changes can be problematic because there can be usually only one delegate registered, so there is no way to register multiple observers.
Also, delegates usually don't fire initial value upon invoking delegate setter, so you'll also need to read that initial value in some other way. That is kind of tedious.
RxCocoa not only provides wrappers for popular UIKit/Cocoa classes, but it also provides a generic mechanism called DelegateProxy that enables wrapping your own delegates and exposing them as observable sequences.
This is real code taken from UISearchBar integration.
It uses delegate as a notification mechanism to create an Observable<String> that immediately returns current search text upon subscription, and then emits changed search values. -->

## Data layer

### Remote

#### HTTP

I> The presented examples can be found in `Design/Data/HTTP`

I> Examples make use of [*Alamofire*](https://github.com/alamofire/alamofire). A networking library that also includes a set of useful components that we used.

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
5. **Encoding:** That determines how parameters will be encoded in the URL. We use [Alamofire](https://github.com/Alamofire/Alamofire) and its `ParameterEncoding` enum to encode passed parameters.
5. **Session:** In case we're accessing HTTP resources that require authentication we will need the user session. It's represented in the example below with a `Session` struct object. That session structure will depend on the authentication mechanism of the API you'r accessing to.

~~~~~~~~
public struct HTTP {

  // MARK: - REST Method

  public enum Method: String {
    case POST, PUT, PATCH, DELETE, GET
  }


  // MARK: HTTP Error

  public enum HttpError: ErrorType {
    case Default(NSError)
  }


  // MARK: - Session

  public struct Session {

    let accessToken: String
    let refreshToken: String

    init(accessToken: String, refreshToken: String) {
      self.accessToken = accessToken
      self.refreshToken = refreshToken
    }
  }


  // MARK: - FRP Interface

  static public func request(baseURL: String)(path: String)(method: Method, parameters: [String: AnyObject], encoding: ParameterEncoding)(session: Session) -> SignalProducer<(NSData, NSURLResponse), HttpError> {
    return SignalProducer { (observer, disposable) in

      let urlSession: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
      var request: NSURLRequest = NSURLRequest(URL: NSURL(string: baseURL)!.URLByAppendingPathComponent(path))
      request = self.urlRequest(request, withSession: session)
      request = self.urlRequest(request, withMethod: method, parameters: parameters, encoding: encoding)
      let task = urlSession.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        if let error = error {
          observer.sendFailed(.Default(error))
        }
        else if let response = response, let data = data {
          observer.sendNext((data, response))
        }
        observer.sendCompleted()
      })
      if disposable.disposed {
        return
      }
      task.resume()
    }
  }

  static public func mapToJSON(input: (NSData, NSURLResponse)) -> AnyObject? {
    return try! NSJSONSerialization.JSONObjectWithData(input.0, options: NSJSONReadingOptions.AllowFragments)
  }


  // MARK: - Private Helpers

  static private func urlRequest(request: NSURLRequest, withSession session: Session) -> NSURLRequest {
    let mutableRequest: NSMutableURLRequest = request.mutableCopy() as! NSMutableURLRequest
    mutableRequest.allHTTPHeaderFields = ["Authorization": "Bearer \(session.accessToken)"]
    return mutableRequest.copy() as! NSURLRequest
  }

  static private func urlRequest(request: NSURLRequest, withMethod method: Method, parameters: [String: AnyObject], encoding: ParameterEncoding) -> NSURLRequest {
    let mutableRequest: NSMutableURLRequest = encoding.encode(request, parameters: parameters).0
    mutableRequest.HTTPMethod = method.rawValue
    return mutableRequest.copy() as! NSURLRequest
  }

}
~~~~~~~~

Let's analyze it:

- **Method:** We define an enum that contains the REST method that we're using in the request. That way we introduce a value safety which is implicit in the enum itself.
- **HttpError:** We're defining a custom error type for our requests. That way we've more flexibility to support more errors in the future.
- **Session:** We define an struct that contains information about the user session. In the example presented the user access token.
- **Request:** Request function is implemented **currying**, why? If we call that curry function passing the base URL then we have a request generator for a given base url. Does the `APIClient` singleton instance sound familiar to you? We could say that that request is the functional equivalent to your API clients. The function returns a `SignalProducer` that creates the request, and executes it when the `SignalProducer` is started.

> Notice that the `SignalProducer` type next event type is a tuple of (NSData, NSURLResponse). We want to propagate the response back, that way the consumer can extract information about the HTTP response.

##### 2. JSON requests

The `SignalProducer` created in the example above is a generic one that is valid for any kind of HTTP response. If we wanted to make it specific for JSON responses and return a `Foundation` object instead we can use the **map** operator of Reactive.

First thing we do is defining our mapper that takes an `(NSData, NSURLResponse)` tuple as input parameter and converts it into an `AnyObject` that might represent a dictionary, `[String: AnyObject]` or an array `[AnyObject]`.

~~~~~~~~
func mapToJSON(input: (NSData, NSURLResponse)) -> AnyObject? {
  return try! NSJSONSerialization.JSONObjectWithData(input.0, options: NSJSONReadingOptions.AllowFragments)
}
~~~~~~~~

Then we can use it with `map`:

~~~~~~~~
showUserRequest(session: mySession)
  .map(Reactive.HTTP.mapToJSON)
  .on(event: { event in
    switch event {
    case .Next(_):
      print("Got response from the server")
    case .Failed(_):
      print("Something went wrong")
    default:
      break
    }
  }).start()
~~~~~~~~

Voila! we moved our generic Reactive Functional API Client to an API Client valid for JSON APIs.

##### 3. Plain objects mapping

Depending on the response, we'll want to map it into a plain object that we can use from our code having its own attributes defined. As we did mapping the response into a `Foundation` object, we can again map that object into a defined `Foundation` or `Struct`. Let's say we have defined an `User` struct with the user data that the Github API returns:

1. We define a protocol called `Mappable` that defines how the struct that conforms it can be mapped into a collection of itself or a single element.
2. Using **protocol extensions** of Swift we give a default implementation for `collectionMapper()` that internally uses `singleMapper()`
3. We define our `User` struct that conforms that protocol and consequently implement the `singleMapper()` method.

> Note: `singleMapper()` implementation doesn't include the extraction of values from the dictionary. You can directly get them from the `Foundation` dictionary or use any of the existing libraries for that. I recommend you to use [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) or [Genome](https://github.com/Genome).

~~~~~~~~
protocol Mappable {
  static func singleMapper(object: AnyObject) -> Self?
  static func collectionMapper(object: AnyObject) -> [Self]?
}

extension Mappable {
  static func collectionMapper(object: AnyObject) -> [Self]? {
    guard let array = object as? [AnyObject] else { return nil }
    return array.map { singleMapper($0)! }
  }
}

struct User: Mappable {

  // MARK: - Attributes

  let username: String
  let email: String

  // MARK: - Constructor

  private init(username: String, email: String) {
    self.username = username
    self.email = email
  }

  // MARK: - Mappable

  static func singleMapper(object: AnyObject) -> User? {
    guard let dict = object as? [String: AnyObject] else { return nil }
    // Extract the information from the dictionary
    return Account(username: "xxxx", email: "xxx")
  }
}
~~~~~~~~

Now with the mapper defined we can use again the `map` operator of ReactiveCocoa to get a `SignalProducer` of `User` instead:

1. After mapping into the JSON `Foundation` object *(that can return a nil value)* we use the operator `ignoreNil` of ReactiveCocoa to get a `SignalProducer` of **non-nil** `Foundation` values.
2. Then we use the `map` operator again passing in this case the `User.singleMapper` function.

~~~~~~~~
showUserRequest(session: mySession)
  .map(Reactive.HTTP.mapToJSON)
  .ignoreNil()
  .map(User.singleMapper)
  .on(event: { event in
    switch event {
    case .Next(let user):
      print("User with username: \(user?.username)")
    case .Failed(_):
      print("Something went wrong")
    default:
      break
    }
  }).start()
~~~~~~~~

##### Combining requests
One of the main advantages of the use of Reactive Programming is the ease to combine multiple SignalProducers. When we interact with APIs resources we might need fetching resources after some others have been downloaded. For example, interacting with the Github API:

- Download the user repositories when the user account has been downloaded.
- Download the repository collaborators when the repositories have been downloaded.
- Download the list of issues of a given repository when that has been downloaded.

Without the Reactive approach we end up chaining multiple completion closures and with a lot of indentations levels, which is not clear in terms of readability. That an be simplified using our request generators seen before:

**Download user repositories after user**
Supposing that our `User` model has now a new attribute, `reposIds` that is an `Array<String>` we can implement a new request that using `userRequest` and `repoRequest` fetches the user repositories. To get them we use the operator `flatMap` that for every value sent in the source signal *(`User` object)* we return a `SignalValues` whose values are sent through the main stream. In this case we combine multiple `SignalProducer` that get each of these repositories and return it.

~~~~~~~~
private func userRequest() -> SignalProducer<User, HttpError>
private func repoRequest(identifier: String) -> SignalProducer<Repository, HttpError>
private func userRepos() -> SignalProducer<[Repository], HttpError> {
  return userRequest()
          .flatMap { (user) -> SignalProducer<[Repository], HttpError> in
            return combineLatest(user.reposIds.map(repoRequest))
          }
}
private func shortUserRequest() -> SignalProducer<[Repository], HttpError> {
  return userRequest().flatMap { combineLatest($0.reposIds.map(repoRequest)) }
}
~~~~~~~~

##### Summary
- We use the `SignalProducer`constructor defining in the closure how the request is build and executed. When the producer is started the HTTP request is executed.
- The constructor is defined using **currying** to have more flexibility building our own requests changing the *path* and *parameters*.
- Thanks to the `map` operator we can:
  - Get a `SignalProducer` whose responses are `Foundation` object instead of `NSData` values.
  - Get a `SignalProducer` whose responses are plain structs that we can use from our code reading its attributes.
- We've also seen the use of the ReactiveCocoa `ignoreNil` to ignore nil values returned after mapping into JSON.
- Finally we **combined** multiple HTTP requests to fetch API resources that might be related with the `flatMap` operator.

### Local persistence

#### Keychain
//TODO

#### NSUserDefaults

NSUserDEfaults

##### Making its interface Reactive

##### Creating a changes signal



#### CoreData
//TODO

#### Realm
//TODO

## Presentation layer

### IBActions
//TODO

### MVVM

//TODO



## Include them?
- Best practices
- Pitfalls
- Retain cycles
- Objects retainment (in producers)
