import XCTest

@testable import Chats

class ChatsTests: XCTestCase {
    func testInitials() {
        let users = [
            (User(ID: 1, username: "mattdipasquale", firstName: "Matt", lastName: "Di Pasquale"), "MD"),
            (User(ID: 2, username: "walterstephanie", firstName: "Ë", lastName: "R"), "ËR"),
            (User(ID: 3, username: "wake_gs", firstName: "Ë", lastName: "中"), "Ë")
        ]

        for (user, initials) in users {
            XCTAssertEqual(user.initials!, initials, "")
        }
    }

    func testWords() {
        XCTAssertEqual("".words(), [])
        XCTAssertEqual(" \n$#@-_^`~".words(), [])

        XCTAssertEqual("hey".words(), ["hey"])
        XCTAssertEqual("@hey ".words(), ["hey"])

        XCTAssertEqual("Káty Smith-Shapiro_".words(), ["Káty", "Smith", "Shapiro"])
        XCTAssertEqual("?c00l_dud3::3n1ce*".words(), ["c00l", "dud3", "3n1ce"])
    }

    func testMatchesFilterString() {
        XCTAssertTrue("Matt Di Pasquale".matchesFilterString("Mat pasqu D"))
        XCTAssertFalse("Matt Di Pasquale".matchesFilterString("L Pasqu"))
        XCTAssertTrue("Káty Smith-Shapiro_".matchesFilterString("sh smit smit katy"))
    }
}
