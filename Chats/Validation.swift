class Validation {
    class func isValidName(name: String) -> Bool {
        return 1...50 ~= name.characters.count
    }

    class func isValidEmail(email: String) -> Bool {
        let emailCharacters = email.characters
        return 3...254 ~= emailCharacters.count && emailCharacters.contains("@")
    }

    class func errorMessageWithEmail(email: String) -> String? {
        if !Validation.isValidEmail(email) {
            return "Email must be between 3 & 254 characters and have an at sign."
        } else {
            return nil
        }
    }

    class func errorMessageWithFirstName(firstName: String, lastName: String, email: String) -> String? {
        if !Validation.isValidName(firstName) {
            return "First name must be between 1 & 50 characters."
        } else if !Validation.isValidName(lastName) {
            return "Last name must be between 1 & 50 characters."
        } else {
            return errorMessageWithEmail(email)
        }
    }
}

import Foundation.NSCharacterSet

extension String {
    mutating func strip() {
        self = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}
