class ServerUser: User {
    var serverUsername: String {
        didSet {
            username = serverUsername
        }
    }
    var serverFirstName: String {
        didSet {
            firstName = serverFirstName
        }
    }
    var serverLastName: String {
        didSet {
            lastName = serverLastName
        }
    }

    override init(ID: UInt, username: String, firstName: String, lastName: String) {
        serverUsername = username
        serverFirstName = firstName
        serverLastName = lastName
        super.init(ID: ID, username: username, firstName: firstName, lastName: lastName)
    }
}
