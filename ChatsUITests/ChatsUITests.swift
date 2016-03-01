import XCTest

// 1. Add fake test users
// 2. Check that they show up
//     Click on them

class ChatsUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDown() {
        super.tearDown()
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

        let username = "acani.chats-" + random4DigitString()
        let emailTextField = tablesQuery.textFields["Email"]
        emailTextField.typeText(username+"@tempinbox.com")
        app.keyboards.buttons["Done"].tap()

        let collectionViewsQuery = app.alerts["Is your email correct?"].collectionViews
        collectionViewsQuery.buttons["No"].tap()
        app.navigationBars["Sign Up"].buttons["Done"].tap()
//        collectionViewsQuery.buttons["Yes"].tap()
//
//        app.typeText("1111")
//        let okButton = app.alerts.collectionViews.buttons["OK"]
//        okButton.tap()
//        guard let code = getCode(username) else {
//            XCTFail("Couldn't get code")
//            return
//        }
//        app.typeText(code)
    }

    // Generate a random string from "0000" to "9999"
    func random4DigitString() -> String {
        let int = Int(arc4random_uniform(10000))
        return String(format: "%04d", int)
    }

    func getCode(username: String) -> String? {
        guard let queryString = getQueryString(username) else {
            return nil
        }
        let code = scrapePath("/cgi-bin/viewmail.pl?"+queryString, regex: "\n\\d{4}\n")!
        return code.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }

    func getQueryString(username: String) -> String? {
        let path = "/cgi-bin/checkmail.pl?username=\(username)&button=Check+Mail&terms=on&large=1"
        for _ in 1...10 {
            if let queryString = scrapePath(path, regex: "id=\\d+&kw=Signup") {
                return queryString + "+Code"
            }
            sleep(5)
        }
        return nil
    }

    func scrapePath(path: String, regex: String) -> String? {
        let session = NSURLSession.sharedSession()
        let baseURL = NSURL(string: "http://www.tempinbox.com")
        let url = NSURL(string: path, relativeToURL: baseURL)!
        let data = session.synchronousDataTaskWithURL(url).data!
        let source = String(data: data, encoding: NSUTF8StringEncoding)!
        let range = source.rangeOfString(regex, options: .RegularExpressionSearch)
        return range != nil ? source.substringWithRange(range!) : nil
    }
}

extension NSURLSession {
    func synchronousDataTaskWithURL(url: NSURL) -> (data: NSData?, response: NSURLResponse?, error: NSError?) {
        var data: NSData?, response: NSURLResponse?, error: NSError?

        let semaphore = dispatch_semaphore_create(0)

        dataTaskWithURL(url) {
            data = $0; response = $1; error = $2
            dispatch_semaphore_signal(semaphore)
            }.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        return (data, response, error)
    }
}
