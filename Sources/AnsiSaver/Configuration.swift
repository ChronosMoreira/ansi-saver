import Foundation

struct Configuration {

    private static let suiteName = "com.lardissone.AnsiSaver"

    private enum Key {
        static let packURLs = "packURLs"
        static let fileURLs = "fileURLs"
        static let localFolderPath = "localFolderPath"
        static let transitionMode = "transitionMode"
        static let scrollSpeed = "scrollSpeed"
    }

    var packURLs: [String]
    var fileURLs: [String]
    var localFolderPath: String?
    var transitionMode: Int
    var scrollSpeed: Double

    static func load() -> Configuration {
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        return Configuration(
            packURLs: defaults.stringArray(forKey: Key.packURLs) ?? [],
            fileURLs: defaults.stringArray(forKey: Key.fileURLs) ?? [],
            localFolderPath: defaults.string(forKey: Key.localFolderPath),
            transitionMode: defaults.integer(forKey: Key.transitionMode),
            scrollSpeed: defaults.object(forKey: Key.scrollSpeed) != nil
                ? defaults.double(forKey: Key.scrollSpeed)
                : 50.0
        )
    }

    func save() {
        guard let defaults = UserDefaults(suiteName: Configuration.suiteName) else { return }
        defaults.set(packURLs, forKey: Key.packURLs)
        defaults.set(fileURLs, forKey: Key.fileURLs)
        defaults.set(localFolderPath, forKey: Key.localFolderPath)
        defaults.set(transitionMode, forKey: Key.transitionMode)
        defaults.set(scrollSpeed, forKey: Key.scrollSpeed)
    }
}
