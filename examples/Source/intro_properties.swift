import Foundation
import ReactiveCocoa

// 1. AnyProperty
private let anyPropertyProducer: AnyProperty<String> = AnyProperty(initialValue: "initial-value", producer: SignalProducer(value: "new-value"))
private let anyPropertySignal: AnyProperty<String> = AnyProperty(initialValue: "initial-value", signal: Signal<String, NoError> { observer -> Disposable? in
    observer.sendNext("new-value")
    return nil
})

// 2. ConstantProperty
private let constantProperty: ConstantProperty<String> = ConstantProperty("value")