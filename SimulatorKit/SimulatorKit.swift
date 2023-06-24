import Foundation
import CoreSimulator

@objc public protocol SimDeviceUserInterfacePlugin {}

@objc public class SimDeviceLegacyHIDClient : NSObject {
    @objc public init(device: SimDevice) throws {
        print("Stub called?!")
    }
}
