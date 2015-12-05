import Foundation
import ReactiveCocoa
import Result

let (signal, observer) = Signal<String, NoError>.pipe()
signal.throttle(3, onScheduler: QueueScheduler())

/// Does not forward any values from `self` until `trigger` sends a Next or
/// Completed event, at which point the returned signal behaves exactly like
/// `signal`.