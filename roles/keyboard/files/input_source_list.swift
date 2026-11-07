import Carbon
import Foundation

let filter = [kTISPropertyInputSourceType: kTISTypeKeyboardLayout!] as CFDictionary
let sources = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource] ?? []

for source in sources {
    let raw = TISGetInputSourceProperty(source, kTISPropertyInputSourceID)!
    print(Unmanaged<CFString>.fromOpaque(raw).takeUnretainedValue() as String)
}
