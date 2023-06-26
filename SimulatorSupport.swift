import Foundation
import SimulatorKit
import CoreSimulator
import AppKit

@objc class SimulatorSupport : NSObject, SimDeviceUserInterfacePlugin {
    
    private let device: SimDevice
    private let hid_client: SimDeviceLegacyHIDClient
        
    @objc init(with device: SimDevice) {
        self.device = device
        print("XRGyroControls: Initialized with device: \(device)")
        self.hid_client = try! SimDeviceLegacyHIDClient(device: device)
        print("XRGyroControls: Initialized HID client")
        super.init()
        
        // Schedule a HID message to be sent every 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            self.send_test_message()
        }
    
    }
    
    func send_test_message() {
        print("Sending HID message")
        let message = IndigoHIDMessage()
        hid_client.send(message: message.as_struct())
    }
    
    @objc func overlayView() -> NSView {
        return NSView()
    }
    
    @objc func toolbar() -> NSToolbar {
        return NSToolbar()
    }
}
