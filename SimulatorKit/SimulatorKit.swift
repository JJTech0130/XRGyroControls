import Foundation
import CoreSimulator

@objc public protocol SimDeviceUserInterfacePlugin {}

@objc public class SimDeviceLegacyHIDClient : NSObject {
    // The padding is to make sure that the offset aligns with the original, when Swift tries to do tricky optimizations
    // I don't completely understand it yet, but this works and I'm not touching it
    private var padding001: Int64 = 0
    private var padding002: Int64 = 0
    private var padding003: Int64 = 0
    private var padding004: Int64 = 0
    private var padding005: Int64 = 0
    private var padding006: Int64 = 0
    private func padding07() {}
    private func padding08() {}
    private func padding09() {}
    private func padding10() {}
    private func padding11() {}
    
    @objc public init(device: SimDevice) throws {}
   
    // Offset: 0x140
    @objc public func send(message: UnsafeMutablePointer<IndigoHIDMessageStruct>) {}

}
