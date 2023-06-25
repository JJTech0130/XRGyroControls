#import <Foundation/Foundation.h>

//! Project version number for CoreSimulator.
FOUNDATION_EXPORT double CoreSimulatorVersionNumber;

//! Project version string for CoreSimulator.
FOUNDATION_EXPORT const unsigned char CoreSimulatorVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CoreSimulator/PublicHeader.h>

@interface SimDevice : NSObject
@end

// This isn't really from CoreSimulator, but I'm defining it here as it doesn't really matter
struct IndigoHIDMessageStruct{
   // uint8_t bytes[0xc0];
    
};

