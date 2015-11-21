import UIKit

class EditEmailTableViewController: UITableViewController {
    convenience init() {
        self.init(style: .Grouped)
        let verifyBarButtonItem = UIBarButtonItem(title: "Verify", style: .Done, target: self, action: "verifyAction")
        verifyBarButtonItem.enabled = false
        navigationItem.rightBarButtonItem = verifyBarButtonItem
        title = "Email Address"
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextFieldTableViewCell))
    }

    // MARK: UITableView

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TextFieldTableViewCell), forIndexPath: indexPath) as! TextFieldTableViewCell
        let textField = cell.textField
        textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        textField.clearButtonMode = .WhileEditing
        textField.keyboardType = .EmailAddress
        textField.placeholder = account.email
        textField.text = account.email
        textField.becomeFirstResponder()
        return cell
    }

    // MARK: Actions

    func textFieldDidChange(textField: UITextField) {
        let text = textField.text!
        navigationItem.rightBarButtonItem?.enabled = (ValidationHelper.isValidEmail(text) && text != account.email)
    }

    func verifyAction() {
        print("Verify")
        //        myAccount.createCodeWithPhone(textField.text)
    }
}
