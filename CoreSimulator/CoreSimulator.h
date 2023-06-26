#import <Foundation/Foundation.h>

//! Project version number for CoreSimulator.
FOUNDATION_EXPORT double CoreSimulatorVersionNumber;

//! Project version string for CoreSimulator.
FOUNDATION_EXPORT const unsigned char CoreSimulatorVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CoreSimulator/PublicHeader.h>

@interface SimDevice : NSObject
@end

struct IndigoHIDMessageStruct{
    uint8_t bytes[0xc0];
};

