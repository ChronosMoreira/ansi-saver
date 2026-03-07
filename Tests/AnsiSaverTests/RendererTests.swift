import XCTest

final class RendererTests: XCTestCase {

    func testRenderProducesImageFromValidANS() throws {
        let fixturePath = fixturesPath().appendingPathComponent("sample.ans").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: fixturePath),
                      "Fixture file should exist at \(fixturePath)")
        let image = try XCTUnwrap(Renderer.render(ansFileAt: fixturePath),
                                  "Renderer should produce a non-nil NSImage from a valid .ANS file")
        XCTAssertGreaterThan(image.size.width, 0)
        XCTAssertGreaterThan(image.size.height, 0)
    }

    func testRenderReturnsNilForMissingFile() {
        let image = Renderer.render(ansFileAt: "/nonexistent/path/file.ans")
        XCTAssertNil(image)
    }

    func testRenderReturnsNilForEmptyFile() throws {
        let tmp = NSTemporaryDirectory() + "empty_test.ans"
        FileManager.default.createFile(atPath: tmp, contents: Data())
        defer { try? FileManager.default.removeItem(atPath: tmp) }

        let image = Renderer.render(ansFileAt: tmp)
        XCTAssertNil(image)
    }

    private func fixturesPath() -> URL {
        let srcRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
        return srcRoot
    }
}
