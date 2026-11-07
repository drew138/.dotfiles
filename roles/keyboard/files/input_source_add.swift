import Carbon
import Foundation

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

func isEnabled(_ source: TISInputSource) -> Bool {
    let raw = TISGetInputSourceProperty(source, kTISPropertyInputSourceIsEnabled)!
    return CFBooleanGetValue(Unmanaged<CFBoolean>.fromOpaque(raw).takeUnretainedValue())
}

let ids = Array(CommandLine.arguments.dropFirst())
if ids.isEmpty { fail("usage: input_source_add <id>...") }

for id in ids {
    let filter = [kTISPropertyInputSourceID: id] as CFDictionary
    let found = TISCreateInputSourceList(filter, true)?.takeRetainedValue() as? [TISInputSource]
    guard let source = found?.first else { fail("\(id) is not installed") }
    if isEnabled(source) { continue }
    if TISEnableInputSource(source) != noErr { fail("could not enable \(id)") }
    print("enabled \(id)")
}
