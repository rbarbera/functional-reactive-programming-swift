import Foundation
import ReactiveCocoa

public enum UserDefaultsError: ErrorType {
    case SynchronizationError
}

public extension NSUserDefaults {
    
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