import Foundation
import ReactiveCocoa
import CoreLocation

class LocationManager: CLLocationManager, CLLocationManagerDelegate {
    
    enum GPSError: ErrorType { }
    
    // MARK: - Attributes
    
    private let gpsObserver: Observer<CLLocation, GPSError>
    let gpsSignal: Signal<CLLocation, GPSError>
    
    
    // MARK: - Init
    
    override init() {
        let gps = Signal<CLLocation, GPSError>.pipe()
        gpsObserver = gps.1
        gpsSignal = gps.0
        super.init()
        self.delegate = self
    }
    
    
    // MARK: - Deinit
    
    deinit {
        gpsObserver.sendCompleted()
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        gpsObserver.sendNext(location)
    }
}