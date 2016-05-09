import UIKit

class SettingsTableViewController: UITableViewController {
    enum Section : Int {
        case Email
        case LogOut
        case DeleteAccount
    }

    convenience init() {
        self.init(style: .Grouped)
        title = "Settings"
    }

    deinit {
        if isViewLoaded() {
            account.removeObserver(self, forKeyPath: "email")
        }
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        account.addObserver(self, forKeyPath: "email", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Set style & identifier based on section
        let section = Section(rawValue: indexPath.section)!
        var style: UITableViewCellStyle = .Default
        var cellIdentifier = "DefaultCell"
        if section == .Email {
            style = .Value1
            cellIdentifier = "Value1Cell"
        }

        // Dequeue or create cell with style & identifier
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: style, reuseIdentifier: cellIdentifier)
            cell.textLabel!.font = UIFont.systemFontOfSize(18)
        }

        // Customize cell
        cell.textLabel!.textAlignment = .Center
        switch section {
        case .Email:
            cell.accessoryType = .DisclosureIndicator
            cell.detailTextLabel!.text = account.email
            cell.textLabel!.text = "Email"
            cell.textLabel!.textAlignment = .Left
        case .LogOut:
            cell.textLabel!.text = "Log Out"
            cell.textLabel!.textColor = UIColor(red: 0/255, green: 88/255, blue: 249/255, alpha: 1)
        case .DeleteAccount:
            cell.textLabel!.text = "Delete Account"
            cell.textLabel!.textColor = UIColor(red: 252/255, green: 53/255, blue: 56/255, alpha: 1)
        }

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        switch Section(rawValue: indexPath.section)! {
        case .Email:
            navigationController!.pushViewController(EditEmailTableViewController(), animated: true)
        case .LogOut:
            if account.accessToken == "guest_access_token" {
                account.logOutGuest()
            } else {
                account.logOut(self)
            }
        case .DeleteAccount:
            let actionSheet = UIAlertController(title: "Deleting your account will permanently delete your first & last name, email address, and chat history.\n\nAre you sure you want to delete your account?", message: nil, preferredStyle: .ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Delete Account", style: .Destructive) { _ in
                if account.accessToken == "guest_access_token" {
                    return account.logOutGuest()
                }
                account.deleteAccount(self)
            })
            presentViewController(actionSheet, animated: true, completion: nil)
        }
    }

    // MARK: - NSKeyValueObserving

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // Update email cell when account.email changes
        let emailIndexPath = NSIndexPath(forRow: 0, inSection: Section.Email.rawValue)
        let emailCell = tableView.cellForRowAtIndexPath(emailIndexPath)
        emailCell?.detailTextLabel!.text = account.email
    }
}
