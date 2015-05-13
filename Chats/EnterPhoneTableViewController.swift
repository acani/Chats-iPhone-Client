import UIKit

class EnterPhoneTableViewController: UITableViewController {
    convenience init() {
        self.init(style: .Grouped)
        let verifyBarButtonItem = UIBarButtonItem(title: "Verify", style: .Done, target: self, action: "verifyAction")
        verifyBarButtonItem.enabled = false
        navigationItem.rightBarButtonItem = verifyBarButtonItem
        title = "Enter Phone Number"
    }

    // MARK - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextFieldTableViewCell))

        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44+32))
        tableFooterView.autoresizingMask = .FlexibleWidth
        tableView.tableFooterView = tableFooterView

        let continueAsGuestButton = UIButton.buttonWithType(.System) as! UIButton
        continueAsGuestButton.addTarget(self, action: "continueAsGuestAction", forControlEvents: .TouchUpInside)
        continueAsGuestButton.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin
        continueAsGuestButton.frame = CGRect(x: (view.frame.width-184)/2, y: 32, width: 184, height: 44)
        continueAsGuestButton.setTitle("Continue as Guest", forState: .Normal)
        continueAsGuestButton.titleLabel?.font = UIFont.systemFontOfSize(17)
        tableFooterView.addSubview(continueAsGuestButton)
    }

    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TextFieldTableViewCell), forIndexPath: indexPath) as! TextFieldTableViewCell
        let textField = cell.textField
        textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        textField.keyboardType = UIKeyboardType.PhonePad
        textField.becomeFirstResponder()
        return cell
    }

    // MARK: Actions

    func continueAsGuestAction() {
        continueAsGuest()
    }

    func textFieldDidChange(textField: UITextField) {
        let textLength = count(textField.text)
        navigationItem.rightBarButtonItem?.enabled = (textLength == 10)
    }

    func verifyAction() {
        println("Verify")
//        myAccount.createCodeWithPhone(textField.text)
    }
}
