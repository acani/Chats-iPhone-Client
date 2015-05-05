class Account {
    let user: User
    var users = [User]()
    var chats = [Chat]()

    init(user: User) {
        self.user = user
    }
}
