import Foundation
import ReactiveCocoa

public extension Reactive {
    
    public class UserDefaults: NSUserDefaults {
        
        // MARK: - Overriden
        
        private static var _userDefaults: UserDefaults = UserDefaults()
        
        public override class func standardUserDefaults() -> NSUserDefaults {
            return _userDefaults
        }
        
        
        // MARK: - Observer
        
        lazy var pipes: [String: (Signal<(String, AnyObject?), NoError>, Observer<(String, AnyObject?), NoError>)] = {
            return [:]
        }()
        
        public func observe(key: String) -> Signal<(String, AnyObject?), NoError> {
            guard let pipe = self.pipes[key] else {
                let pipe = Signal<(String, AnyObject?), NoError>.pipe()
                self.pipes[key] = pipe
                self.addObserver(self, forKeyPath: key, options: NSKeyValueObservingOptions.New, context: nil)
                return pipe.0
            }
            return pipe.0
        }
        
        public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            guard let key = keyPath else { return }
            guard let pipe = pipes[key] else { return }
            pipe.1.sendNext((key, self.objectForKey(key)))
        }
        
        deinit {
            for item in pipes {
                self.removeObserver(self, forKeyPath: item.0)
                let observer = item.1.1
                observer.sendCompleted()
            }
            pipes.removeAll()
        }
        
        
        // MARK: - Set
        
        public func rac_setObject(value: AnyObject?, forKey defaultName: String) -> SignalProducer<Void, NoError> {
            self.setObject(value, forKey: defaultName)
            return SignalProducer.empty
        }
        
        public func rac_setInteger(value: Int, forKey defaultName: String) -> SignalProducer<Void, NoError> {
            self.setInteger(value, forKey: defaultName)
            return SignalProducer.empty
        }
        
        public func rac_setFloat(value: Float, forKey defaultName: String) -> SignalProducer<Void, NoError> {
            self.setFloat(value, forKey: defaultName)
            return SignalProducer.empty
        }
        
        public func rac_setDouble(value: Double, forKey defaultName: String) -> SignalProducer<Void, NoError> {
            self.setDouble(value, forKey: defaultName)
            return SignalProducer.empty
        }
        
        public func rac_setBool(value: Bool, forKey defaultName: String) -> SignalProducer<Void, NoError> {
            self.setBool(value, forKey: defaultName)
            return SignalProducer.empty
        }
        
        
        // MARK: - Synchronize
        
        public func rac_synchronize() -> SignalProducer<Void, NoError> {
            _  = self.synchronize()
            return SignalProducer.empty
        }
        
        
        // MARK: - Delete
        
        public func rac_removeObjectForKey(defaultName: String) -> SignalProducer<Void, NoError> {
            self.removeObjectForKey(defaultName)
            return SignalProducer.empty
        }
        
        
        // MARK: - Get
        
        public func rac_objectForKey(defaultName: String) -> SignalProducer<AnyObject?, NoError> {
            return SignalProducer(value: objectForKey(defaultName))
        }
        
        public func rac_stringForKey(defaultName: String) -> SignalProducer<String?, NoError> {
            return SignalProducer(value: stringForKey(defaultName))
        }
        
        public func rac_arrayForKey(defaultName: String) -> SignalProducer<[AnyObject]?, NoError> {
            return SignalProducer(value: arrayForKey(defaultName))
        }
        
        public func rac_dictionaryForKey(defaultName: String) -> SignalProducer<[String : AnyObject]?, NoError> {
            return SignalProducer(value: dictionaryForKey(defaultName))
        }
        
        public func rac_dataForKey(defaultName: String) -> SignalProducer<NSData?, NoError> {
            return SignalProducer(value: dataForKey(defaultName))
        }
        
        public func rac_stringArrayForKey(defaultName: String) -> SignalProducer<[String]?, NoError> {
            return SignalProducer(value: stringArrayForKey(defaultName))
        }
        
        public func rac_integerForKey(defaultName: String) -> SignalProducer<Int, NoError> {
            return SignalProducer(value: integerForKey(defaultName))
        }
        
        public func rac_floatForKey(defaultName: String) -> SignalProducer<Float, NoError> {
            return SignalProducer(value: floatForKey(defaultName))
        }
        
        public func rac_doubleForKey(defaultName: String) -> SignalProducer<Double, NoError> {
            return SignalProducer(value: doubleForKey(defaultName))
        }
        
        public func rac_boolForKey(defaultName: String) -> SignalProducer<Bool, NoError> {
            return SignalProducer(value: boolForKey(defaultName))
        }
        
        public func rac_URLForKey(defaultName: String) -> SignalProducer<NSURL?, NoError> {
            return SignalProducer(value: URLForKey(defaultName))
        }
        
    }
    
}