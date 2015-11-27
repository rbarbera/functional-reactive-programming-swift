import Foundation
import ReactiveCocoa

public extension NSUserDefaults {
    
    // MARK: - Set
    
    public func rac_setObject(value: AnyObject?, forKey defaultName: String) -> SignalProducer<Void, NoError> {
        self.setObject(value, forKey: defaultName)
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
    
}


/*

public func boolForKey(defaultName: String) -> Bool
@available(iOS 4.0, *)
public func URLForKey(defaultName: String) -> NSURL?

public func setInteger(value: Int, forKey defaultName: String)
public func setFloat(value: Float, forKey defaultName: String)
public func setDouble(value: Double, forKey defaultName: String)
public func setBool(value: Bool, forKey defaultName: String)
*/