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
        print("data: \(data)")
        // Make sure that the backing data is the correct size
        guard data.count == MemoryLayout<IndigoHIDMessageStruct>.size else {
            fatalError("IndigoHIDMessage backing data is not the correct size")
        }
        
        // Allocate a new struct and copy the bytes to it
        let ptr = UnsafeMutablePointer<IndigoHIDMessageStruct>.allocate(capacity: 1)
        ptr.initialize(to: data.withUnsafeBufferPointer { $0.baseAddress!.withMemoryRebound(to: IndigoHIDMessageStruct.self, capacity: 1) { $0.pointee } })
        return ptr
    
    }
    
    init() {
        // Initialize the backing data to be the correct size, and zeroed out
        data = [UInt8](repeating: 0, count: MemoryLayout<IndigoHIDMessageStruct>.size)
        
        // Set the timestamp to the current time
        let timestamp = mach_absolute_time()
        let timestamp_bytes = withUnsafeBytes(of: timestamp) { Array($0) }
        // Write it at offset 0x24, it's 64 bits
        data[0x24..<0x24+8] = timestamp_bytes[0..<8]
        
        // Write the constant values
        data[0x18] = 0xA0
        data[0x1C] = 0x01
        data[0x20] = 0x01
        
        data[0x30..<0x30+4] = [0x2C, 0x01, 0x00, 0x00] // Int32: 300
    }
    
    private func write_float(_ float: Float, offset: Int) {
        let bytes: [UInt8] = withUnsafeBytes(of: float) { Array($0) }
        data[offset..<offset+bytes.count] = bytes[...]
    }
    
    public func pose(x: Float, y: Float, z: Float, pitch: Float, yaw: Float, roll: Float) {
        write_float(x, offset: 0x54)
        write_float(y, offset: 0x58)
        write_float(z, offset: 0x5C)
        
        write_float(pitch, offset: 0x64)
        write_float(yaw, offset: 0x68)
        write_float(roll, offset: 0x6C)
        
        write_float(1.0, offset: 0x70) // Not sure why, but this is important
    }
}
