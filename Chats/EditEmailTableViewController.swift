import UIKit

class EditEmailTableViewController: UITableViewController, UITextFieldDelegate {
    convenience init() {
        self.init(style: .Grouped)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneAction")
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
        textField.autocapitalizationType = .None
        textField.autocorrectionType = .No
        textField.clearButtonMode = .WhileEditing
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

    // MARK: Actions

    func doneAction() {
        var newEmail = tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.text!
        newEmail.strip()

        // Validate newEmail
        if let errorMessage = Validation.errorMessageWithEmail(newEmail) {
            let alert = UIAlertController(title: "", message: errorMessage, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Is your new email correct?", message: newEmail, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .Default) { _ in
                account.changeEmail(self, newEmail: newEmail)
            })
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}
