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
    
    private func write<T>(_ of: T, at offset: Int) {
        //let of = of as! UInt64
        let bytes: [UInt8] = withUnsafeBytes(of: of) { Array($0) }
        print("Converted \(of) to \(bytes.count) bytes")
        data[offset..<offset+bytes.count] = bytes[...]
    }
    
    private init() {
        // Initialize the backing data to be the correct size, and zeroed out
        data = [UInt8](repeating: 0, count: MemoryLayout<IndigoHIDMessageStruct>.size)
        
        // Set the timestamp to the current time
        write(mach_absolute_time(), at: 0x24)
        
        // Write the constant values
        data[0x18] = 0xA0
        data[0x1C] = 0x01
        data[0x20] = 0x01
        
        //write(300, at: 0x30)
    }
    
    public static func camera(x: Float, y: Float, z: Float, pitch: Float, yaw: Float, roll: Float) -> IndigoHIDMessage {
        let message = IndigoHIDMessage()
        
        message.write(300, at: 0x30)
        
        message.write(x, at: 0x54)
        message.write(y, at: 0x58)
        message.write(z, at: 0x5C)
        
        message.write(pitch, at: 0x64)
        message.write(yaw, at: 0x68)
        message.write(roll, at: 0x6C)
        
        message.write(1.0, at: 0x70) // Not sure why, but this is important
        
        return message
    }
    
    public static func manipulator(_ f1: Float, _ f2: Float, _ f3: Float) -> IndigoHIDMessage {
        let message = IndigoHIDMessage()
        
        message.write(302, at: 0x30)
        
        // Constant values
        message.data[0x34] = 3
        
        message.data[0x38] = 0 // arg4?
        message.data[0x39] = 2
        
        message.data[0x3A] = 0 // arg5?
        message.data[0x3B] = 3
        
        message.data[0x3F] = 0 // arg7
        message.data[0x40] = 1
        message.data[0x41] = 0 // arg8
        
        let dfloats = [-0.25, -0.2, -0.3, 1.0]
        
        // Pq1
        message.write(f1, at: 0x57)
        message.write(f2, at: 0x5B)
        message.write(f3, at: 0x5F)
        
        // q0
        message.write(dfloats[0], at: 0x67)
        message.write(dfloats[1], at: 0x6B)
        message.write(dfloats[2], at: 0x6F)
        
        // q1
        message.write(dfloats[3], at: 0x83)
        
        // q2
        message.write(dfloats[0], at: 0x87)
        message.write(dfloats[1], at: 0x8B)
        message.write(dfloats[2], at: 0x8F)
        
        // q3
        message.write(dfloats[3], at: 0xA3)
        
        
        return message
    }
}
