import Foundation
import ReactiveCocoa


// MARK: - Request generator

enum Method: String {
    case POST, PUT, PATCH, DELETE, GET
}

enum HttpError: ErrorType {
    case Default(NSError)
}

struct Session {
    let accessToken: String
    init(accessToken: String) {
        self.accessToken = accessToken
    }
}

private func request(baseURL: String)(path: String)(method: Method, parameters: [String: AnyObject])(session: Session) -> SignalProducer<(NSData, NSURLResponse), HttpError> {
    return SignalProducer { (observer, disposable) in
        
        let urlSession: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: baseURL)!.URLByAppendingPathComponent(path))
        // TODO - Append parameters
        request.allHTTPHeaderFields = ["Authorization": "Bearer \(session.accessToken)"]
        request.HTTPMethod = method.rawValue
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

// MARK: - JSON requests

func mapToJSON(input: (NSData, NSURLResponse)) -> AnyObject? {
    return try! NSJSONSerialization.JSONObjectWithData(input.0, options: NSJSONReadingOptions.AllowFragments)
}


// MARK: - Mapping to plain object

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


private func github() {
    // 1. Unauthenticated request for a given base url
    let githubRequest = request("https://api.github.com")
    
    // 2. Unauthenticated request pointing to a given resource
    let userRequest = githubRequest(path: "/user")
    
    // 3. Unauthenticated request getting a resource
    let showUserRequest = userRequest(method: .GET, parameters: [:])
    
    // 4. Authenticated request getting a resource
    let mySession: Session = Session(accessToken: "xxx")
    showUserRequest(session: mySession).on(event: { event in
        switch event {
        case .Next(_):
            print("Got response from the server")
        case .Failed(_):
            print("Something went wrong")
        default:
            break
        }
    }).start()
    
    // 5. Authenticated request getting a JSON resource
    showUserRequest(session: mySession)
        .map(mapToJSON)
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
    
    // 6. Authenticated request getting an User resource
    showUserRequest(session: mySession)
        .map(mapToJSON)
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
}


