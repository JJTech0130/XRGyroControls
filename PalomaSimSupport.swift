import Foundation
import SimulatorKit

@objc class PalomaSimSupport : NSObject, SimDeviceUserInterfacePlugin {
    @objc init(with: SimDevice) {
        print("Initialized with device: \(with)")
    }
    
    @objc func overlayView() {
        print("overlayView called")
    }
    
    @objc func toolbar() {
        print("toolbar called!")
    }
    
    @objc func window() {
        print("windows called")
    }
}
