import UIKit

class SettingsTableViewController: UITableViewController, UIActionSheetDelegate {
    convenience init() {
        self.init(style: .Grouped)
        title = "Settings"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.textAlignment = .Center

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Log Out"
            cell.textLabel?.textColor = UIColor(red: 0/255, green: 88/255, blue: 249/255, alpha: 1)
        default:
            cell.textLabel?.text = "Delete Account"
            cell.textLabel?.textColor = UIColor(red: 252/255, green: 53/255, blue: 56/255, alpha: 1)
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch indexPath.section {
        case 0:
            account.logOut()
        default:
            let actionSheet = UIActionSheet(title: "Deleting your account will permanently delete your phone number, picture, and first & last name.\n\nAre you sure you want to delete your account?", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Delete Accout")
            actionSheet.showInView(tableView.window)
        }
    }

    // MARK: - UIActionSheetDelegate

    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            account.deleteAccount()
        }
    }
}
