import ObjectiveC.NSObject

let account = Account()

class Account: NSObject {
    dynamic var accessToken: String!
    var user: User!
    var users = [User]()
    var chats = [Chat]()

    func logOut() {
        accessToken = nil
        user = nil
    }

    func deleteAccount() {
        logOut()
    }
}
