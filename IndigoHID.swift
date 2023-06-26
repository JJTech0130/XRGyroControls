//
//  IndigoHID.swift
//  XRGyroControls
//
//  Created by James Gill on 6/25/23.
//

import Foundation
import CoreSimulator

class IndigoHIDMessage {
    /// You must NOT change the length to anything other than 0xC0
    public var data: [UInt8] = []
    
    public func as_struct() -> UnsafeMutablePointer<IndigoHIDMessageStruct> {
        //print("data: \(data)")
        // Make sure that the backing data is the correct size
        guard data.count == MemoryLayout<IndigoHIDMessageStruct>.size else {
            fatalError("IndigoHIDMessage backing data is not the correct size")
        }
        
        // Allocate a new struct and copy the bytes to it
        let ptr = UnsafeMutablePointer<IndigoHIDMessageStruct>.allocate(capacity: 1)
        ptr.initialize(to: data.withUnsafeBufferPointer { $0.baseAddress!.withMemoryRebound(to: IndigoHIDMessageStruct.self, capacity: 1) { $0.pointee } })
        return ptr
    
    }
    
    private func write(_ of: Any, at offset: Int) {
        let bytes: [UInt8] = withUnsafeBytes(of: of) { Array($0) }
        data[offset..<offset+bytes.count] = bytes[...]
    }
    
    init() {
        // Initialize the backing data to be the correct size, and zeroed out
        data = [UInt8](repeating: 0, count: MemoryLayout<IndigoHIDMessageStruct>.size)
        
        // Set the timestamp to the current time
        write(mach_absolute_time, at: 0x24)
        
        // Write the constant values
        data[0x18] = 0xA0
        data[0x1C] = 0x01
        data[0x20] = 0x01
        
        write(300, at: 0x30)
    }
    
    public func pose(x: Float, y: Float, z: Float, pitch: Float, yaw: Float, roll: Float) {
        write(x, at: 0x54)
        write(y, at: 0x58)
        write(z, at: 0x5C)
        
        write(pitch, at: 0x64)
        write(yaw, at: 0x68)
        write(roll, at: 0x6C)
        
        write(1.0, at: 0x70) // Not sure why, but this is important
    }
}
