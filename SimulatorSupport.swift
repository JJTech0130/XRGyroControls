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
        
        var cnt = 0
        // Schedule a HID message to be sent every 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            cnt += 1
            self.send_test_message(cnt)
        }
    
    }
    
    func send_test_message(_ cnt: Int) {
        print("Sending HID message")
        //let message = IndigoHIDMessage.pose(x: 0.0, y: Float(cnt) / 1000, z: 0.0, pitch: 0.0, yaw: 0.0, roll: 0.0)
        // Should create a very slow rise
        //message.pose(x: 0.0, y: Float(cnt) / 1000, z: 0.0, pitch: 0.0, yaw: 0.0, roll: 0.0)
        //hid_client.send(message: IndigoHIDMessage.camera(x: 0.0, y: Float(cnt) / 1000, z: 0.0, pitch: 0.0, yaw: 0.0, roll: 0.0).as_struct())
        hid_client.send(message: IndigoHIDMessage.camera(x: 0.0, y: 0.0, z: 0.0, pitch: 0.0, yaw: 0.0, roll: 0.0).as_struct())
        hid_client.send(message: IndigoHIDMessage.manipulator(-0.31972468, -0.041431412, -0.9466042).as_struct())
    }
    
    @objc func overlayView() -> NSView {
        return NSView()
    }
    
    @objc func toolbar() -> NSToolbar {
        return NSToolbar()
    }
}
