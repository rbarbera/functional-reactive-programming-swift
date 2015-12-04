import Foundation
import ReactiveCocoa


func test() {
    let (innerProducer, innerObserver) = SignalProducer<String, NoError>.buffer(5)
    let (signal, observer) = SignalProducer<String, NoError>.buffer(5)
    signal.flatMap(.Concat) { (input) -> SignalProducer<String, NoError> in
        return innerProducer.map({"\(input)-\($0)"})
    }.startWithNext { (next) -> () in
        print(next)
    }
    innerObserver.sendNext("A") // nothing printed
    innerObserver.sendNext("B") // nothing printed
    innerObserver.sendNext("C") // nothing printed
    innerObserver.sendCompleted() // nothing printed
    observer.sendNext("1") // printed 1-A, 1-B, 1-C
    observer.sendNext("2") // printed 2-A, 2-B, 2-c
}
