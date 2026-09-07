import Foundation
import CoreAudio

func fail(_ message: String) -> Never {
  FileHandle.standardError.write(Data((message + "\n").utf8))
  exit(1)
}
func address(_ selector: AudioObjectPropertySelector, _ scope: AudioObjectPropertyScope) -> AudioObjectPropertyAddress {
  AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: kAudioObjectPropertyElementMain)
}
var defaultAddress = address(kAudioHardwarePropertyDefaultInputDevice, kAudioObjectPropertyScopeGlobal)
var device = AudioDeviceID(0)
var size = UInt32(MemoryLayout<AudioDeviceID>.size)
guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &defaultAddress, 0, nil, &size, &device) == noErr, device != 0 else {
  fail("No default microphone is available.")
}
var muteAddress = address(kAudioDevicePropertyMute, kAudioDevicePropertyScopeInput)
var mute = UInt32(0)
size = UInt32(MemoryLayout<UInt32>.size)
guard AudioObjectGetPropertyData(device, &muteAddress, 0, nil, &size, &mute) == noErr else {
  fail("This microphone does not expose a mute control. Select another microphone in Sound settings.")
}
if CommandLine.arguments.contains("--check") {
  print(mute == 0 ? "Microphone is unmuted" : "Microphone is muted")
  exit(0)
}
var uidAddress = address(kAudioDevicePropertyDeviceUID, kAudioObjectPropertyScopeGlobal)
var uid: Unmanaged<CFString>? = nil
size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
if AudioObjectGetPropertyData(device, &uidAddress, 0, nil, &size, &uid) == noErr, let uid = uid?.takeRetainedValue() {
  let settings = UserDefaults(suiteName: "org.hammerspoon.Hammerspoon")
  if let saved = settings?.dictionary(forKey: "pushToTalk.levels")?[uid as String] as? NSNumber {
    var volume = Float32(min(100, max(0, saved.doubleValue)) / 100)
    var volumeAddress = address(kAudioDevicePropertyVolumeScalar, kAudioDevicePropertyScopeInput)
    if AudioObjectHasProperty(device, &volumeAddress) {
      guard AudioObjectSetPropertyData(device, &volumeAddress, 0, nil, UInt32(MemoryLayout<Float32>.size), &volume) == noErr else {
        fail("Could not restore the saved microphone volume.")
      }
    }
  }
}
mute = 0
guard AudioObjectSetPropertyData(device, &muteAddress, 0, nil, UInt32(MemoryLayout<UInt32>.size), &mute) == noErr else {
  fail("Could not unmute the microphone.")
}
size = UInt32(MemoryLayout<UInt32>.size)
guard AudioObjectGetPropertyData(device, &muteAddress, 0, nil, &size, &mute) == noErr, mute == 0 else {
  fail("The microphone is still muted.")
}
print("Normal microphone restored. Push-to-talk is off.")
