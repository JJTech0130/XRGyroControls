import Foundation
import SimulatorKit
import CoreSimulator
import AppKit


@objc class SimulatorSupport : NSObject, SimDeviceUserInterfacePlugin {
    
    private let device: SimDevice
    private let hid_client: SimDeviceLegacyHIDClient
    
    private func createIndigoMessage(_ bytes: [UInt8]) -> UnsafeMutablePointer<IndigoHIDMessageStruct> {
        // Covert the array of bytes to a tuple :pain:
        let bytes_tuple = (
            bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15],
            bytes[16], bytes[17], bytes[18], bytes[19], bytes[20], bytes[21], bytes[22], bytes[23],
            bytes[24], bytes[25], bytes[26], bytes[27], bytes[28], bytes[29], bytes[30], bytes[31],
            bytes[32], bytes[33], bytes[34], bytes[35], bytes[36], bytes[37], bytes[38], bytes[39],
            bytes[40], bytes[41], bytes[42], bytes[43], bytes[44], bytes[45], bytes[46], bytes[47],
            bytes[48], bytes[49], bytes[50], bytes[51], bytes[52], bytes[53], bytes[54], bytes[55],
            bytes[56], bytes[57], bytes[58], bytes[59], bytes[60], bytes[61], bytes[62], bytes[63],
            bytes[64], bytes[65], bytes[66], bytes[67], bytes[68], bytes[69], bytes[70], bytes[71],
            bytes[72], bytes[73], bytes[74], bytes[75], bytes[76], bytes[77], bytes[78], bytes[79],
            bytes[80], bytes[81], bytes[82], bytes[83], bytes[84], bytes[85], bytes[86], bytes[87],
            bytes[88], bytes[89], bytes[90], bytes[91], bytes[92], bytes[93], bytes[94], bytes[95],
            bytes[96], bytes[97], bytes[98], bytes[99], bytes[100], bytes[101], bytes[102], bytes[103],
            bytes[104], bytes[105], bytes[106], bytes[107], bytes[108], bytes[109], bytes[110], bytes[111],
            bytes[112], bytes[113], bytes[114], bytes[115], bytes[116], bytes[117], bytes[118], bytes[119],
            bytes[120], bytes[121], bytes[122], bytes[123], bytes[124], bytes[125], bytes[126], bytes[127],
            bytes[128], bytes[129], bytes[130], bytes[131], bytes[132], bytes[133], bytes[134], bytes[135],
            bytes[136], bytes[137], bytes[138], bytes[139], bytes[140], bytes[141], bytes[142], bytes[143],
            bytes[144], bytes[145], bytes[146], bytes[147], bytes[148], bytes[149], bytes[150], bytes[151],
            bytes[152], bytes[153], bytes[154], bytes[155], bytes[156], bytes[157], bytes[158], bytes[159],
            bytes[160], bytes[161], bytes[162], bytes[163], bytes[164], bytes[165], bytes[166], bytes[167],
            bytes[168], bytes[169], bytes[170], bytes[171], bytes[172], bytes[173], bytes[174], bytes[175],
            bytes[176], bytes[177], bytes[178], bytes[179], bytes[180], bytes[181], bytes[182], bytes[183],
            bytes[184], bytes[185], bytes[186], bytes[187], bytes[188], bytes[189], bytes[190], bytes[191]
        )
        let message_ptr = UnsafeMutablePointer<IndigoHIDMessageStruct>.allocate(capacity: 1)
        message_ptr.initialize(to: IndigoHIDMessageStruct(bytes: bytes_tuple))
        return message_ptr
    }
    
    
    @objc init(with device: SimDevice) {
        self.device = device
        print("XRGyroControls: Initialized with device: \(device)")
        self.hid_client = try! SimDeviceLegacyHIDClient(device: device)
        print("XRGyroControls: Initialized HID client")
        super.init()
        let message = createIndigoMessage([
            00,00,00,00,00,00,00,00,00,00, 00, 00, 00, 00, 00, 00,
                                                     00,00,00,00,00,00,00,00,0xa0,00,00,00,0x01,00,00,00,
01,00,00,00,0x5e,0xe7,0x7e,0x20,0xd6,01,00,00,00,00,00,00,
0x2c,01,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
                                                     00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
00,00,0x80,0x3f,00,00,00,00,00,00,00,00,00,00,00,00,
00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,
00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00])
//        // Copy the message to a malloc'd block of memory so it can be freed by C
//        let message_ptr = UnsafeMutablePointer<IndigoHIDMessageStruct>.allocate(capacity: 1)
//        message_ptr.initialize(to: message)
//        print("wat2")
//        // Print pointer for debugging
//        print("ptr: \(message_ptr)")
        hid_client.send(message: message)
        print("XRGyroControls: Sent message")
    }
    
    @objc func overlayView() -> NSView {
        print("overlayView called")
        print(device)
        
        // Return a dummy view for now
        let view = NSView()
        //view.wantsLayer = true
        //view.layer?.backgroundColor = NSColor.red.cgColor
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
