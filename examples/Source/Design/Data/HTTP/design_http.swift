import Foundation
import ReactiveCocoa




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
        return User(username: "xxxx", email: "xxx")
    }
}


private func github() {
    // 1. Unauthenticated request for a given base url
    let githubRequest = Reactive.HTTP.request("https://api.github.com")
    
    // 2. Unauthenticated request pointing to a given resource
    let userRequest = githubRequest(path: "/user")
    
    // 3. Unauthenticated request getting a resource
    let showUserRequest = userRequest(method: .GET, parameters: [:])
    
    // 4. Authenticated request getting a resource
    let mySession: Reactive.HTTP.Session = Reactive.HTTP.Session(accessToken: "token", refreshToken: "refresh")
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
    
    // 6. Authenticated request getting an User resource
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
}


