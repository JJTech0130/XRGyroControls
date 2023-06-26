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
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            self.send_test_message(cnt)
        }
    
    }
    
    func send_test_message(_ cnt: Int) {
        print("Sending HID message")
        let message = IndigoHIDMessage()

        // If it's even
        if cnt % 2 == 0 {
            message.write_simd_bytes(q0: [0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0x80,0x3F], q1: [0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0x80,0x3F])
        } else {
            let q1: [UInt8] = [0x25, 0x3d, 0x1a, 0xbd, 0x84, 0xe1, 0x73, 0x3f, 0x41, 0x7b, 0x07, 0x3e, 0xb6, 0xd2, 0x8a, 0x3e]
            message.write_simd_bytes(q0: [0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0x80,0x3F], q1: q1)
        }

        hid_client.send(message: message.as_struct())
    }
    
    @objc func overlayView() -> NSView {
        return NSView()
    }
    
    @objc func toolbar() -> NSToolbar {
        return NSToolbar()
    }
}
