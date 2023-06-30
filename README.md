# XRGyroControls
This is a replacement for the default controls used in the VisionOS xrOS Simulator. This will allow you to control the simulator camera with an actual VR headset once it is finished. Right now it is in POC stage and can control the simulator, but doesn't actually take input from another headset.

## Installation
1. Disable SIP
2. Disable library validation (`sudo defaults write /Library/Preferences/com.apple.security.libraryvalidation.plist DisableLibraryValidation -bool true`)
3. Install the latest Xcode beta, and install the VisionOS Simulator.
4. Clone the git repo and open it in Xcode
6. Launch the default schema. It should automatically open the Xcode simulator, you will need to manually select the "XRGyroControlsType" simulator device type and launch it.
7. You should be able to control the new simulator type over UDP port 9985. A sample JSON client is in test.py for now, it also accepts OpenTrack and @keithahern's messages on the same port (though they are less flexible)
