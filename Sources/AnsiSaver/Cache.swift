import Foundation

enum Cache {

    private static let basePath: String = {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        return (path as NSString).appendingPathComponent("AnsiSaver")
    }()

    static func ansPath(forPack pack: String, file: String) -> String {
        return (basePath as NSString)
            .appendingPathComponent("packs/\(pack)/\(file)")
    }

    static func pngPath(forAnsPath ansPath: String) -> String {
        return (ansPath as NSString).deletingPathExtension + ".png"
    }

    static func urlCachePath(for urlString: String) -> String {
        let hash = sha256(urlString)
        return (basePath as NSString)
            .appendingPathComponent("urls/\(hash).ans")
    }

    static func read(_ path: String) -> Data? {
        return FileManager.default.contents(atPath: path)
    }

    static func write(_ data: Data, to path: String) {
        let dir = (path as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(
            atPath: dir, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: path, contents: data)
    }

    static func exists(_ path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    static func clearPacks() {
        let packsDir = (basePath as NSString).appendingPathComponent("packs")
        try? FileManager.default.removeItem(atPath: packsDir)
    }

    static func clearAll() {
        try? FileManager.default.removeItem(atPath: basePath)
    }

    private static func sha256(_ string: String) -> String {
        let data = Data(string.utf8)
        var hash = [UInt8](repeating: 0, count: 32)
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

import CommonCrypto
