import UIKit
import Alerts
import TextFieldTableViewCell
import Validator

class EditEmailTableViewController: UITableViewController, UITextFieldDelegate {
    convenience init() {
        self.init(style: .Grouped)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(EditEmailTableViewController.doneAction))
        title = "Email Address"
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
    }

    // MARK: - UITableViewDataSource

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell", forIndexPath: indexPath) as! TextFieldTableViewCell
        let textField = cell.textField
        textField.autocapitalizationType = .None
        textField.autocorrectionType = .No
        textField.clearButtonMode = .WhileEditing
        textField.delegate = self
        textField.keyboardType = .EmailAddress
        textField.placeholder = account.email
        textField.returnKeyType = .Done
        textField.text = account.email
        textField.becomeFirstResponder()
        return cell
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doneAction()
        return true
    }

    // MARK: - Actions

    func doneAction() {
        let newEmail = tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.text!.strip()

        // Validate email
        guard newEmail.isValidEmail else {
            return alert(title: "", message: Validator.invalidEmailMessage)
        }

        // Change email
        confirm(title: "Is your new email correct?", message: newEmail) { _ in
            if account.accessToken == "guest_access_token" {
                account.email = newEmail
                self.navigationController!.popViewControllerAnimated(true)
                return
            }
            account.changeEmail(self, newEmail: newEmail)
        }
    }
}
