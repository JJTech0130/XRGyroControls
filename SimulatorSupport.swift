import Foundation
import SimulatorKit
import AppKit

@objc class SimulatorSupport : NSObject, SimDeviceUserInterfacePlugin {
    private let device: SimDevice
    
    @objc init(with device: SimDevice) {
        self.device = device
        print("XRGyroControls: Initialized with device: \(device)")
    }
    
    @objc func overlayView() -> NSView {
        print("overlayView called")
        print(device)
        
        // Return a dummy view for now
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.red.cgColor
        return view
    }
    
    @objc func toolbar() -> NSToolbar {
        print("toolbar called!")

        let toolbar = NSToolbar(identifier: "XRGyroControls")
        toolbar.allowsUserCustomization = false
        toolbar.displayMode = .iconOnly
        return toolbar
    }
}
