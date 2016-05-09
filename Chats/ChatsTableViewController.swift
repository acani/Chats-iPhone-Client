import UIKit

class ChatsTableViewController: UITableViewController {
    var chats: [Chat] { return account.chats }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    convenience init() {
        self.init(style: .Plain)
        title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(ChatsTableViewController.newMessageAction))
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem() // TODO: KVO
        tableView.backgroundColor = .whiteColor()
        tableView.rowHeight = chatTableViewCellHeight
        tableView.separatorInset.left = chatTableViewCellInsetLeft
        tableView.registerClass(ChatTableViewCell.self, forCellReuseIdentifier: "ChatCell")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatsTableViewController.accountDidSendMessage(_:)), name: AccountDidSendMessageNotification, object: nil)
    }

    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath) as! ChatTableViewCell
        cell.configureWithChat(chats[indexPath.row])
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            account.chats.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            if chats.count == 0 {
                navigationItem.leftBarButtonItem = nil  // TODO: KVO
            }
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let chat = chats[indexPath.row]
        let chatViewController = ChatViewController(chat: chat)
        navigationController!.pushViewController(chatViewController, animated: true)
    }

    // MARK: - Actions

    func newMessageAction() {
        let navigationController = UINavigationController(rootViewController: NewMessageTableViewController(user: nil))
        presentViewController(navigationController, animated: true, completion: nil)
    }

    // MARK: - AccountDidSendMessageNotification

    // Move the note I just commented on to the top
    func accountDidSendMessage(notification: NSNotification) {
        let indexPath0 = NSIndexPath(forRow: 0, inSection: 0)

        let chat = notification.object as! Chat
        let row = chats.indexOf { $0 === chat }!
        if row == 0 {
            if chats.count > tableView.numberOfRowsInSection(0) {
                return tableView.insertRowsAtIndexPaths([indexPath0], withRowAnimation: .None)
            }
        } else {
            account.chats.removeAtIndex(row)
            account.chats.insert(chat, atIndex: 0)
            let fromIndexPath = NSIndexPath(forRow: row, inSection: 0)
            tableView.moveRowAtIndexPath(fromIndexPath, toIndexPath: indexPath0)
        }

        tableView.reloadRowsAtIndexPaths([indexPath0], withRowAnimation: .None)
    }
}
