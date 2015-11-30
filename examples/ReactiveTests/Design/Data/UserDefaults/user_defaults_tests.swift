import Foundation
import Quick
import Nimble

@testable import Reactive

class UserDefaultsTests: QuickSpec {
    
    override func spec() {
        
        describe("singleton instance") {
            
            it("standard user defaults should return an UserDefaults") {
                expect(Reactive.UserDefaults.standardUserDefaults()).to(beAKindOf(Reactive.UserDefaults.classForCoder()))
            }
        }
        
        describe("observation") {
            
            var defaults: Reactive.UserDefaults?
            
            beforeSuite {
                defaults = Reactive.UserDefaults.standardUserDefaults() as! Reactive.UserDefaults
            }
            
            it("should notify observers when the object under a given key changes") {
                waitUntil(action: { (done) -> Void in
                    defaults?.observe("test").observeNext({ (key, value) -> () in
                        done()
                    })
                    defaults?.setObject("value", forKey: "test")
                    defaults?.synchronize()
                })
            }
            
        }
        
    }
    
}