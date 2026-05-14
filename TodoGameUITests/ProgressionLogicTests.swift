import XCTest
@testable import TodoGameUI

final class ProgressionLogicTests: XCTestCase {
    func testLevelProgressMath() {
        var profile = PlayerProfile.starter
        profile.totalXP = 100
        profile.level = 2
        XCTAssertEqual(profile.xpIntoCurrentLevel, 0)
        XCTAssertEqual(profile.xpNeededForNextLevel, 140)
    }
}
