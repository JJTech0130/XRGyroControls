import Foundation
import CoreSimulator
import simd
import Spatial

// These are probably really inefficient, but whatever they make everything else a ton easier
extension simd_quatf {
    // Convert simd_quatd to simd_quatf
    init(_ quat: simd_quatd) {
        self.init(ix: Float(quat.imag.x), iy: Float(quat.imag.y), iz: Float(quat.imag.z), r: Float(quat.real))
        print("Converting \(quat) to \(self)")
    }
}

extension simd_float4x4 {
    // Convert double4x4 to float4x4
    init(_ mat: double4x4) {
        self.init(columns: (simd_float4(Float(mat.columns.0.x), Float(mat.columns.0.y), Float(mat.columns.0.z), Float(mat.columns.0.w)),
                            simd_float4(Float(mat.columns.1.x), Float(mat.columns.1.y), Float(mat.columns.1.z), Float(mat.columns.1.w)),
                            simd_float4(Float(mat.columns.2.x), Float(mat.columns.2.y), Float(mat.columns.2.z), Float(mat.columns.2.w)),
                            simd_float4(Float(mat.columns.3.x), Float(mat.columns.3.y), Float(mat.columns.3.z), Float(mat.columns.3.w))))
    }
}

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
        print("Writing \(bytes) to offset \(offset)")
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
    
    public static func camera(_ pose: Pose3D) -> IndigoHIDMessage {
        let message = IndigoHIDMessage()
        
        message.write(300 as Int32, at: 0x30)
        
        message.write(simd_float3(pose.position.vector), at: 0x54)
        message.write(simd_quatf(pose.rotation.quaternion), at: 0x64)
        
        return message
    }
    
    public static func manipulator(pose: Pose3D, gaze: Ray3D, pinch: Bool) -> IndigoHIDMessage {
        let message = IndigoHIDMessage()
        
        message.write(302, at: 0x30)
        
        // TODO: Expose pinching, figure out all the different possibilities (what is 'touching' for?)
        message.data[0x34] = 3
        
        message.data[0x38] = 0 // ?
        message.data[0x39] = 2
        
        message.data[0x3A] = 0 // ?
        message.data[0x3B] = 3
        
        message.data[0x3F] = pinch ? 1 : 0 // pinch right
        message.data[0x40] = 1
        message.data[0x41] = 0 // ?
        
        message.write(simd_float3(gaze.origin.vector), at: 0x47)
        message.write(simd_float3(gaze.direction.vector), at: 0x57)
        
        message.write(simd_float4x4(pose.matrix), at: 0x67)
        
        return message
    }
    
    // This doesn't have any observable effects that I can see, but I implemented it for completeness sake.
    public static func dial(_ value: Double) -> IndigoHIDMessage {
        let message = IndigoHIDMessage()
        
        message.data[0x20] = 0x06
        
        message.write(value, at: 0x38)
        
        message.data[0x4C] = 0xC8
        message.data[0x2C] = 0x10
        
        return message
    }
}
