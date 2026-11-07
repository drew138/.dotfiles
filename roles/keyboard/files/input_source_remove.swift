import Carbon
import Foundation

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

func enabledSource(_ id: String) -> TISInputSource? {
    let filter = [kTISPropertyInputSourceID: id] as CFDictionary
    let sources = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource]
    return sources?.first
}

let ids = Array(CommandLine.arguments.dropFirst())
if ids.isEmpty { fail("usage: input_source_remove <id>...") }

for id in ids {
    guard let source = enabledSource(id) else { continue }
    TISDisableInputSource(source)
    // macOS reports success even when it refuses to disable the last enabled keyboard.
    if enabledSource(id) != nil { fail("could not disable \(id)") }
    print("disabled \(id)")
}
