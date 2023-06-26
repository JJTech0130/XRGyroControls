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
        
        //Float
        //let firstValue: Float = 1.0
        //l//et firstValueBytes = withUnsafeBytes(of: firstValue) { Array($0) }
        //print("firstValueBytes: \(firstValueBytes)")
    }
    
    public func write_simd_bytes(q0: [UInt8], q1: [UInt8]) {
        // Make sure that q0 and q1 are both 16 bytes long
        guard q0.count == 16 && q1.count == 16 else {
            fatalError("q0 and q1 must both be 16 bytes long")
        }
        
        // First 8 bytes of q0 are written to 0x54
        data[0x54..<0x54+8] = q0[0..<8]
        // Next 4 bytes of q0 are written to 0x5C
        data[0x5C..<0x5C+4] = q0[8..<12]
        // All 16 bytes of q1 are written to 0x64
        data[0x64..<0x64+16] = q1[0..<16]
    }
    
    
    
    
    
}
