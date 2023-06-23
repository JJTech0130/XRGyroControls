import Foundation
import SimulatorKit

@objc class SimulatorSupport : NSObject, SimDeviceUserInterfacePlugin {
    @objc init(with: SimDevice) {
        print("XRGyroControls: Initialized with device: \(with)")
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
