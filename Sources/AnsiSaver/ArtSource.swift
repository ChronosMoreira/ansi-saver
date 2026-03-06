import Foundation

protocol ArtSource {
    func loadArtPaths(completion: @escaping ([String]) -> Void)
}

class FolderSource: ArtSource {

    private let folderPath: String

    init(folderPath: String) {
        self.folderPath = folderPath
    }

    func loadArtPaths(completion: @escaping ([String]) -> Void) {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(atPath: folderPath) else {
            completion([])
            return
        }

        let ansiExtensions: Set<String> = ["ans", "ansi", "asc", "diz", "ice", "bin", "xb", "pcb", "adf"]

        let paths = contents
            .filter { name in
                let ext = (name as NSString).pathExtension.lowercased()
                return ansiExtensions.contains(ext)
            }
            .map { (folderPath as NSString).appendingPathComponent($0) }

        completion(paths)
    }
}
