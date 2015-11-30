import Foundation
import ReactiveCocoa

func sum(amount: Int)(input: Signal<Int, NoError>) -> Signal<Int, NoError> {
    return input.map({$0 + amount})
}

let integerPipe = Signal<Int, NoError>.pipe()
let integerObserver = integerPipe.1
let integerSignal = integerPipe.0

let sum2 = sum(2)
let signal = integerSignal |> sum2

