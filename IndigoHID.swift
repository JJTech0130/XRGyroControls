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
    
    private func write<T>(_ of: T, at offset: Int) {
        let bytes: [UInt8] = withUnsafeBytes(of: of) { Array($0) }
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
        // HIDMessage - sending .manipulator with pinching (L=false, R=false), touching (L=false, R=false), matrix: simd_float4x4([[1.0, 0.0, 0.0, 0.0], [0.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 0.0], [0.0, 0.0, 0.0, 1.0]]), gaze=RERay(origin: SIMD3<Float>(0.0, 0.0, 0.0), direction: SIMD3<Float>(-0.03173566, -0.04234394, -0.99859893), length: 10.0)
        
        let message = IndigoHIDMessage()
        
        message.write(302, at: 0x30)
        
        // TODO: Expose pinching, figure out all the different possibilities (what is 'touching' for?)
        message.data[0x34] = 3
        
        message.data[0x38] = 0 // ?
        message.data[0x39] = 2
        
        message.data[0x3A] = 0 // ?
        message.data[0x3B] = 3
        
        message.data[0x3F] = 0 // pinch right
        message.data[0x40] = 1
        message.data[0x41] = 0 // ?
        
        // (I assume) gaze origin
        message.write(0.0, at: 0x47)
        message.write(0.0, at: 0x4B)
        message.write(0.0, at: 0x4F)
        
        // gaze direction
        message.write(f1, at: 0x57)
        message.write(f2, at: 0x5B)
        message.write(f3, at: 0x5F)
        
        // Pose matrix? Maybe related to the pan/yaw/roll thing because it's printing out the same thing as the pre-converted simd matrix
        // If it is that I have no idea why tf it is duplicated... idk
        message.write(-0.25, at: 0x67)
        message.write(-0.2,  at: 0x6B)
        message.write(-0.3,  at: 0x6F)
        message.write(0.0,   at: 0x73)
        
        message.write(0.0,   at: 0x77)
        message.write(0.0,   at: 0x7B)
        message.write(0.0,   at: 0x7F)
        message.write(1.0,   at: 0x83)
        
        message.write(-0.25, at: 0x87)
        message.write(-0.2,  at: 0x8B)
        message.write(-0.3,  at: 0x8F)
        message.write(0.0,   at: 0x93)
        
        message.write(0.0,   at: 0x97)
        message.write(0.0,   at: 0x9B)
        message.write(0.0,   at: 0x9F)
        message.write(1.0,   at: 0xA3)
        
        
        return message
    }
}
