import XCTest

final class QuranSphereUITests: XCTestCase {

    override func setUpWithError() throws {
        // UI tests must launch the application that they test.
        continueAfterFailure = false
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
