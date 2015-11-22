import Foundation
import UIKit
import ReactiveCocoa

// Say hellow action (without enable/disable property)
private func sayHello() {
    let action: Action<String, String, NoError> = Action<String, String, NoError> { (input) -> SignalProducer<String, NoError> in
        return SignalProducer(value: "hi \(input)")
    }
    action.values.observeNext { (output) -> () in
        print(output) // "hi Pedro"
    }
    _ = action.apply("Pedro")
}

// User tap action (with enable/disable property)
private func userTap() {
    let isEnabled: MutableProperty<Bool> = MutableProperty(true)
    let action: Action<Void, Void, NoError> = Action<Void, Void, NoError>(enabledIf: isEnabled) { (input) -> SignalProducer<Void, NoError> in
        return SignalProducer(value: ())
    }
    action.values.observeNext { () -> () in
        print("User did tap")
    }
    _ = action.apply(()) // User did tap
    isEnabled.value = false
    _ = action.apply(()) // Nothing will be printed
}

// UIButton using a CocoaAction

private func loginAction() {
    let loginButton: UIButton = UIButton()
    let action: Action<Void, Void, NoError> = Action<Void, Void, NoError> { SignalProducer(value: ()) }
    let cocoaAction = CocoaAction(action) { $0 }
    loginButton.addTarget(cocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
}