import Foundation
import ReactiveCocoa
import Alamofire

public extension Reactive {
    
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
    
}