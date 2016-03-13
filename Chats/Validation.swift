struct Validation {
    static func isValidName(name: String) -> Bool {
        return 1...50 ~= name.characters.count
    }

    static func errorMessageWithFirstName(firstName: String, lastName: String) -> String? {
        let contract = " name must be between 1 & 50 characters."
        if !isValidName(firstName) { return "First" + contract }
        if !isValidName(lastName)  { return "Last"  + contract }
        return nil
    }

    static func isValidEmail(email: String) -> Bool {
        let emailCharacters = email.characters
        return 3...254 ~= emailCharacters.count && emailCharacters.contains("@")
    }

    static func errorMessageWithEmail(email: String) -> String? {
        if !isValidEmail(email) {
            return "Email must be between 3 & 254 characters and have an at sign."
        }
        return nil
    }
}

import Foundation.NSCharacterSet

extension String {
    func strip() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}
