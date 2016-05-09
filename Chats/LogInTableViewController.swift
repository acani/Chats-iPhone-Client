import UIKit
import Alerts
import Networking
import TextFieldTableViewCell
import Validator

class LogInTableViewController: UITableViewController, UITextFieldDelegate {
    convenience init() {
        self.init(style: .Grouped)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(LogInTableViewController.cancelAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(LogInTableViewController.doneAction))
        title = "Log In"
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
        textField.placeholder = "Email"
        textField.returnKeyType = .Done
        textField.becomeFirstResponder()
        return cell
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doneAction()
        return true
    }

    // MARK: - Actions

    func cancelAction() {
        tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))?.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func doneAction() {
        let email = tableView.textFieldForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.text!.strip()

        // Validate email
        guard email.isValidEmail else {
            return alert(title: "", message: Validator.invalidEmailMessage)
        }

        // Create code with email
        let request = api.request("POST", "/login", ["email": email])
        let dataTask = Net.dataTaskWithRequest(request, self) { _ in
            let enterCodeViewController = EnterCodeViewController(method: .Login, email: email)
            self.navigationController!.pushViewController(enterCodeViewController, animated: true)
        }
        dataTask.resume()
    }
}
