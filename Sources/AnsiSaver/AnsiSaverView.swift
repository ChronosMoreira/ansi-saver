import ScreenSaver

class AnsiSaverView: ScreenSaverView {

    private var currentImage: NSImage?
    private var artPaths: [String] = []
    private var currentIndex = 0

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        wantsLayer = true
        animationTimeInterval = 1.0 / 30.0
        loadArt()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func loadArt() {
        let config = Configuration.load()
        var sources: [ArtSource] = []

        if let folderPath = config.localFolderPath, !folderPath.isEmpty {
            sources.append(FolderSource(folderPath: folderPath))
        }

        guard !sources.isEmpty else { return }

        for source in sources {
            source.loadArtPaths { [weak self] paths in
                self?.artPaths.append(contentsOf: paths)
                if self?.currentImage == nil {
                    self?.showNextArt()
                }
            }
        }
    }

    private func showNextArt() {
        guard !artPaths.isEmpty else { return }
        let path = artPaths[currentIndex % artPaths.count]
        currentIndex += 1

        if let image = Renderer.render(ansFileAt: path) {
            currentImage = image
            setNeedsDisplay(bounds)
        }
    }

    override func draw(_ rect: NSRect) {
        NSColor.black.setFill()
        rect.fill()

        guard let image = currentImage else { return }

        let imageSize = image.size
        let viewSize = bounds.size

        let scale = min(viewSize.width / imageSize.width, viewSize.height / imageSize.height)
        let drawSize = NSSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let origin = NSPoint(
            x: (viewSize.width - drawSize.width) / 2,
            y: (viewSize.height - drawSize.height) / 2
        )

        image.draw(in: NSRect(origin: origin, size: drawSize))
    }

    override func animateOneFrame() {
    }

    override var hasConfigureSheet: Bool {
        return false
    }

    override var configureSheet: NSWindow? {
        return nil
    }
}
