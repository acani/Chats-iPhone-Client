import XCTest

class ChatsUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // Generate a random string from "0000" to "9999"
    func randomString() -> String {
        let int = Int(arc4random_uniform(10000))
        return String(format: "%04d", int)
    }

    func testSignup() {
        let app = XCUIApplication()
        app.buttons["Sign Up"].tap()

        let tablesQuery = app.tables
        let nextButton = app.keyboards.buttons["Next"]

        let firstNameTextField = tablesQuery.textFields["First Name"]
        firstNameTextField.typeText("Acani")
        nextButton.tap()

        let lastNameTextField = tablesQuery.textFields["Last Name"]
        lastNameTextField.typeText("Chats")
        nextButton.tap()

        let suffix = randomString()
        let emailTextField = tablesQuery.textFields["Email"]
        emailTextField.typeText("acani.chats-\(suffix)@tempinbox.com")
        app.keyboards.buttons["Done"].tap()

        let collectionViewsQuery = app.alerts["Is your email correct?"].collectionViews
        collectionViewsQuery.buttons["No"].tap()
        app.navigationBars["Sign Up"].buttons["Done"].tap()
//        collectionViewsQuery.buttons["Yes"].tap()
//
//        app.typeText("1111")
//        app.alerts.collectionViews.buttons["OK"].tap()
//        app.typeText("2898")
    }
}
