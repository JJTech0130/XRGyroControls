import Foundation
import SimulatorKit
import CoreSimulator
import AppKit
import Spatial

@objc class SimulatorSupport : NSObject, SimDeviceUserInterfacePlugin {
    
    private let device: SimDevice
    private let hid_client: SimDeviceLegacyHIDClient
    private let server: UDPServer
        
    @objc init(with device: SimDevice) {
        self.device = device
        print("XRGyroControls: Initialized with device: \(device)")
        self.hid_client = try! SimDeviceLegacyHIDClient(device: device)
        print("XRGyroControls: Initialized HID client")
        
        server = try! UDPServer(hid_client, on: 9985)

        super.init()
        
        // Here's an example using a 4x4 transform matrix, as logged by the simulator
        // Should point the pointer at the "Environments" menu item
        let fxf = simd_float4x4([[0.9999595, 0.0, -0.008998766, 0.0], [0.0, 1.0, 0.0, 0.0], [0.008998766, 0.0, 0.9999595, 0.0], [0.009089867, 0.0, 0.009959124, 1.0]])
        
        let transform = ProjectiveTransform3D(fxf)
        
        let pose = Pose3D(transform: transform)!
        
        hid_client.send(message: IndigoHIDMessage.camera(pose).as_struct())
        
        hid_client.send(message: IndigoHIDMessage.manipulator(pose: pose, gaze: Ray3D(direction: Vector3D(x: -0.40874016, y: -0.07154943, z: -0.9098418))).as_struct())
    }
    
    @objc func overlayView() -> NSView {
        return NSView()
    }
    
    @objc func toolbar() -> NSToolbar {
        return NSToolbar()
    }
}
