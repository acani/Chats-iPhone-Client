struct Validation {
    static func isValidName(name: String) -> Bool {
        return 1...50 ~= name.characters.count
    }

    static func isValidEmail(email: String) -> Bool {
        let emailCharacters = email.characters
        return 3...254 ~= emailCharacters.count && emailCharacters.contains("@")
    }

    static func errorMessageWithEmail(email: String) -> String? {
        guard Validation.isValidEmail(email) else {
            return "Email must be between 3 & 254 characters and have an at sign."
        }
        return nil
    }

    static func errorMessageWithFirstName(firstName: String, lastName: String) -> String? {
        guard Validation.isValidName(firstName) else {
            return "First name must be between 1 & 50 characters."
        }
        guard Validation.isValidName(lastName) else {
            return "Last name must be between 1 & 50 characters."
        }
        return nil
    }

    static func errorMessageWithFirstName(firstName: String, lastName: String, email: String) -> String? {
        if let errorMessage = errorMessageWithFirstName(firstName, lastName: lastName) {
            return errorMessage
        }
        return errorMessageWithEmail(email)
    }
}

import Foundation.NSCharacterSet

extension String {
    func strip() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}
