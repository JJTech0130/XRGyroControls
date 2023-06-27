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
        
        // Reset the camera to the center
        hid_client.send(message: IndigoHIDMessage.camera(x: 0.0, y: 0.0, z: 0.0, pitch: 0.0, yaw: 0.0, roll: 0.0).as_struct())
    }
    
    var sliders: [NSSlider] = []
    
    @objc public func sliderChanged(sender: NSSlider) {
        //print("Slider changed to \(sender.doubleValue)")
        hid_client.send(message: IndigoHIDMessage.manipulator(sliders[0].floatValue, sliders[1].floatValue, sliders[2].floatValue).as_struct())
    }
    
    @objc func overlayView() -> NSView {
        let view = NSView()
        
        sliders = [NSSlider(target: self, action: #selector(self.sliderChanged)),
                   NSSlider(target: self, action: #selector(self.sliderChanged)),
                   NSSlider(target: self, action: #selector(self.sliderChanged))]
        
        for slider in sliders {
            slider.minValue = -1.0
            slider.maxValue = 1.0
        }
        
        // OK so I think this is a "3D direction vector" of where the eye tracking is pointing
        // I don't understand 3D maths at all so...
        sliders[0].floatValue = -0.40874016
        sliders[1].floatValue = -0.07154943
        sliders[2].floatValue = -0.9098418
        
        
        // Create a stack of sliders
        let stack = NSStackView(views: sliders)
        view.addSubview(stack)

        stack.orientation = .vertical
        stack.distribution = .fillEqually
        stack.edgeInsets = NSEdgeInsetsMake(10, 10, 10, 10)
        
        let constraints = [
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.widthAnchor.constraint(equalToConstant: 300),
            stack.heightAnchor.constraint(equalToConstant: 100),
            stack.heightAnchor.constraint(equalTo: stack.widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)

        return view
    }
    
    @objc func toolbar() -> NSToolbar {
        return NSToolbar()
    }
}
