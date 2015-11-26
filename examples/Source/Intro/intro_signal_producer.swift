import Foundation
import Result
import ReactiveCocoa

// 1. Initialization passing a closure with the operation
private let operationProducer: SignalProducer<String, NoError> = SignalProducer { (observer, disposable) in
    observer.sendNext("Ey ya!")
    observer.sendCompleted()
}

// 2. Initialization using a buffer
private func buffer() {
    let _buffer = SignalProducer<String, NoError>.buffer(2)
    let bufferProducer = _buffer.0
    let bufferObserver: Observer<String, NoError> = _buffer.1
    bufferProducer.startWithNext { value in
        print(value)
    }
    bufferObserver.sendNext("yai!")
}


// 3. Initialization of a value producer
private let valueProducer: SignalProducer<String, NoError> = SignalProducer(value: "Ey ya!")

// 4. Initialization of a result producer
private let resultProducer: SignalProducer<String, NoError> = SignalProducer(result: Result(value: "Ey ya!"))

// 5. Initialization of an error producer
private enum Error: ErrorType { case Unknown }
private let errorProducer: SignalProducer<String, Error> = SignalProducer(error: Error.Unknown)

// 6. Initialization of an empty producer
private let emptyProducer: SignalProducer<String, NoError> = SignalProducer.empty

// 7. Initialization of a producer that never sends events
private let neverProducer: SignalProducer<String, NoError> = SignalProducer.never